# 🎯 Bruin Bites - Quick Reference

## 🚀 To Run the App

```bash
# Method 1: Double-click in Finder
# Open: Bruin Bites.xcodeproj

# Method 2: Terminal
open "Bruin Bites.xcodeproj"

# Method 3: Helper script
./RUN_PROJECT.sh
```

## ✅ Validation

```bash
./validate.sh
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `Bruin Bites.xcodeproj` | **Main project file - OPEN THIS** |
| `HOTH Project/` | Source code folder |
| `GoogleService-Info.plist` | Firebase credentials (in HOTH Project/) |
| `README.md` | Project overview |
| `SETUP_GUIDE.md` | Detailed setup & troubleshooting |
| `FIREBASE_SETUP.md` | Firebase configuration guide |

## 🏗️ Project Structure

```
HOTH Project/
├── HOTH_ProjectApp.swift        ← App entry point
├── Models/                      ← Data structures
│   ├── User.swift
│   ├── DiningPost.swift
│   ├── DiningRequest.swift
│   ├── Conversation.swift
│   └── Message.swift
├── ViewModels/                  ← Business logic
│   ├── AuthViewModel.swift
│   ├── MapViewModel.swift
│   ├── RequestViewModel.swift
│   └── ChatViewModel.swift
├── Views/                       ← UI screens
│   ├── Auth/                    (Login, Registration, Welcome)
│   ├── Map/                     (Create post)
│   ├── Post/                    (Post details)
│   ├── Inbox/                   (Requests & messages)
│   ├── Chat/                    (Messaging)
│   ├── Profile/                 (User profiles)
│   └── MainTabView.swift        (Main navigation)
├── Services/                    ← External APIs
│   └── RestaurantSearchService.swift
├── Utilities/                   ← Helpers
│   ├── ColorTheme.swift
│   └── ImagePicker.swift
└── Assets.xcassets/            ← Images & icons
```

## 🎨 Key Features

### 1. Authentication
- UCLA email verification (`@ucla.edu` required)
- User profiles with grade and gender

### 2. Map View
- Interactive UCLA campus map
- Restaurant pins with distance
- Tap pins to see post details

### 3. Create Posts
- Restaurant autocomplete search
- Time slot selection (Breakfast, Lunch, Dinner, Late Night)
- Optional notes

### 4. Dining Requests
- Send requests to post owners
- Accept/decline requests
- Automatic chat creation on acceptance

### 5. Messaging
- Real-time chat with matched users
- Message Center with tabs:
  - Received Requests
  - Sent Requests
  - Chats
- Unread badges

### 6. Profile
- Custom avatar based on initials
- Transportation preferences
- View other users' profiles

## 🔧 Common Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build & Run | `⌘ + R` |
| Stop | `⌘ + .` |
| Clean Build | `⌘ + Shift + K` |
| Build | `⌘ + B` |
| Quick Open | `⌘ + Shift + O` |
| Find in Project | `⌘ + Shift + F` |
| Show Preview | `⌥ + ⌘ + ↩` |

## 🐛 Quick Fixes

### Build fails with "No such module Firebase..."
```bash
# In Xcode menu:
File → Packages → Reset Package Caches
File → Packages → Resolve Package Versions
```

### App crashes on launch
1. Check console for error message
2. Verify `GoogleService-Info.plist` exists
3. Clean build: `⌘ + Shift + K`

### No pins on map
- Create a post first (tap + tab)
- Check Firestore in Firebase Console for data

### Location not working
- Allow location permission when prompted
- Check: Settings → Privacy → Location → Bruin Bites

## 📊 Firebase Collections

| Collection | Documents | Purpose |
|------------|-----------|---------|
| `/users` | User profiles | Store user data |
| `/diningPosts` | Dining posts | Restaurant posts on map |
| `/diningRequests` | Requests | Dining requests between users |
| `/conversations` | Chats | Chat metadata |
| `/conversations/{id}/messages` | Messages | Individual messages |

## 🧪 Test Flow

1. **Sign Up**: Use `test@ucla.edu` format
2. **Create Post**: Search "Chipotle", select time
3. **View on Map**: See your pin appear
4. **Send Request**: Tap another pin, send request
5. **Accept**: Other user accepts in Messages tab
6. **Chat**: Message in Chats tab

## 🌈 UCLA Color Scheme

```swift
Color.uclaBlue          // #5389C3
Color.uclaDarkBlue      // #003B70
Color.uclaGold          // #FFD86C
Color.uclaLightBlue     // #84BFEF
Color.uclaLightGold     // #FFEBAD
```

## 📞 Need Help?

1. Check `SETUP_GUIDE.md` for detailed troubleshooting
2. Review `FIREBASE_SETUP.md` for Firebase issues
3. Check Xcode console for error messages
4. Clean and rebuild the project

---

**Made with 💙💛 at UCLA**
