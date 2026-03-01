# UCLA Dining Buddy

An iOS app for UCLA students to find dining companions on campus.

## Features

### 1. User Authentication
- UCLA email verification (@ucla.edu)
- User registration with:
  - Username
  - Grade (Freshman, Sophomore, Junior, Senior, Graduate)
  - Gender
  
### 2. Interactive Map View
- Map centered on UCLA campus
- Create dining posts by tapping the "+" button
- View all dining posts as pins on the map
- Tap pins to view post details

### 3. Create Dining Posts
- Restaurant name and address
- Time slots:
  - Breakfast (7AM - 11AM)
  - Lunch (11AM - 3PM)
  - Dinner (5PM - 9PM)
- Add notes (dietary restrictions, preferences, etc.)
- Automatic geocoding to place pins on map
- Restaurant website lookup

### 4. Post Details & Chat
- View full post information
- See poster's profile (username, grade, gender)
- Restaurant website link
- Connect button to start chatting
- Real-time messaging with other students

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0 or later
- Firebase account

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add an iOS app to your project:
   - Bundle ID: `com.yourcompany.HOTH-Project` (or your custom bundle ID)
4. Download the `GoogleService-Info.plist` file
5. Replace the placeholder file at `HOTH Project/GoogleService-Info.plist`

6. Enable the following Firebase services:
   - **Authentication**: Enable Email/Password sign-in
   - **Firestore Database**: Create a database in production mode
   - **Storage**: Enable storage for future media uploads

7. Set up Firestore security rules:

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

### Building the App

1. Open `HOTH Project.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Build and run on your device or simulator

## Project Structure

```
HOTH Project/
├── Models/
│   ├── User.swift              # User data model
│   ├── DiningPost.swift        # Dining post model
│   └── Message.swift           # Message and conversation models
├── ViewModels/
│   ├── AuthViewModel.swift     # Authentication logic
│   ├── MapViewModel.swift      # Map and post management
│   └── ChatViewModel.swift     # Chat functionality
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift     # Login screen
│   │   └── RegistrationView.swift  # Registration screen
│   ├── Map/
│   │   ├── MapView.swift       # Main map interface
│   │   └── CreatePostView.swift    # Create post form
│   ├── Post/
│   │   └── PostDetailView.swift    # Post details
│   └── Chat/
│       └── ChatView.swift      # Chat interface
├── GoogleService-Info.plist    # Firebase configuration
├── Info.plist                  # App permissions
└── HOTH_ProjectApp.swift       # App entry point
```

## Dependencies

The app uses Swift Package Manager for dependencies:
- Firebase iOS SDK (10.20.0+)
  - FirebaseAuth
  - FirebaseFirestore
  - FirebaseStorage

## Future Enhancements

- Push notifications for new messages
- Profile pictures
- Restaurant ratings and reviews
- Group dining options
- In-app restaurant reservations
- Dietary preference filters
- Match suggestions based on interests

## License

This project is created for HOTH (Hack on the Hill) event.
