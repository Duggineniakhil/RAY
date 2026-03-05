# Task 7: CRUD Operations with Firestore & Local DB

## 1. Create (C)
- **Content Creation:** Uploading new videos creates a new document in the `videos` collection with metadata like `creatorId`, `uploadTime`, and initial engagement stats all set to zero.
- **Interactions:** Posting comments to the global `comments` collection. Each comment maps its `videoId` as a foreign key. Following users creates a dual-record (adding to the followers subcollection of the target, and the following subcollection of the user).

## 2. Read (R)
- **Feeds:** Fetching paginated video arrays for the `Home` feed, `Explore` feed (filtered by tags/categories), and `Profile` video grids.
- **Real-time Stats:** Utilizing `ProfileStatsService.syncStats()` on profile load to asynchronously read all instances of a user's videos and dynamically sum their cumulative `likesCount` and `postsCount` directly from the raw data.
- **Comments:** Real-time stream subscription (`snapshots()`) to listen for incoming comments on a specific post.

## 3. Update (U)
- **Like Transactions:** Double-tapping a video executes a `FieldValue.increment(1)` transaction on the video's `likes` field.
- **Profile Configuration:** The `EditProfileDialog` allows users to cleanly update their canonical `displayName`, `bio`, and `profileImage`. These updates are pushed to the main `users` document.

## 4. Delete (D)
- **Unfollowing:** Deleting the matching relational user reference documents from both subcollections simultaneously via a `WriteBatch` to keep counts consistent.
- **Unlike/Content:** Reverting like interactions by submitting negative mathematical increments (`FieldValue.increment(-1)`).

## 5. Local Database Caching
- **Thumbnail Cache Service:** Videos inherently produce heavy network loads. We intercept the network request for thumbnails, mapping the `Video URL` hash to local storage via the `path_provider` and `crypto` libraries. 
- **Execution:** Future thumbnails are resolved entirely from local device disk I/O instead of hitting the internet, saving massive bandwidth and eliminating stutter during fast scrolling.
