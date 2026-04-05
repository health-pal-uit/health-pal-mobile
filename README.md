# Health Pal Mobile 🏥

A comprehensive Flutter-based mobile health and fitness tracking application that helps users monitor their health metrics, manage diet and exercise, connect with a community, and receive personalized health advice.

[![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📖 About The Project

Health Pal is a mobile health companion that empowers users to take control of their wellness journey. The application provides comprehensive tools for tracking daily activities, managing nutrition, monitoring exercise routines, and connecting with a health-focused community. With features like Google OAuth integration, personalized onboarding, and real-time health metrics tracking, Health Pal makes maintaining a healthy lifestyle accessible and engaging.

### Key Features

- 🔐 **Authentication**: Secure login with email/password and Google OAuth integration
- 📊 **Health Tracking**: Monitor steps, calories, exercise activities, and nutrition
- 🍎 **Diet Management**: Search and track food intake with detailed nutritional information
- 💪 **Exercise Analytics**: Log workouts and view detailed activity analytics
- 👥 **Community**: Connect with other users, share progress, and build a supportive network
- 🎯 **Personalized Onboarding**: Customized setup flow to capture user health metrics
- 🔔 **Password Recovery**: Secure password reset flow powered by Supabase

## 🛠️ Built With

### Core Technologies

- **Flutter** (^3.7.0) - Cross-platform mobile framework
- **Dart** (^3.7.0) - Programming language

### State Management & Architecture

- **flutter_bloc** (^8.1.2) - BLoC pattern for state management
- **go_router** (^16.2.1) - Declarative routing
- **equatable** (^2.0.5) - Value equality comparisons
- **dartz** (^0.10.1) - Functional programming utilities

### Backend & Authentication

- **Supabase Flutter** (^2.9.4) - Backend-as-a-Service and authentication
- **Dio** (^5.3.3) - HTTP client for REST API communication
- **JWT Decoder** (^2.0.1) - JSON Web Token decoding

### UI Components & Design

- **flutter_screenutil** (^5.9.3) - Responsive UI design
- **lucide_icons_flutter** (^3.1.4) - Modern icon pack
- **font_awesome_flutter** (^10.9.1) - Font Awesome icons
- **flutter_signin_button** (^2.1.1) - Pre-built OAuth sign-in buttons
- **fl_chart** (^1.1.1) - Beautiful data visualization charts
- **syncfusion_flutter_gauges** (^31.1.19) - Circular progress indicators

### Local Storage & Security

- **flutter_secure_storage** (^9.2.4) - Encrypted local data storage
- **flutter_dotenv** (^6.0.0) - Environment variable management

### Additional Features

- **url_launcher** (^6.3.1) - External URL handling for OAuth
- **app_links** (^6.3.4) - Deep linking support
- **intl** (^0.20.2) - Internationalization and date formatting

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.7.0 or higher
- **Dart SDK**: Version 3.0 or higher
- **Android Studio** or **Xcode** (for mobile development)
- **Git**: For version control

To verify your Flutter installation:

```bash
flutter doctor
```

## ⚙️ Setup & Installation

### 1. Clone the Repository

```bash
git clone https://github.com/health-pal-uit/health-pal-mobile.git
cd health-pal-mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Create a `.env` file in the root directory and add your environment variables:

```env
# Backend Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_DATABASE=health-pal-db

# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
SUPABASE_JWT_SECRET=your_jwt_secret

# Google OAuth Configuration
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_CALLBACK_URL=http://localhost:3001/auth/google/callback

# Application Configuration
PORT=3001
NODE_ENV=development
```

### 4. Backend Setup (Optional)

If you're running a custom backend server:

```bash
# Navigate to your backend directory
cd ../backend

# Install dependencies
npm install

# Run migrations
npm run migrate

# Start the backend server
npm run dev
```

The backend API should be running on `http://localhost:3001`.

## 🚀 How to Run

### Development Mode

#### Android Emulator

1. Start an Android emulator or connect a physical device
2. Run the application:

```bash
flutter run
```

#### iOS Simulator (macOS only)

1. Open iOS Simulator
2. Run the application:

```bash
flutter run
```

### Specific Device

To run on a specific device:

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Hot Reload

While the app is running, you can use hot reload for faster development:

- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## 🏗️ Build for Production

### Android APK

```bash
# Build APK
flutter build apk

# Build App Bundle (recommended for Play Store)
flutter build appbundle
```

The output will be in `build/app/outputs/flutter-apk/` or `build/app/outputs/bundle/`.

### iOS

```bash
# Build iOS app
flutter build ios
```

> **Note**: Building for iOS requires a macOS system with Xcode installed.

## 📂 Project Structure

```
lib/
├── src/
│   ├── app.dart                    # Main app widget
│   ├── config/                     # Configuration files
│   │   ├── api_config.dart        # API endpoints
│   │   ├── env.dart               # Environment variables
│   │   ├── routes.dart            # App routing
│   │   └── theme/                 # Theme configuration
│   ├── core/                       # Core utilities
│   │   └── services/              # Services (auth, deep linking)
│   ├── data/                       # Data layer
│   │   ├── datasources/           # Remote & local data sources
│   │   └── repositories/          # Repository implementations
│   ├── domain/                     # Domain layer
│   │   └── entities/              # Business entities
│   └── presentation/               # Presentation layer
│       ├── bloc/                  # BLoC state management
│       ├── screens/               # App screens
│       └── widgets/               # Reusable widgets
└── main.dart                       # Application entry point
```

## 🔧 Configuration

### Deep Linking Setup

The app supports deep linking for OAuth callbacks and password reset flows.

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="da1" android:host="auth" />
    <data android:scheme="da1" android:host="reset-callback" />
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>da1</string>
        </array>
    </dict>
</array>
```

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Run Integration Tests

```bash
flutter test integration_test
```

## 📱 Features Overview

### Authentication Flow

- Welcome screens with onboarding
- Email/password registration and login
- Google OAuth integration
- Password reset via email (Supabase)
- Email verification

### Health Tracking

- Step counter with daily goals
- Calorie tracking and management
- Water intake monitoring
- Weight and height tracking

### Exercise & Activity

- Activity logging and analytics
- Exercise search and categorization
- Workout statistics and charts
- Weekly progress tracking

### Nutrition

- Food search functionality
- Meal logging (breakfast, lunch, dinner)
- Calorie and nutritional information
- Custom meals and recipes

### Community

- User profiles
- Social feed with posts
- Health stats sharing
- Community engagement

### Profile Management

- Personal health information
- Account settings
- Notification preferences
- Theme customization

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

**Health Pal Team** - UIT (University of Information Technology)

- Repository: [health-pal-uit/health-pal-mobile](https://github.com/health-pal-uit/health-pal-mobile)

## 📞 Support

For support and questions:

- Create an issue in the GitHub repository
- Contact: duyhuu1109@gmail.com

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Supabase](https://supabase.com/) - Backend infrastructure
- [BLoC Library](https://bloclibrary.dev/) - State management
- All open-source contributors

---

Made with ❤️ by the Health Pal Team

- **app_links** (^6.3.4) - Deep linking support
- **intl** (^0.19.0) - Internationalization and date formatting
- **dartz** (^0.10.1) - Functional programming utilities

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.7.0 or higher
    ```bash
    flutter --version
    ```

```
da1
├─ .metadata
├─ analysis_options.yaml
├─ assets
│  ├─ icons
│  │  ├─ google_fit.svg
│  │  └─ health-pal-logo.png
│  └─ images
│     ├─ welcome1.jpeg
│     ├─ welcome2.jpeg
│     └─ welcome3.jpeg
├─ commitlint.config.js
├─ devtools_options.yaml
├─ firebase.json
├─ lib
│  ├─ firebase_options.dart
│  ├─ main.dart
│  └─ src
│     ├─ app.dart
│     ├─ config
│     │  ├─ api_config.dart
│     │  ├─ constants.dart
│     │  ├─ env.dart
│     │  ├─ routes.dart
│     │  ├─ theme
│     │  │  ├─ app_colors.dart
│     │  │  ├─ app_theme.dart
│     │  │  └─ typography.dart
│     │  └─ utils
│     │     ├─ date_time_helper.dart
│     │     └─ hashtag_helper.dart
│     ├─ core
│     │  ├─ bloc
│     │  │  └─ user
│     │  │     ├─ user.dart
│     │  │     ├─ user_bloc.dart
│     │  │     ├─ user_event.dart
│     │  │     └─ user_state.dart
│     │  ├─ errors
│     │  │  ├─ exceptions.dart
│     │  │  └─ failure.dart
│     │  ├─ models
│     │  │  ├─ user.dart
│     │  │  └─ user_model.dart
│     │  ├─ network
│     │  │  └─ auth_interceptor.dart
│     │  ├─ repositories
│     │  │  └─ user_repository_impl.dart
│     │  └─ services
│     │     ├─ auth_service.dart
│     │     ├─ chat_service.dart
│     │     ├─ deep_link_service.dart
│     │     ├─ device_registration_service.dart
│     │     └─ local_notification_service.dart
│     └─ features
│        ├─ expert
│        ├─ shared
│        │  ├─ auth
│        │  │  ├─ data
│        │  │  │  ├─ auth_repository.dart
│        │  │  │  ├─ auth_repository_impl.dart
│        │  │  │  ├─ datasources
│        │  │  │  │  ├─ auth_local_data_source.dart
│        │  │  │  │  ├─ auth_remote_data_source.dart
│        │  │  │  │  └─ fitness_goal_remote_data_source.dart
│        │  │  │  └─ fitness_goal_repository.dart
│        │  │  └─ presentation
│        │  │     ├─ auth
│        │  │     │  ├─ email_verification_screen.dart
│        │  │     │  ├─ forgot_password_screen.dart
│        │  │     │  ├─ login_screen.dart
│        │  │     │  ├─ onboarding
│        │  │     │  │  ├─ onboarding_activity_level_screen.dart
│        │  │     │  │  ├─ onboarding_body_measurements_screen.dart
│        │  │     │  │  ├─ onboarding_complete_screen.dart
│        │  │     │  │  ├─ onboarding_goal_type_screen.dart
│        │  │     │  │  ├─ onboarding_height_screen.dart
│        │  │     │  │  └─ onboarding_weight_screen.dart
│        │  │     │  ├─ password_reset_waiting_screen.dart
│        │  │     │  ├─ reset_password_screen.dart
│        │  │     │  ├─ signup_screen.dart
│        │  │     │  └─ welcome
│        │  │     │     └─ welcome_scroll_screen.dart
│        │  │     └─ auth_bloc
│        │  │        ├─ auth.dart
│        │  │        ├─ auth_bloc.dart
│        │  │        ├─ auth_event.dart
│        │  │        └─ auth_state.dart
│        │  └─ notifications
│        │     └─ data
│        │        ├─ datasources
│        │        │  └─ device_remote_data_source.dart
│        │        └─ device_repository.dart
│        └─ user
│           ├─ advisor
│           │  └─ presentation
│           │     ├─ advisor_screen.dart
│           │     └─ widgets
│           │        ├─ chat_message_widget.dart
│           │        ├─ clear_chat_dialog.dart
│           │        ├─ empty_state_widget.dart
│           │        └─ typing_indicator.dart
│           ├─ chat
│           │  ├─ data
│           │  │  ├─ chat_message_repository.dart
│           │  │  ├─ chat_model.dart
│           │  │  ├─ chat_session_repository.dart
│           │  │  └─ datasources
│           │  │     ├─ chat_message_remote_data_source.dart
│           │  │     ├─ chat_remote_data_source.dart
│           │  │     └─ chat_session_remote_data_source.dart
│           │  ├─ domain
│           │  │  ├─ chat_message.dart
│           │  │  ├─ chat_participant.dart
│           │  │  ├─ chat_session.dart
│           │  │  └─ user_chat_message.dart
│           │  └─ presentation
│           │     ├─ add_group_participant_screen.dart
│           │     ├─ chat_list_screen.dart
│           │     ├─ chat_thread_screen.dart
│           │     ├─ group_participants_screen.dart
│           │     ├─ new_chat_screen.dart
│           │     ├─ new_group_chat_screen.dart
│           │     └─ widgets
│           │        ├─ delete_chat_dialog.dart
│           │        ├─ message_bubble.dart
│           │        └─ message_input.dart
│           ├─ community
│           │  ├─ data
│           │  │  ├─ comment_model.dart
│           │  │  ├─ datasources
│           │  │  │  └─ post_remote_data_source.dart
│           │  │  └─ post_model.dart
│           │  └─ presentation
│           │     ├─ community_screen.dart
│           │     ├─ personal_profile_screen.dart
│           │     └─ widgets
│           │        ├─ attachment_selection_screen.dart
│           │        ├─ comments_bottom_sheet.dart
│           │        ├─ create_post_bottom_sheet.dart
│           │        ├─ post_card.dart
│           │        └─ stat_card.dart
│           ├─ home
│           │  ├─ data
│           │  │  ├─ activity_record_repository.dart
│           │  │  ├─ activity_repository.dart
│           │  │  ├─ challenge_repository.dart
│           │  │  ├─ daily_log_repository.dart
│           │  │  ├─ daily_meal_repository.dart
│           │  │  ├─ datasources
│           │  │  │  ├─ activity_record_remote_data_source.dart
│           │  │  │  ├─ activity_remote_data_source.dart
│           │  │  │  ├─ challenge_remote_data_source.dart
│           │  │  │  ├─ daily_log_remote_data_source.dart
│           │  │  │  ├─ daily_meal_remote_data_source.dart
│           │  │  │  ├─ diet_type_remote_data_source.dart
│           │  │  │  ├─ meal_remote_data_source.dart
│           │  │  │  ├─ medal_remote_data_source.dart
│           │  │  │  ├─ user_remote_data_source.dart
│           │  │  │  └─ user_repository_impl.dart
│           │  │  ├─ diet_type_repository.dart
│           │  │  ├─ meal_repository.dart
│           │  │  ├─ medal_repository.dart
│           │  │  └─ user_repository.dart
│           │  ├─ domain
│           │  │  ├─ activity.dart
│           │  │  ├─ challenge.dart
│           │  │  ├─ diet_type.dart
│           │  │  └─ medal.dart
│           │  └─ presentation
│           │     ├─ diet
│           │     │  ├─ create_recipe_screen.dart
│           │     │  ├─ food_search_screen.dart
│           │     │  ├─ meal_analysis_results_screen.dart
│           │     │  ├─ meal_detail_screen.dart
│           │     │  ├─ meal_diary_detail_screen.dart
│           │     │  └─ meal_scan_screen.dart
│           │     ├─ exercise
│           │     │  ├─ activity_analytics_screen.dart
│           │     │  ├─ add_activity_screen.dart
│           │     │  ├─ challenges_screen.dart
│           │     │  ├─ challenge_detail_screen.dart
│           │     │  ├─ log_activity_screen.dart
│           │     │  └─ medals_screen.dart
│           │     ├─ fitness_recommendations_screen.dart
│           │     ├─ home_screen.dart
│           │     ├─ meal_recommendations_input_screen.dart
│           │     ├─ meal_recommendations_results_screen.dart
│           │     ├─ step
│           │     │  └─ steps_screen.dart
│           │     └─ widgets
│           │        ├─ add_action_bottom_list.dart
│           │        ├─ charts
│           │        │  ├─ kcal_circular_progress.dart
│           │        │  ├─ steps_progress.dart
│           │        │  └─ water_intake.dart
│           │        ├─ custom_bottom_nav.dart
│           │        ├─ diet_type_bottom_sheet.dart
│           │        ├─ meal_diary_card.dart
│           │        └─ workout_card.dart
│           ├─ notifications
│           │  ├─ data
│           │  │  ├─ datasources
│           │  │  │  └─ notification_remote_data_source.dart
│           │  │  └─ notification_repository.dart
│           │  └─ presentation
│           │     └─ notifications_screen.dart
│           └─ profile
│              ├─ data
│              │  ├─ datasources
│              │  │  ├─ fitness_profile_remote_data_source.dart
│              │  │  └─ google_fit_remote_data_source.dart
│              │  ├─ fitness_profile_repository.dart
│              │  └─ google_fit_repository.dart
│              ├─ domain
│              │  └─ fitness_goal.dart
│              └─ presentation
│                 ├─ body_fat_calculator_results_screen.dart
│                 ├─ body_fat_calculator_screen.dart
│                 ├─ fitness_profile_screen.dart
│                 ├─ integrations
│                 │  └─ google_fit_sync_screen.dart
│                 ├─ profile_screen.dart
│                 └─ widgets
│                    ├─ profile_header.dart
│                    ├─ profile_item.dart
│                    ├─ profile_section.dart
│                    └─ sections
│                       ├─ account_section.dart
│                       ├─ health_data_section.dart
│                       ├─ preferences_section.dart
│                       └─ support_section.dart
├─ package-lock.json
├─ package.json
├─ pubspec.lock
├─ pubspec.yaml
├─ README.md
├─ test
│  └─ widget_test.dart
└─ web

```
