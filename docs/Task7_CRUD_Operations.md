# Task 7: CRUD Operations & Data Sync

## ⚡ 1. The CRUD Ecosystem

RAY utilizes Cloud Firestore's real-time capabilities to provide an "Always-Synced" experience.

| Op | Action | Technical Implementation |
| :--- | :--- | :--- |
| **C** | **Post Content** | Firestore `doc().set()` with `uploadTime` and Cloudinary URL references. |
| **R** | **Live Feeds** | `Query.snapshots()` for comments; `get()` with pagination for the video feed. |
| **U** | **Engagement** | Atomic `FieldValue.increment(1)` for likes and share counts. |
| **D** | **Social Link** | WriteBatch `delete()` for removing follower/following relationship records. |

---

## 🔄 2. Real-time Statistical Synchronization
To avoid stale data, the app implements a **Dynamic Metric Sync** logic.

- **Trigger**: Every profile load initiates `ProfileStatsService.syncStats()`.
- **Logic**: The service queries the `videos` collection for the user's ID, sums the cumulative likes and post counts in real-time, and refreshes the user's master document. 
- **Result**: Users see perfectly accurate counts even if a backend sync function has a delay.

---

## 💾 3. Performance Caching
To minimize bandwidth and improve "Time to First Play":

1.  **Thumbnail Caching**: A local service intercepts network requests, hashes the URL, and stores the image bytes in the device's temporal cache using `path_provider`.
2.  **Persistence**: High-frequency data (like auth tokens) are cached via `shared_preferences` for instantaneous app launches.
