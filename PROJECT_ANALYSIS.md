# 📊 Project Analysis: Seeker (Service Finder App)

## 1. 🚀 Executive Summary
**Seeker** is a modern Flutter-based mobile application designed to connect users with service providers (plumbers, cleaners, electricians, etc.). The app features a robust service discovery system, category filtering, detailed service information, and a booking flow.

## 2. 🛡️ Technical Architecture
The project follows the **Clean MVVM (Model-View-ViewModel)** architectural pattern with a dedicated **Repository** layer for data handling. 

### 🏛️ Layers
-   **Model**: Data structures and JSON parsing (`ServiceModel`, `CategoryModel`, `UserProfileModel`).
-   **View**: Generic UI components and screens using Flutter widgets.
-   **ViewModel**: State management logic using the **Provider** pattern to decouple UI from business logic.
-   **Repository**: Acts as a bridge between the ViewModel and the Data Source (API).

## 3. 🛠️ Technology Stack
-   **Framework**: Flutter (Dart)
-   **State Management**: `provider` 
-   **Networking**: `dio` (with a centralized `ApiService`)
-   **Storage**: `shared_preferences` for basic persistence.
-   **Location & Maps**: `google_maps_flutter`, `geolocator`, `geocoding`.
-   **Asset Handling**: `image_picker` for uploads.
-   **Localization**: `flutter_localizations` with full **Arabic (AR)** and **English (EN)** support.
-   **Theming**: Custom **QSColors** theme extension for flexible dark/light mode and branding colors.

## 4. 📂 Folder Structure Analysis
The `lib` directory is organized into modular features for high maintainability:

```text
lib/
├── core/                # Centralized logic
│   ├── network/         # ApiService & Endpoints
│   ├── routes/          # Navigation logic
│   ├── theme/           # QSColors & Design tokens
│   └── utils/           # Shared helpers
├── features/            # Feature-based modules
│   ├── auth/            # Login/Register logic
│   ├── home/            # Discovery, Categories, Services
│   ├── profile/         # User/Provider profile views
│   ├── settings/        # App configurations
│   └── intro/           # Onboarding & Splash
└── l10n/                # Localization (ARB files)
```

## 5. ✨ Key Features
1.  **Onboarding & Auth**: Secure login/registration and welcome tour.
2.  **Service Discovery**: Categorized viewing of services with search and filtering.
3.  **Detailed Service Info**: Includes ratings, reviews, working hours, and maps.
4.  **Booking Flow**: `ConfirmOrder` workflow for finalized service requests.
5.  **Multi-Mode Profile**:
    -   **Personal Profile**: Manage account info (SettingsViewModel).
    -   **Provider Profile**: View provider bio, gallery, and contact info (ProfileViewModel).
6.  **Real-Time Geolocation**: Map picking for service locations.

## 6. 📈 Strategic Recommendations
-   **Cache Layer**: Integrate `Hive` or `SQLite` for offline-first support.
-   **Unit Testing**: Expand coverage for the `Repository` and `ViewModel` layers.
-   **Push Notifications**: Implement `Firebase Cloud Messaging` for order updates.
-   **Design System**: Further componentization of UI elements into a shared `widgets` folder.
