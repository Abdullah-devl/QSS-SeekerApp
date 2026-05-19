// lib/core/services/notification_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:seeker/features/notifications/repositories/notification_repository.dart';
import 'dart:developer' as developer;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log("Handling a background message: ${message.messageId}");
  developer.log("Background message data: ${message.data}");
  developer.log(
    "Background message notification: ${message.notification?.title}",
  );

  try {
    if (message.notification == null) {
      final FlutterLocalNotificationsPlugin localNotifications =
          FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await localNotifications.initialize(initializationSettings);

      String title = message.data['title']?.toString() ?? 'إشعار جديد 🔔';
      String body =
          message.data['body']?.toString() ??
          message.data['message']?.toString() ??
          'لديك بيانات جديدة في الخلفية';

      await localNotifications.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel_v2',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  } catch (e) {
    developer.log('❌ Error in background handler: $e');
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  NotificationRepository? _repository;
  int _retryCount = 0; // عداد لمنع التكرار اللانهائي

  // تيار (Stream) للتحكم في التنقل عند الضغط على الإشعار
  final StreamController<Map<String, dynamic>> _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  Future<void> initialize(NotificationRepository repository) async {
    _repository = repository;

    // 1. طلب الصلاحيات
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('🔔 NotificationService: User granted permission');
    }

    // إعداد ظهور الإشعارات في المقدمة للايفون (iOS Foreground Options)
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // إعداد معالجة الإشعارات في الخلفية (Background Handler)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. إعداد قنوات الإشعارات للأندرويد (هام جداً للظهور كـ Banner)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel_v2', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 3. إعداد الإشعارات المحلية
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _notificationStreamController.add(Map<String, dynamic>.from(data));
        }
      },
    );

    // 3. معالجة التوكن
    _setupToken();

    // 4. الاستماع للإشعارات والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        '📩 NotificationService: Message received in foreground: ${message.notification?.title}',
      );
      _showLocalNotification(message);
    });

    // 5. الاستماع عند الضغط على الإشعار والتطبيق في الخلفية (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('🖱️ NotificationService: Notification clicked!');
      _notificationStreamController.add(message.data);
    });

    // 6. التحقق إذا تم فتح التطبيق من إشعار وهو مغلق تماماً (Terminated)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _notificationStreamController.add(initialMessage.data);
    }
  }

  Future<void> _setupToken() async {
    // تحديث التوكن تلقائياً إذا تغير من فيربييس
    _fcm.onTokenRefresh.listen((newToken) async {
      developer.log('🔄 FCM Token Refreshed: $newToken');
      await _repository?.storeToken(newToken);
    });
  }

  /// 🔑 جلب التوكن الحالي وإرساله للسيرفر (يُستدعى عند الدخول)
  Future<void> updateTokenToServer() async {
    print('🧐 [NOTIFICATION SERVICE]: Starting updateTokenToServer...');

    // تشخيص: التأكد من أن Firebase يقرأ الإعدادات الصحيحة
    try {
      final options = Firebase.app().options;
      print('ℹ️ [FIREBASE CONFIG]: Project ID: ${options.projectId}');
      print('ℹ️ [FIREBASE CONFIG]: App ID: ${options.appId}');
      print('ℹ️ [FIREBASE CONFIG]: API Key: ${options.apiKey}');
    } catch (e) {
      print('⚠️ [FIREBASE CONFIG]: Could not read options: $e');
    }

    if (_repository == null) {
      print(
        '⚠️ [NOTIFICATION SERVICE]: Repository is NULL! Waiting 2 seconds...',
      );
      await Future.delayed(const Duration(seconds: 2));
      if (_repository == null) {
        print(
          '❌ [NOTIFICATION SERVICE]: Repository still NULL. Cannot send token.',
        );
        return;
      }
    }

    try {
      // ⏳ انتظار أطول قليلاً لضمان استقرار خدمات فيربييس على الجهاز
      print(
        '⏳ [NOTIFICATION SERVICE]: Waiting for Firebase to stabilize (5s)...',
      );
      await Future.delayed(const Duration(seconds: 5));

      // محاولة الحصول على التوكن
      String? token = await _fcm.getToken();

      if (token != null) {
        print(
          '✅ [NOTIFICATION SERVICE]: FCM Token Found: ${token.substring(0, 10)}...',
        );
        _retryCount = 0; // نجاح! تصفير العداد
        await _repository?.storeToken(token);
      } else {
        print('❌ [NOTIFICATION SERVICE]: FCM Token is NULL from Firebase.');
      }
    } catch (e) {
      print('❌ [NOTIFICATION SERVICE]: Exception during token fetch: $e');

      if (e.toString().contains('FIS_AUTH_ERROR')) {
        _retryCount++;
        if (_retryCount > 3) {
          print(
            '🚫 [NOTIFICATION SERVICE]: Max retries reached (3). Stopping fix attempts.',
          );
          print(
            '💡 [ACTION REQUIRED]: Please check Google Cloud Console -> API Restrictions.',
          );
          _retryCount = 0;
          return;
        }

        print(
          '🔧 [FIX ATTEMPT #$_retryCount]: FIS_AUTH_ERROR detected. Trying a deep reset...',
        );
        try {
          await FirebaseInstallations.instance.delete();
          print('✅ [FIX]: Firebase Installation deleted. Retrying in 5s...');
          await Future.delayed(const Duration(seconds: 5));
          return updateTokenToServer(); // إعادة المحاولة
        } catch (retryError) {
          print('❌ [FIX FAILED]: Could not recover: $retryError');
        }
      }
    }
  }

  /// 🚪 حذف التوكن من السيرفر (يُستدعى عند تسجيل الخروج)
  Future<void> deleteTokenOnLogout() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _repository?.removeToken(token);
      }
      // مسح التوكن من فيربييس أيضاً
      await _fcm.deleteToken();
    } catch (e) {
      print('❌ [NOTIFICATION SERVICE]: Error during token deletion: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // التحقق مما إذا كان هناك عنوان أو نص في الإشعار أو في البيانات (Data Payload)
    String? title = notification?.title ?? message.data['title'];
    String? body =
        notification?.body ?? message.data['body'] ?? message.data['message'];

    // إذا كان كلاهما null، ربما نستخدم بيانات احتياطية لضمان ظهور الإشعار للتجربة
    if (title == null && body == null) {
      developer.log(
        '⚠️ [NOTIFICATION SERVICE]: No title or body found in payload!',
      );
      // يمكنك إزالة هذا السطر إذا كنت لا تريد ظهور إشعارات فارغة
      // title = 'إشعار جديد';
      // body = 'تم استلام بيانات جديدة';
    }

    if (title != null || body != null) {
      try {
        await _localNotifications.show(
          notification?.hashCode ?? message.hashCode,
          title ?? 'إشعار',
          body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel_v2',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon:
                  '@mipmap/ic_launcher', // الاعتماد على الأيقونة الافتراضية دائماً لتجنب مشاكل الأيقونات المفقودة
              channelShowBadge: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      } catch (e) {
        developer.log(
          '❌ [NOTIFICATION SERVICE]: Error showing local notification: $e',
        );
      }
    }
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
