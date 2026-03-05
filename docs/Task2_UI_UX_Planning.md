# Task 2: UI/UX Planning – Wireframes & Navigation Flow

## 1. Design Philosophy
The user interface revolves around immersive, edge-to-edge media consumption. The app employs a dark-mode-first aesthetic with dynamic overlays, ensuring the video content remains the central focus. 

## 2. Core Navigation Flow
The application uses a persistent Bottom Navigation Bar controlling the primary routes. Global routing and deep-linking are managed by the `go_router` package for robust state preservation.

### Route Hierarchy
- `/splash` -> Application initialization and auth check.
- `/login` & `/signup` -> Authentication flow.
- `/home` (Bottom Navigation Shell)
  - `/home/feed` -> The primary vertical scrolling video player.
  - `/home/explore` -> Search and trending content grid.
  - `/home/upload` -> Video/Image picker and camera module.
  - `/home/profile` -> Current user's profile and analytics.

## 3. Screen Breakdowns

### Video Feed Screen
- **Background:** Full-screen `VideoPlayer` widget.
- **Right Overlay:** Floating interaction column (Profile Avatar, Like, Comment, Share).
- **Bottom Overlay:** Video caption, hashtags, and scrolling music track marquee.
- **Gestures:** Vertical drag to paginate, single-tap to play/pause, double-tap to trigger a Lottie heart animation.

### Camera & Media Editor Screen
- **Camera Screen:** Full-screen camera preview utilizing `camera` package. Includes torch toggle, flip camera, and filter scrolling wheel.
- **Editor Screen:** Video timeline trimmer using `video_trimmer`, playback preview, and final confirmation before uploading to the BaaS (Cloudinary).

### Profile Screen
- **Header:** Circular user avatar, Username, Bio, and localized follower/following statistics.
- **Body:** Tabular views switching between a grid of `Uploaded` videos and `Liked` videos. 

## 4. Micro-Animations & Interactivity
- Utilizing `flutter_animate` for staggered fade-ins on grids.
- Lottie animations for empty states, successful uploads, and the double-tap to like functionality.
- Custom slide-up and slide-right page transitions via `CustomTransitionPage`.
