# RAY 📱

An AI-powered Short Video Viewer App inspired by TikTok, built with Flutter and Firebase.

## Features ✨

* **Immersive Video Feed**: Infinite scrolling vertical video feed.
* **Authentication**: Seamless login and signup using Firebase Auth.
* **Discover & Explore**: Find new content, trending videos, and creators.
* **Interactive UI**: Double-tap to like, comment section, share functionality, and smooth animations.
* **AI Voice Assistant**: Voice commands and text-to-speech features.
* **Media Upload**: Create and upload your own short videos, utilizing Cloudinary for media management.
* **QR Scanner**: Built-in QR code scanner for quick profile sharing.
* **Offline Caching**: Optimized media loading and caching for a smoother experience.

## Tech Stack 🛠️

* **Framework**: [Flutter](https://flutter.dev/)
* **Backend (BaaS)**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage, Messaging)
* **State Management**: [Riverpod](https://riverpod.dev/) 
* **Routing**: [go_router](https://pub.dev/packages/go_router)
* **Video Playback**: [video_player](https://pub.dev/packages/video_player) & [chewie](https://pub.dev/packages/chewie)
* **Media**: [Cloudinary](https://cloudinary.com/)
* **Local Storage**: Sqflite & Shared Preferences

## Getting Started 🚀

### Prerequisites

* Flutter SDK (>=3.0.0 <4.0.0)
* A Firebase Project configured for Android/iOS.

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd ray
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Code Generation**
   Generate Riverpod/Freezed/Mocks files:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Firebase Configuration**
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`
   - Use FlutterFire CLI to generate `lib/firebase_options.dart`.

5. **Run the App**
   ```bash
   flutter run
   ```

## Architecture 🏛️

Follows a feature-first architecture approach:
* `lib/features/`: Contains distinct features (`auth`, `video_feed`, `explore`, etc.)
* `lib/core/`: Application-wide services, themes, and configuration.
* `lib/shared/`: Shared UI components and utility classes.

## License 📄

This project is licensed under the MIT License.
