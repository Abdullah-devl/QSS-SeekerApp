import 'package:flutter/material.dart';

/// 📂 اسم الملف: custom_text_field.dart
/// 📝 الوصف: ويدجت مخصص لحقول الإدخال النصي (Text Field).
/// الهدف: توحيد تصميم حقول الإدخال في التطبيق وتقليل تكرار الكود.
/// يدعم حقول النصوص العادية وحقول كلمات المرور مع زر إظهار/إخفاء.

class CustomTextField extends StatefulWidget {
  /// عنوان الحقل الذي يظهر في الأعلى (Label).
  final String labelText;

  /// النص التوضيحي الذي يختفي عند الكتابة (Hint).
  final String hintText;

  /// المتحكم في النص (Controller) لإدارة القيمة المدخلة.
  final TextEditingController controller;

  /// تحديد ما إذا كان الحقل مخصصاً لكلمة المرور (يخفي النص).
  final bool isPassword;

  /// الأيقونة التي تظهر في بداية الحقل.
  final IconData icon;

  /// دالة التحقق من صحة المدخلات (Validation).
  final String? Function(String?)? validator;

  /// لون تعبئة الحقل (اختياري).
  final Color? fillColor;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.isPassword = false, // القيمة الافتراضية false (حقل عادي)
    required this.icon,
    this.validator,
    this.fillColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // متغير للتحكم في إظهار/إخفاء كلمة المرور.
  // يبدأ بـ true (مخفي) إذا كان الحقل كلمة مرور.
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Directionality لتحديد اتجاه النص (يمين لليسار RTL بما أن التطبيق عربي)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextFormField(
          controller: widget.controller,

          // تحديد خاصية إخفاء النص بناءً على نوع الحقل وحالة الزر
          obscureText: widget.isPassword ? _obscureText : false,

          validator: widget.validator,

          // تفعيل التحقق التلقائي عند تفاعل المستخدم
          autovalidateMode: AutovalidateMode.onUserInteraction,

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: Icon(widget.icon),

            // 👁️ زر إظهار/إخفاء كلمة المرور (يظهر فقط إذا كان الحقل كلمة مرور)
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      // تغيير الأيقونة بناءً على الحالة
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      // عكس الحالة عند الضغط
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null, // لا يوجد أيقونة إذا لم يكن كلمة مرور

            filled: true,
            // لون الخلفية: إما المحدد أو لون افتراضي شفاف داكن قليلاً
            fillColor: widget.fillColor ?? const Color.fromARGB(66, 0, 0, 0),

            // 🔹 الحدود في الحالة الطبيعية
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),

            // 🔹 الحدود عند التركيز (Focus)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),

            // 🔹 الحدود عند وجود خطأ (Error) ولكن بدون تركيز
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),

            // 🔹 الحدود عند وجود خطأ + تركيز
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),

            // 🔹 تنسيق نص رسالة الخطأ
            errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
