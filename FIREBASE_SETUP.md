# Firebase Configuration Required

This project requires Firebase configuration to run. 

## Setup Instructions

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add an iOS app to your project
4. Download the `GoogleService-Info.plist` file
5. Add it to the `HOTH Project/` directory (same level as `Info.plist`)
6. Do NOT commit this file to version control

## Firebase Services Required

- **Authentication**: Enable Email/Password sign-in
- **Firestore Database**: Create a database
- **Storage**: Enable for profile pictures (optional)

## Firestore Security Rules

See README.md for the complete security rules configuration.
