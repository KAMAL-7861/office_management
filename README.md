# Smart Office Attendance & Task Management System

A production-ready Flutter application built with Clean Architecture, BLoC, and Firebase.

## Features

- **Authentication**: Secure login/logout with role-based access.
- **Attendance**: GPS-verified check-in/out with geofence validation.
- **Offline Support**: Cache attendance records locally using Hive and sync when back online.
- **Task Management**: Submit and track daily tasks.
- **Admin Panel**: Monitor employee attendance and approve tasks.
- **Security**: Robust Firestore rules and backend validation logic.

## Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC / Cubit
- **Backend**: Firebase (Auth, Firestore, Messaging)
- **Local DB**: Hive
- **DI**: GetIt
- **Location**: Geolocator & Google Maps

## Folder Structure

```
lib/
├── core/               # Shared utilities, theme, and network info
├── features/
│   ├── auth/           # Login, Session Management
│   ├── attendance/     # Check-in, Geofencing, History
│   ├── tasks/          # Task Submission & Review
│   └── admin/          # Admin Dashboard & Employee CRUD
└── main.dart           # App Entry Point
```

## Setup

1. Configure Firebase in your project.
2. Run `flutter pub get`.
3. Deploy `firestore.rules`.
4. Run the app on an emulator or physical device.

---
Built by Antigravity (Senior Flutter Engineer)
