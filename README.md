# 📱 WhatsApp Clone - Flutter

<div align="center">
  <img src="assets/whats_app_logo.png" alt="WhatsApp Clone Logo" width="120" height="120">
  
  <h3>A fully functional WhatsApp clone built with Flutter & Firebase</h3>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.5.4-blue.svg)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
  [![Express.js](https://img.shields.io/badge/Express.js-File%20Upload-green.svg)](https://expressjs.com/)
  [![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
</div>

---

## 🌟 Features

### 📞 **Authentication & User Management**
- 📱 Phone number authentication with OTP verification
- 👤 User profile creation and management
- 🖼️ File and picture upload with Express.js backend
- 📞 Country code picker integration
- 🔐 Secure Firebase Authentication

### 💬 **Real-time Messaging**
- ⚡ Real-time message sending and receiving
- ✅ Message delivery status (sent, delivered, read)
- 📝 Text messages with emoji support
- 🎭 Emoji picker with GIF support
- 📎 File attachments (images, videos, documents, audio)
- 🔄 Message reply functionality
- 🗑️ Message deletion
- 📱 Swipe-to-reply gesture

### 👥 **Contacts & Chat Management**
- 📋 Device contacts integration
- 👥 User discovery and contact management
- 💬 Chat list with recent messages
- 🔍 Search functionality
- 📂 Chat archiving
- 🔔 Unread message indicators
- 📊 Chat filtering (All, Unread, Favorites, Groups)

### 📸 **Status & Media**
- 📷 Status updates with images/videos
- ⏰ 24-hour status expiry
- 👀 Status view tracking
- 🎵 Audio message recording and playback
- 🖼️ Advanced image picker with multi-selection
- 📹 Video player integration
- 🎨 Custom UI with Material Design

### 🎨 **User Interface**
- 🌙 Modern WhatsApp-inspired design
- 📱 Responsive layout for all screen sizes
- ✨ Smooth animations and transitions
- 🎭 Custom clippers and widgets
- 📊 Shimmer loading effects
- 🎨 Custom themes and styling
- 📱 Platform-specific adaptations

### ☁️ **Backend & Storage**
- 🔥 Firebase Firestore for real-time database
- 🚀 Express.js server for file uploads
- ☁️ Cloudinary integration for media storage
- 🔄 Real-time synchronization
- 📊 Efficient data caching

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **BLoC** state management:

```
lib/
├── features/
│   ├── app/                 # App-wide configurations
│   ├── user/               # User management & authentication
│   ├── chat/               # Messaging functionality
│   ├── status/             # Status updates
│   └── call/               # Call features (future)
├── storage/                # File upload providers
├── routes/                 # Navigation management
└── main.dart              # App entry point
```

### 🧱 **Architecture Layers:**
- **Presentation Layer**: BLoC/Cubit + UI Widgets
- **Domain Layer**: Use Cases + Entities + Repositories (Abstract)
- **Data Layer**: Repository Implementations + Data Sources + Models

---

## 🚀 Getting Started

### 📋 Prerequisites

- Flutter SDK (3.5.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Node.js (for Express.js server)

### 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/whatsapp_clone.git
   cd whatsapp_clone
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Phone)
   - Enable Firestore Database
   - Enable Firebase Storage
   - Download `google-services.json` and place in `android/app/`
   - Update `firebase_options.dart` with your config

4. **Express.js Server Setup**
   ```bash
   # Navigate to your Express.js server directory
   npm install
   npm start
   ```
   
   Update the base URL in `lib/storage/express_storage_provider.dart`:
   ```dart
   static const String _baseUrl = 'YOUR_EXPRESS_SERVER_URL';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

### 🔥 **Core Dependencies**
```yaml
# State Management
flutter_bloc: ^9.1.1
equatable: ^2.0.7
get_it: ^8.0.3

# Firebase
firebase_core: ^3.14.0
firebase_auth: ^5.6.0
cloud_firestore: ^5.6.9
firebase_storage: ^12.4.7

# UI & Media
image_picker: ^1.1.2
video_player: ^2.9.5
cached_network_image: ^3.4.1
emoji_picker_flutter: ^4.3.0
photo_manager: ^3.7.1
shimmer: ^3.0.0

# Utilities
intl: ^0.19.0
uuid: ^4.5.1
http: ^1.4.0
shared_preferences: ^2.5.3
```

---

## 📱 Screenshots

<div align="center">
  <img src="screenshots/auth.png" alt="Authentication" width="200">
  <img src="screenshots/chat_list.png" alt="Chat List" width="200">
  <img src="screenshots/chat.png" alt="Chat Screen" width="200">
  <img src="screenshots/status.png" alt="Status" width="200">
</div>

---

## 🔥 Firebase Configuration

### 📊 **Firestore Structure**
```
users/
├── {userId}/
│   ├── uid: string
│   ├── username: string
│   ├── email: string
│   ├── phoneNumber: string
│   ├── profileUrl: string
│   ├── status: string
│   ├── isOnline: boolean
│   └── myChat/
│       └── {chatId}/
│           ├── messages/
│           └── chatInfo
```

<!-- ### 🔐 **Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
} -->
```

---

## 🌐 Express.js Server Integration

The app uses a custom Express.js server for file uploads with the following endpoints:

- `POST /files/upload` - Upload files (images, videos, documents)
- `GET /files/:fileId` - Get file information
- `DELETE /files/:fileId` - Delete files

### 🔧 **Server Features:**
- 📁 Cloudinary integration for media storage
- 🔒 File validation and security
- 📊 Upload progress tracking
- 🔄 Real-time file status updates

---

## 🎯 Key Features Implementation

### 💬 **Real-time Messaging**
```dart
// Stream messages in real-time
Stream<List<MessageEntity>> getMessages(MessageEntity message) {
  return firestore
    .collection('users')
    .doc(message.senderUid)
    .collection('myChat')
    .doc(message.recipientUid)
    .collection('messages')
    .orderBy('createdAt', descending: false)
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromSnapshot(doc))
        .toList());
}
```

### 📱 **Phone Authentication**
```dart
// Verify phone number with Firebase
await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: phoneNumber,
  verificationCompleted: (PhoneAuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  },
  verificationFailed: (FirebaseAuthException e) {
    // Handle error
  },
  codeSent: (String verificationId, int? resendToken) {
    // Navigate to OTP screen
  },
);
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Emmanuel Oghenemine**
- GitHub: [@mine0059](https://github.com/mine0059)
<!-- - LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile) -->
- Email: oghenemineemma@gmail.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- WhatsApp for design inspiration
- Open source community for various packages

---

## 📞 Support

If you like this project, please give it a ⭐ on GitHub!

For support, email your.email@example.com or create an issue on GitHub.

---

<div align="center">
  <h3>Made with ❤️ and Flutter</h3>
  <p>© 2025 WhatsApp Clone. All rights reserved.</p>
</div>