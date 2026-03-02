# Bruin Bites 🐻

**Find your perfect dining companion at UCLA**

Bruin Bites connects UCLA students who want to eat together. Post your dining plans on our map, find others heading to the same restaurant, send a dining request, chat, and meet up. Never eat alone again!

![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue)
![Language](https://img.shields.io/badge/Swift-5.9-orange)
![Firebase](https://img.shields.io/badge/Firebase-10.20%2B-yellow)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 1. User Authentication
- UCLA email verification (@ucla.edu)
- Beautiful gradient login interface with UCLA colors
- User registration with:
  - Username
  - Grade (Freshman, Sophomore, Junior, Senior, Graduate)
  - Gender
  
### 2. Interactive Map View
- Map centered on UCLA campus
- **Zoom in/out with pinch gestures**
- **Pan to explore different areas**
- Create dining posts by tapping the blue "+" button
- View all dining posts as pins on the map
- Tap pins to view post details

### 3. Create Dining Posts with Smart Search
- **🆕 Restaurant autocomplete** - Start typing and see suggestions
- **🆕 Automatic address lookup** - Select from restaurant suggestions
- Manual address entry if needed
- Enhanced time slots:
  - Breakfast (7AM - 11AM)
  - Lunch (11AM - 3PM)
  - Dinner (5PM - 9PM)
  - **🆕 Late Night Snack (9PM - 2AM)**
- Add notes (dietary restrictions, preferences, etc.)
- Automatic geocoding to place pins on map
- Restaurant website lookup

### 4. Dining Request System
- **Send dining requests** to post owners
- **Accept or decline** incoming requests
- View all sent and received requests in Message Center
- Automatic chat creation upon request acceptance
- Real-time messaging with matched students

### 5. Message Center
- **Three tabs**: Received Requests, Sent Requests, Chats
- **Unread indicators** with red dot badges
- See conversation previews and last messages
- One-tap access to active chats

### 5. Profile & Transportation
- **Initial-based avatars** with consistent colors
- User profile with grade and gender info
- **Transportation preferences**: Car, Rideshare, Public Transit, Walking, or custom option
- Profile pictures support (optional)

### 6. Location Services
- **One-time location permission** on first launch
- Display distance from user to each restaurant
- Real-time location updates on map
- Privacy-focused location handling

### 7. 🎨 UCLA-Themed Design
- Beautiful UCLA blue and gold color scheme
- **Welcome screen** with app branding on first launch
- Gradient backgrounds throughout
- Modern card-based interfaces
- Smooth animations and shadows
- Consistent Roboto font family
- Unread message badges and indicators

## 🎨 UCLA Color Palette

- **UCLA Blue**: #5389C3 (Primary actions, icons)
- **UCLA Dark Blue**: #003B70 (Text, emphasis)
- **UCLA Gold**: #FFD86C (Accents, highlights)
- **UCLA Light Blue**: #84BFEF (Backgrounds, gradients)
- **UCLA Light Gold**: #FFEBAD (Secondary backgrounds)

## 📱 Screenshots

*Coming soon - Add your app screenshots here!*

## 🚀 Quick Start

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0 or later
- macOS 13.0+ (for development)
- Firebase account (free tier works fine)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/kellynie0521/Bruin-Bites.git
   cd Bruin-Bites
   ```

2. **Set up Firebase**
   - Follow instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to `HOTH Project/` directory (do NOT commit this file)

3. **Open in Xcode**
   ```bash
   open "HOTH Project.xcodeproj"
   ```

4. **Configure signing**
   - Select your development team in Xcode project settings
   - Update Bundle Identifier if needed

5. **Build and Run**
   - Select a simulator or connected device
   - Press ⌘+R to build and run

## 🔧 Firebase Configuration

### Required Firebase Services

1. **Authentication**
   - Enable Email/Password sign-in method
   - UCLA email domain (@ucla.edu) is validated in the app

2. **Firestore Database**
   - Create a database in production mode
   - Deploy the security rules (see below)
   - Create a composite index for conversations (link provided in console error if needed)

3. **Storage** (Optional)
   - Enable if you want to support profile picture uploads
   - Configure storage security rules

### Firestore Security Rules

Copy these rules to your Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Dining posts
    match /diningPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Dining requests
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
    
    // Conversations and messages
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

## 📁 Project Structure

```
Bruin-Bites/
├── HOTH Project/
│   ├── Models/
│   │   ├── User.swift              # User profile model
│   │   ├── DiningPost.swift        # Dining post with location
│   │   ├── DiningRequest.swift     # Request system model
│   │   ├── Conversation.swift      # Chat conversation model
│   │   └── Message.swift           # Individual message model
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift     # Authentication & user management
│   │   ├── MapViewModel.swift      # Map, posts, and location services
│   │   ├── RequestViewModel.swift  # Dining request management
│   │   └── ChatViewModel.swift     # Real-time messaging
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── WelcomeView.swift       # First-launch welcome screen
│   │   │   ├── LoginView.swift         # Login interface
│   │   │   └── RegistrationView.swift  # Sign-up form
│   │   ├── Map/
│   │   │   └── CreatePostView.swift    # Create dining post form
│   │   ├── Post/
│   │   │   └── PostDetailView.swift    # Post details with request button
│   │   ├── Profile/
│   │   │   ├── ProfileView.swift           # User's own profile
│   │   │   ├── UserProfileView.swift       # Other users' profiles
│   │   │   └── InitialAvatarView.swift     # Avatar generation
│   │   ├── Inbox/
│   │   │   └── InboxView.swift         # Message Center with 3 tabs
│   │   ├── Chat/
│   │   │   └── ChatView.swift          # Real-time chat interface
│   │   ├── MainTabView.swift           # Main app navigation
│   │   └── LocationPermissionView.swift # Location permission UI
│   ├── Services/
│   │   └── RestaurantSearchService.swift # MapKit local search
│   ├── Utilities/
│   │   ├── ColorTheme.swift            # UCLA color extensions
│   │   └── ImagePicker.swift           # Photo picker wrapper
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/         # App icon
│   │   └── AppCover.imageset/          # Welcome screen image
│   ├── Info.plist                      # App configuration
│   ├── GoogleService-Info.plist        # Firebase config (not in repo)
│   └── HOTH_ProjectApp.swift           # App entry point
├── FIREBASE_SETUP.md                   # Firebase setup guide
├── README.md                           # This file
└── LICENSE                             # MIT License
```

## 🛠 Technologies Used

### iOS Development
- **Swift 5.9** - Modern, safe programming language
- **SwiftUI** - Declarative UI framework
- **MapKit** - Maps, geocoding, and local search
- **Core Location** - User location services

### Backend & Services
- **Firebase Authentication** - User sign-in and email verification
- **Cloud Firestore** - Real-time NoSQL database
- **Firebase Storage** - (Optional) Image storage

### Architecture & Patterns
- **MVVM (Model-View-ViewModel)** - Clean separation of concerns
- **Async/await** - Modern Swift concurrency
- **Combine** - Reactive programming with `@Published` properties
- **ObservableObject** - SwiftUI state management

### Tools & Package Management
- **Swift Package Manager** - Dependency management
- **Xcode 15+** - IDE and build system
- **Git** - Version control

## 🎓 Learning Outcomes

Building Bruin Bites taught us:
- Real-time database synchronization with Firestore
- iOS location services and permission handling
- Complex SwiftUI navigation patterns (sheets, fullScreenCover, NavigationStack)
- State management in a multi-view app
- MapKit integration and custom annotations
- Firebase security rules and data modeling
- UCLA-themed UI/UX design principles
- Chat system architecture

## 🐛 Known Issues

- Black borders may appear on some iPhone models (16/17) - related to launch screen configuration
- Location services work best on physical devices (simulator has limitations)
- Restaurant search requires active internet connection

## 🔒 Security & Privacy

- User authentication required for all features
- Firestore security rules enforce data access control
- Location data is only used for distance calculations
- No user data is sold or shared with third parties
- UCLA email verification ensures student-only access

## 📦 Dependencies

This project uses Swift Package Manager. Dependencies are automatically resolved when you open the project.

- **Firebase iOS SDK** (10.20.0+)
  - `FirebaseAuth` - User authentication
  - `FirebaseFirestore` - Real-time database
  - `FirebaseStorage` - File storage (optional)

No manual installation required - Xcode handles it automatically!

## 🤝 Contributing

This is a student project created for HOTH (Hack on the Hill). While it's primarily for educational purposes, we welcome:

- Bug reports and feature suggestions (open an issue)
- Code improvements (submit a pull request)
- Documentation enhancements
- UI/UX feedback

## 📝 Future Enhancements

Potential features for future development:

- [ ] Push notifications for new messages and requests
- [ ] Advanced profile customization with profile pictures
- [ ] Restaurant ratings and reviews system
- [ ] Group dining options (3+ people)
- [ ] In-app restaurant reservations
- [ ] Dietary preference filters and matching
- [ ] AI-powered dining companion suggestions
- [ ] Integration with UCLA dining halls
- [ ] Event-based dining (study sessions, group projects)
- [ ] Friend/favorites system

## 👥 Authors

Created with ❤️ by UCLA students for the HOTH hackathon

- **GitHub**: [@kellynie0521](https://github.com/kellynie0521)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- UCLA community for inspiration
- HOTH organizers for the opportunity
- Firebase for backend infrastructure
- Apple for SwiftUI and MapKit frameworks

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/kellynie0521/Bruin-Bites/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kellynie0521/Bruin-Bites/discussions)

---

Made with 🐻 at UCLA | HOTH 2026
