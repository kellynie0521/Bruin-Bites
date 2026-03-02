# Firebase Setup Guide

This guide explains how to configure your own Firebase project for Bruin Bites.

> **Note**: The project already includes a Firebase configuration. You only need to follow this guide if you want to set up your own Firebase instance.

---

## 📋 Prerequisites

- Google account
- Internet connection
- Bruin Bites project downloaded

---

## 🔥 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `UCLA Dining Buddy` (or your choice)
4. Click **Continue**
5. (Optional) Disable Google Analytics if you don't need it
6. Click **Create project**
7. Wait for project creation to complete
8. Click **Continue**

---

## 📱 Step 2: Add iOS App to Firebase

1. In your Firebase project dashboard, click the **iOS+** icon
2. Fill in the registration form:
   - **iOS bundle ID**: `com.yourcompany.HOTH-Project`  
     (or your custom bundle ID - must match Xcode project)
   - **App nickname**: `Bruin Bites` (optional)
   - **App Store ID**: Leave blank (optional)
3. Click **Register app**

---

## 📥 Step 3: Download Configuration File

1. Click **Download GoogleService-Info.plist**
2. Save the file to your Desktop
3. Move it to your project:
   ```bash
   mv ~/Desktop/GoogleService-Info.plist "/Users/niechuhan/Desktop/HOTH Project/HOTH Project/"
   ```
4. **⚠️ IMPORTANT**: This file contains sensitive keys. Never commit it to public repositories!
5. Click **Next** and then **Continue to console**

---

## 🔐 Step 4: Enable Authentication

1. In Firebase Console sidebar, click **Build** → **Authentication**
2. Click **Get started**
3. Click **Sign-in method** tab
4. Click **Email/Password**
5. Toggle **Enable** ON
6. Click **Save**

### Why Email/Password?
- Bruin Bites validates `@ucla.edu` email addresses
- Simple user registration flow
- No external auth provider needed

---

## 🗄️ Step 5: Create Firestore Database

1. In Firebase Console sidebar, click **Build** → **Firestore Database**
2. Click **Create database**
3. Choose **Start in production mode** (we'll add security rules next)
4. Select a Cloud Firestore location:
   - Choose `us-west2` (Los Angeles) for lowest latency at UCLA
   - Or `us-central1` (Iowa) for free tier
5. Click **Enable**
6. Wait for database creation (may take 1-2 minutes)

---

## 🔒 Step 6: Configure Security Rules

1. In Firestore Database, click **Rules** tab
2. Replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles - readable by all authenticated users, writable by owner
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Dining posts - readable by all authenticated users, writable by creator
    match /diningPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Dining requests - readable by sender and receiver
    match /diningRequests/{requestId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.fromUserId || 
         request.auth.uid == resource.data.toUserId);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.fromUserId;
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.toUserId;
      allow delete: if request.auth != null && 
        (request.auth.uid == resource.data.fromUserId || 
         request.auth.uid == resource.data.toUserId);
    }
    
    // Conversations - readable/writable by participants only
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      // Messages subcollection - accessible by conversation participants
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
      }
    }
  }
}
```

3. Click **Publish**
4. Confirm by clicking **Publish** again

### What These Rules Do:
- ✅ Users can only edit their own profiles
- ✅ Anyone can view dining posts (but only owners can delete)
- ✅ Dining requests are private between sender and receiver
- ✅ Conversations are only visible to participants
- ❌ Unauthenticated users cannot access any data

---

## 📦 Step 7: Enable Storage (Optional)

> This is optional - only needed if you want users to upload profile pictures

1. In Firebase Console sidebar, click **Build** → **Storage**
2. Click **Get started**
3. Use default security rules (or customize)
4. Choose same location as Firestore
5. Click **Done**

---

## 🔍 Step 8: Create Required Indexes (If Needed)

When you first use the app, Firestore may show an error about missing indexes. This is normal!

**To fix:**
1. Look for the error message in Xcode console
2. It will include a link like:
   ```
   https://console.firebase.google.com/v1/r/project/ucla-dining-buddy/firestore/indexes?create_composite=...
   ```
3. Click the link (it opens Firebase Console)
4. Click **Create Index**
5. Wait for index to build (1-2 minutes)

**Common indexes needed:**
- `conversations` collection: `participants` (array) + `lastMessageTimestamp` (desc)
- `diningRequests` collection: `toUserId` + `createdAt` (desc)

---

## ✅ Step 9: Verify Configuration

1. Open Xcode: `open "Bruin Bites.xcodeproj"`
2. Build and run the app (`⌘ + R`)
3. Try creating a test account with `test@ucla.edu`
4. If successful, you'll see:
   ```
   ✅ User created: [some-user-id]
   ✅ User data saved to Firestore
   ```

---

## 🎯 Data Structure Overview

Your Firestore will have these collections:

### `/users/{userId}`
```json
{
  "id": "abc123...",
  "email": "test@ucla.edu",
  "username": "JohnDoe",
  "grade": "Junior",
  "gender": "Male",
  "createdAt": "2026-03-01T10:00:00Z"
}
```

### `/diningPosts/{postId}`
```json
{
  "id": "post123...",
  "userId": "abc123...",
  "username": "JohnDoe",
  "restaurantName": "Chipotle",
  "address": "1234 Westwood Blvd",
  "timeSlot": "Lunch",
  "latitude": 34.0689,
  "longitude": -118.4452,
  "notes": "Looking for someone to grab lunch!",
  "createdAt": "2026-03-01T11:00:00Z"
}
```

### `/diningRequests/{requestId}`
```json
{
  "id": "req123...",
  "postId": "post123...",
  "fromUserId": "xyz789...",
  "toUserId": "abc123...",
  "requestStatus": "pending",
  "createdAt": "2026-03-01T11:30:00Z"
}
```

### `/conversations/{conversationId}`
```json
{
  "id": "conv123...",
  "participants": ["abc123...", "xyz789..."],
  "participantNames": ["JohnDoe", "JaneSmith"],
  "lastMessage": "See you at 12!",
  "lastMessageTimestamp": "2026-03-01T11:45:00Z",
  "createdAt": "2026-03-01T11:35:00Z"
}
```

### `/conversations/{conversationId}/messages/{messageId}`
```json
{
  "id": "msg123...",
  "senderId": "abc123...",
  "senderName": "JohnDoe",
  "text": "See you at 12!",
  "timestamp": "2026-03-01T11:45:00Z"
}
```

---

## 🔐 Security Best Practices

1. **Never commit `GoogleService-Info.plist` to public repos**
   - Add it to `.gitignore`
   - Share it securely with team members

2. **Enable App Check** (optional but recommended for production):
   - Firebase Console → Build → App Check
   - Protects against abuse and unauthorized access

3. **Monitor Usage**:
   - Firebase Console → Usage and billing
   - Set up budget alerts to avoid surprises

4. **Test Security Rules**:
   - Firebase Console → Firestore → Rules → Rules Playground
   - Test different scenarios before deploying

---

## 💰 Firebase Free Tier Limits

The free "Spark" plan includes:
- ✅ **Firestore**: 1 GB storage, 50K reads/day, 20K writes/day
- ✅ **Authentication**: Unlimited users
- ✅ **Storage**: 5 GB
- ✅ **Hosting**: 10 GB/month

This is more than enough for testing and small-scale usage!

---

## 🆘 Troubleshooting

### Issue: "Failed to configure Firebase"
- Check `GoogleService-Info.plist` is in correct folder
- Verify bundle ID matches between Xcode and Firebase

### Issue: "Permission denied" errors
- Check Firestore security rules are published
- Verify user is authenticated before accessing data

### Issue: "Index required" error
- Click the link in error message to create index
- Wait for index to build (1-2 minutes)

### Issue: App crashes on launch
- Check Xcode console for detailed error
- Verify all Firebase services are enabled
- Try cleaning build folder (`⌘ + Shift + K`)

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase iOS SDK GitHub](https://github.com/firebase/firebase-ios-sdk)

---

## ✅ You're Done!

Your Firebase backend is now fully configured for Bruin Bites! 🎉

Go back to [README.md](README.md) to start building the app.
