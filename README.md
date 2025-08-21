# MotivaMate Mobile

A comprehensive self-motivation mobile application built with Flutter, designed to help users achieve their goals through task management, focus sessions, and social challenges.

## 🌟 Features

### 🎯 **Achieve Tab**
- **Focus Timer**: Pomodoro-style timer with customizable durations (15, 25, 45, 60 minutes)
- **Goal Setting**: Create and track personal goals with progress monitoring
- **Focus Tips**: Built-in guidance for effective study sessions

### ✅ **Tasks & Challenges**
- **Personal Tasks**: Create self-assigned tasks with priority levels and due dates
- **Social Challenges**: Create and join challenges with friends using unique codes
- **Leaderboards**: Point-based ranking system for challenge participants
- **Progress Tracking**: Daily task completion monitoring

### 📅 **Calendar**
- **Event Management**: Add, edit, and delete events with different types
- **Visual Calendar**: Interactive calendar with event indicators
- **Event Categories**: Study, exam, assignment, personal, and meeting types
- **All-day Events**: Support for both timed and all-day events

### 📝 **Notes**
- **Rich Text Notes**: Create and organize notes with different categories
- **Color Coding**: Customizable note colors for better organization
- **Tags System**: Add tags to notes for easy searching and filtering
- **Search & Filter**: Find notes by title, content, or tags

### 👤 **Profile & Statistics**
- **Comprehensive Stats**: Track focus time, completed tasks, and streaks
- **Achievement System**: Unlock achievements based on your activities
- **Progress Charts**: Visual representation of your weekly progress
- **Goal Tracking**: Monitor your goal completion rates

### 💡 **Inspiration**
- **Historical Characters**: Learn from great minds in history
- **Motivational Stories**: Detailed biographies and achievements
- **Inspiring Quotes**: Famous quotes from influential personalities
- **Life Lessons**: What we can learn from each character

### 🌌 **Space Theme**
- **Animated Background**: Moving stars create an immersive experience
- **Glass Morphism**: Modern UI with semi-transparent elements
- **Dark Theme**: Easy on the eyes for extended use
- **Smooth Animations**: 60fps transitions and micro-interactions

### 💬 **Dynamic Quotes Bar**
- **Bilingual Quotes**: Rotating quotes in Arabic and English
- **Auto-changing**: New quote every 3 seconds
- **Motivational Content**: Carefully curated inspirational messages

## 🛠️ Technical Features

### 🔐 **Authentication**
- Firebase Authentication with email/password
- Google Sign-In integration
- Cross-device data synchronization
- Secure session management

### 📊 **Data Management**
- Cloud Firestore for real-time data sync
- Offline support with local storage
- Automatic data backup and restore
- Real-time updates across devices

### 📱 **Mobile Optimizations**
- Responsive design for all screen sizes
- Touch-optimized interactions (44px minimum touch targets)
- Haptic feedback for different actions
- Platform-specific adaptations (iOS/Android)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/motivamate-mobile.git
   cd motivamate-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download and place configuration files:
     - `google-services.json` in `android/app/`
     - `GoogleService-Info.plist` in `ios/Runner/`
   - Enable Authentication, Firestore, and Cloud Messaging

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart       # App theme and colors
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── tasks_provider.dart
│   ├── calendar_provider.dart
│   ├── notes_provider.dart
│   ├── profile_provider.dart
│   └── quotes_provider.dart
├── screens/
│   ├── auth_screen.dart     # Authentication
│   ├── main_screen.dart     # Main app container
│   └── tabs/                # Tab screens
│       ├── achieve_tab.dart
│       ├── tasks_tab.dart
│       ├── calendar_tab.dart
│       ├── notes_tab.dart
│       ├── profile_tab.dart
│       └── inspiration_tab.dart
└── widgets/
    └── space_background.dart # Animated space background
```

## 🎨 Design System

### Color Palette
- **Primary**: Deep Teal (#1A6B6B) - Focus and reliability
- **Secondary**: Light Blue-Gray (#E5E7EB) - Neutral elements
- **Accent**: Warm Orange (#E67E22) - Highlights and CTAs
- **Background**: Space theme with animated stars
- **Glass**: Semi-transparent elements with backdrop blur

### Typography
- **Font Family**: Inter (optimized for mobile)
- **Sizes**: Responsive scaling from mobile to desktop
- **Hierarchy**: Clear distinction between headers and body text

### Spacing
- **Scale**: 4/8/16/24/32/48px consistent spacing
- **Touch Targets**: Minimum 44px for accessibility
- **Borders**: 4/8/12/16px radius options

## 🔧 Key Dependencies

- **flutter**: UI framework
- **firebase_auth**: Authentication
- **cloud_firestore**: Database
- **provider**: State management
- **table_calendar**: Calendar widget
- **fl_chart**: Charts and analytics
- **circular_countdown_timer**: Focus timer
- **google_fonts**: Typography
- **google_sign_in**: OAuth integration

## 🚀 Features Roadmap

- [ ] Push notifications for reminders
- [ ] Voice notes functionality
- [ ] Study group creation
- [ ] Advanced analytics dashboard
- [ ] Offline mode improvements
- [ ] Widget support
- [ ] Apple Watch companion app

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the original MotivaMate web application
- Historical character information from various educational sources
- UI/UX inspiration from modern productivity apps
- Community feedback and contributions

## 📞 Support

For support, email support@motivamate.com or create an issue on GitHub.

---

**Built with ❤️ using Flutter**