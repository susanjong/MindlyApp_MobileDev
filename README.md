# 🧠 MindlyApp
**An Integrated Productivity Application**

MindlyApp is a productivity application designed to help users manage **daily activities, notes, tasks, and schedules** within a single, unified platform. The main problem addressed by MindlyApp is the fragmentation of productivity tools, where users are forced to switch between multiple applications such as to-do lists, calendars, and note-taking apps.

This habit of switching applications often leads to **loss of focus**, **duplicated information**, **unsynchronized data**, and **low efficiency** in managing time and tasks. MindlyApp provides a solution by integrating **To-Do List, Calendar, and Notes** into one intuitive, adaptive, and contextual interface to **optimize time management** and **improve consistency**.

## 👤 Owner Information
- **Project Name**: MindlyApp
- **Owner / Maintainer**:
    1. Susan Jong (231401014) Lab 3 move to lab 1
    2. Parulian Dwi Reslia Simbolon (231401032) Lab 3
    3. Charissa Haya Qanita (231401113) Lab 3
- **Group Name**: Soyu Team
- **Class** : B (2023)
- Mobile Programming 


## 📚 Documentation
- **Software Requirement Specification (SRS)**: [**View SRS Document**](https://docs.google.com/document/d/1gceSWC0wfhcvUrp6caHxGd70OgIt0XDV/edit?usp=sharing&ouid=113965595944164190356&rtpof=true&sd=true)


## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Make sure you have Flutter installed on your machine. If not, follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install).

### Installation

1.  **Clone the repository**
    Clone the `main` branch of the project to your local machine.
    ```bash
    git clone https://github.com/susanjong/MindlyApp_MobileDev.git -b main
    ```

2.  **Navigate to the project directory**
    ```bash
    cd MindlyApp_MobileDev
    ```

3.  **Install Dependencies**
    Fetch all the required packages for the project.
    ```bash
    flutter pub get
    ```

4.  **Run the Application**
    Launch the app on your connected device or emulator.
    ```bash
    flutter run
    ```

That's it! You should now have MindlyApp running on your device.


## 📦 Download MindlyApp (APK)

Ready to boost your productivity? Experience MindlyApp firsthand by installing the official APK. Get all your notes, tasks, and schedules in one powerful, intuitive app.

**Version**: 1.0.0  
**Build Type**: Release

🔗 **Direct Download**:
👉 **[Download MindlyApp v1.0.0 APK](https://github.com/susanjong/MindlyApp_MobileDev/releases/download/v.1.0.0/app-release.apk)**

*Just click, download, and install to get started!* 


## ✨ Features

### 🔐 Authentication & Onboarding
- Intro / Splash Pages
- Terms of Service & Privacy Policy
- Sign Up with **Email Verification (Firebase – Gmail)**
- Sign In & Forgot Password
- Secure Authentication with Auto Data Sync

### 🏠 Home
- Daily Progress Tracker
- Summary of To-Do Lists, Events, and Notes
- Integrated Notifications

### 📝 Notes & To-Do List
- Full CRUD (Create, Read, Update, Delete)
- Custom Categories, Deadlines, and Descriptions
- Favorite/Like Notes
- Urgent and Overdue Task Status

### 📅 Calendar & Events
- Monthly, Yearly, and Mini Calendar Views
- Full CRUD for Events
- Event Reminders with Sound Alerts

### 👤 Account Settings
- Manage Profile Photo (CRUD)
- Reset Password & Delete Account
- Secure Logout


## ⚙️ Tech Stack
- **IDE**: Android Studio
- **Framework**: Flutter
- **Language**: Dart
- **Backend & Auth**: Firebase


## 🛠️ Firebase Configuration Fix

If you encounter an error related to `firebase_options.dart`, follow these steps:

### 1. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Configure Firebase for the Project
Run this command inside your project directory:
```bash
flutterfire configure
```
Select your Firebase project and desired platforms. This will automatically generate the necessary configuration files.

### 4. Get Dependencies and Run
```bash
flutter pub get
flutter run
```
