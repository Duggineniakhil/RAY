# Task 4: Database Schema & ER Diagram

## 1. Environment
**Database:** Firebase Cloud Firestore (NoSQL)
**File Storage:** Firebase Storage (Avatars) & Cloudinary (Optimized Video streaming)

## 2. Entity Relationship & Collections

The data model utilizes top-level collections optimized for rapid reading and pagination. Denormalization is applied where necessary for performance (e.g., caching counts).

### A. `users` Collection
Stores authentication profiles and social metadata.
```json
{
  "id": "String (Document ID / UID)",
  "username": "String",
  "displayName": "String",
  "email": "String",
  "bio": "String",
  "profileImage": "String (URL)",
  "followersCount": "Integer",
  "followingCount": "Integer",
  "likesCount": "Integer",
  "postsCount": "Integer",
  "isPrivate": "Boolean",
  "createdAt": "Timestamp"
}
```
**Subcollections inside `users/{userId}`:**
- `followers/`: Tracks reference documents of users following this account.
- `following/`: Tracks reference documents of users this account follows.

### B. `videos` Collection
Stores detailed metadata and media references for the main feed.
```json
{
  "id": "String (Document ID)",
  "creatorId": "String (Foreign Key -> users.id)",
  "creatorName": "String (Denormalized)",
  "creatorAvatar": "String (Denormalized)",
  "videoUrl": "String (Cloudinary URL)",
  "thumbnail": "String (URL)",
  "caption": "String",
  "hashtags": "Array of Strings",
  "category": "String",
  "likes": "Integer",
  "commentsCount": "Integer",
  "shares": "Integer",
  "filterIndex": "Integer",
  "uploadTime": "Timestamp"
}
```

### C. `comments` Collection
A global collection for retrieving paginated text discussions tied to a specific video entity.
```json
{
  "id": "String (Document ID)",
  "videoId": "String (Foreign Key -> videos.id)",
  "userId": "String",
  "userName": "String",
  "userAvatar": "String",
  "text": "String",
  "likes": "Integer",
  "timestamp": "Timestamp"
}
```

## 3. Schema Design Rationale
- **Denormalization:** `creatorName` and `creatorAvatar` are duplicated into the `videos` collection to prevent executing secondary Firestore read requests when rendering the high-velocity video feed.
- **Top-Level Grouping:** Comments are stored in a root-level collection mapped by `videoId` instead of sub-collections to facilitate easier global moderation queries if needed.
