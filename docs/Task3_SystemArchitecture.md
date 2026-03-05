# Task 3: System Architecture Setup

## 1. Architectural Pattern
The RAY application follows a **Feature-First Clean Architecture**. This approach ensures separation of concerns, massive scalability, and modular independence. Instead of grouping files by type (e.g., all models together), files are grouped by the feature they belong to.

### Directory Structure
```text
lib/
 ├── core/              # Global application definitions
 │   ├── constants/       # App-wide strings, theme constants
 │   ├── errors/          # Custom exception classes
 │   ├── services/       # 3rd party services (DummyData, ThumbnailCache)
 │   └── utils/          # AppRouter configuration, Camera filters
 ├── features/          # Independent application modules
 │   ├── auth/
 │   ├── explore/
 │   ├── profile/
 │   ├── upload_video/
 │   └── video_feed/
 ├── shared/            # Reusable UI components
 └── main.dart          # Entry point
```

## 2. Feature Layer Breakdown
Each feature inside `lib/features/` is split into three core layers:
1. **Data Layer (`/data`):** Contains the Repositories, handling direct backend communication (Firestore, Auth, Cloudinary APIs).
2. **Domain Layer (`/domain`):** Contains the Data Models (e.g., `VideoModel`, `UserModel`) and business logic entities.
3. **Presentation Layer (`/presentation`):** Contains the Screens, UI Widgets, and State Providers binding the UI to the Data layer.

## 3. State Management Configuration
The application exclusively utilizes **Riverpod** (`flutter_riverpod` and `riverpod_annotation`).

- **Providers:** Used to inject global dependencies (e.g., `firebaseAuthProvider`, `firestoreProvider`).
- **StateNotifier / AsyncNotifier:** Used to handle asynchronous UI states (Loading, Success, Error) for network calls. 
- **ConsumerWidget:** Automatically rebuilding isolated UI components when specific data nodes change, ensuring smooth 60 FPS rendering without resorting to monolithic `setState` calls.
