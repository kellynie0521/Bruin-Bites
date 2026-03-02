# 🚀 Bruin Bites Setup & Troubleshooting Guide

## ✅ Quick Start (3 Simple Steps)

### 1. Open the Correct Project File
```bash
cd "/Users/niechuhan/Desktop/HOTH Project"
open "Bruin Bites.xcodeproj"
```

**⚠️ IMPORTANT**: Use `Bruin Bites.xcodeproj`, NOT "HOTH Project.xcodeproj"

Or double-click the script:
```bash
./RUN_PROJECT.sh
```

### 2. Wait for Dependencies to Resolve
- When Xcode opens, it will automatically download Firebase dependencies
- This may take 1-2 minutes on first launch
- You'll see "Resolving Package Dependencies..." in the toolbar
- Wait until it completes before building

### 3. Build and Run
- Select a simulator: Click the device menu at the top (e.g., "iPhone 15 Pro")
- Press `⌘ + R` or click the Play button ▶️
- The app will build and launch!

---

## 📋 System Requirements

- **Xcode**: 15.0 or later
- **iOS Deployment Target**: 16.0 or later
- **macOS**: 13.0+ (for development)
- **Internet Connection**: Required for first-time Firebase SDK download

---

## 🔧 Common Issues & Solutions

### Issue 1: "Project cannot be opened because it is missing its project.pbxproj file"
**Solution**: You're opening the wrong project file.
- ✅ Use: `Bruin Bites.xcodeproj`
- ❌ Don't use: `HOTH Project.xcodeproj` (in root folder)

### Issue 2: Build Fails with "No such module FirebaseAuth"
**Solution**: Dependencies haven't resolved yet.
1. Go to File → Packages → Reset Package Caches
2. Go to File → Packages → Resolve Package Versions
3. Wait for completion (check progress bar at top)
4. Try building again

### Issue 3: App Crashes on Launch
**Solution**: Firebase configuration issue.
1. Check that `GoogleService-Info.plist` exists in `HOTH Project/` folder
2. Verify it contains valid Firebase credentials (PROJECT_ID, API_KEY, etc.)
3. If missing, download from Firebase Console

### Issue 4: Map Shows But No Pins
**Solution**: No dining posts in database yet.
1. Sign up with a test UCLA email
2. Tap the "+" tab to create your first post
3. Fill in restaurant details and tap "Post"
4. Go back to Map tab to see your pin

### Issue 5: Location Permission Denied
**Solution**: 
- On first launch, tap "Allow" when prompted
- If already denied: Settings → Privacy → Location Services → Bruin Bites → "While Using the App"

### Issue 6: "Publishing changes from within view updates" Warning
**Solution**: This is a benign SwiftUI warning and won't affect functionality. The code already uses proper async/await patterns to minimize this.

---

## 🗂️ Project Structure

```
Bruin Bites/
├── Bruin Bites.xcodeproj        ← OPEN THIS FILE
├── HOTH Project/
│   ├── GoogleService-Info.plist  (Firebase config)
│   ├── HOTH_ProjectApp.swift     (App entry point)
│   ├── Models/                   (Data models)
│   ├── ViewModels/               (Business logic)
│   ├── Views/                    (UI screens)
│   ├── Services/                 (API services)
│   ├── Utilities/                (Helpers)
│   └── Assets.xcassets/          (Images, icons)
├── Package.swift                 (Dependencies)
└── README.md
```

---

## 🔑 Firebase Setup (Required for First-Time Setup)

If you're setting up your own Firebase project:

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Name it (e.g., "UCLA Dining Buddy")
4. Follow the wizard (disable Google Analytics if you want)

### 2. Add iOS App
1. In Firebase Console, click iOS+ icon
2. Bundle ID: `com.yourcompany.HOTH-Project`
3. Download `GoogleService-Info.plist`
4. Replace the file in `HOTH Project/` folder

### 3. Enable Firebase Services
- **Authentication**: Enable Email/Password
- **Firestore Database**: Create database (production mode)
- **Storage**: Enable (optional, for profile pictures)

### 4. Set Firestore Security Rules
Copy these rules in Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /diningPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /diningRequests/{requestId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.fromUserId || 
         request.auth.uid == resource.data.toUserId);
      allow create: if request.auth != null && request.auth.uid == request.resource.data.fromUserId;
      allow update: if request.auth != null && request.auth.uid == resource.data.toUserId;
      allow delete: if request.auth != null && 
        (request.auth.uid == resource.data.fromUserId || 
         request.auth.uid == resource.data.toUserId);
    }
    
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
      }
    }
  }
}
```

---

## 🧪 Testing the App

### Test Account Creation
1. Launch app → Welcome screen → "Get Started"
2. Sign Up with email format: `test@ucla.edu` (must end with @ucla.edu)
3. Fill in username, grade, gender
4. Create account

### Test Creating a Post
1. After login, tap "+" tab
2. Start typing a restaurant name (e.g., "Chipotle")
3. Select from autocomplete suggestions
4. Choose a time slot
5. Add optional notes
6. Tap "Post"

### Test Dining Requests
1. From Map view, tap a pin
2. View post details
3. Tap "Send Dining Request"
4. The post owner will see the request in Messages tab
5. They can Accept or Decline

### Test Messaging
1. After a request is accepted, both users get a chat
2. Go to Messages tab → Chats
3. Tap the conversation
4. Send messages in real-time

---

## 🎨 Features Overview

### ✅ Already Implemented
- User authentication with UCLA email verification
- Interactive map with restaurant pins
- Create dining posts with restaurant search
- Dining request system (send/accept/decline)
- Real-time messaging
- Profile management with avatars
- Location services and distance calculation
- UCLA-themed UI design

### 🚧 Known Limitations
- Restaurant search requires internet connection
- Simulator location may not be accurate (use custom location)
- Black borders on some iPhone 16/17 models (cosmetic only)

---

## 📞 Support

If you encounter issues:
1. Check this troubleshooting guide first
2. Try cleaning the build: `⌘ + Shift + K`
3. Try deleting derived data: Xcode → Preferences → Locations → Derived Data → Delete
4. Restart Xcode

---

## 🎉 You're Ready!

Run the script or open `Bruin Bites.xcodeproj` in Xcode and start building!

```bash
./RUN_PROJECT.sh
```

Happy coding! 🐻💙💛
