# Implementation Plan

- [ ] 1. Remove Google Sign-in from Authentication System
  - Remove Google sign-in button and related UI from login screen
  - Remove Google sign-in event handling from authentication bloc
  - Remove Google sign-in use case and data source methods
  - _Requirements: 1.1, 1.3, 2.3_

- [ ] 1.1 Remove Google sign-in UI from login screen
  - Remove Google sign-in button from LoginScreen widget
  - Remove Google sign-in related imports and dependencies
  - Update UI layout to show only email/password fields
  - _Requirements: 1.1, 1.3_

- [ ] 1.2 Write property test for authentication methods
  - **Property 1: Authentication only accepts email/password**
  - **Validates: Requirements 1.2**

- [ ] 1.3 Remove Google sign-in from authentication bloc
  - Remove GoogleSignInRequested event from auth_event.dart
  - Remove Google sign-in event handler from AuthBloc
  - Remove GoogleSignInUseCase dependency from bloc constructor
  - _Requirements: 2.3_

- [ ] 1.4 Remove Google sign-in use case
  - Delete GoogleSignInUseCase class from auth_usecases.dart
  - Remove Google sign-in method from AuthRepository interface
  - Remove Google sign-in implementation from AuthRepositoryImpl
  - _Requirements: 2.1, 2.2_

- [ ] 1.5 Remove Google sign-in from data source
  - Remove signInWithGoogle method from AuthRemoteDataSource
  - Remove Google sign-in imports (google_sign_in package)
  - Remove Google sign-in logout call from logout method
  - _Requirements: 2.2_

- [ ] 2. Remove Picture Capturing from Attendance System
  - Remove selfie capture functionality from check-in screen
  - Remove image picker dependencies and camera permissions
  - Update attendance entities to exclude selfie fields
  - _Requirements: 3.1, 3.3, 4.3_

- [ ] 2.1 Remove selfie capture UI from check-in screen
  - Remove selfie capture button and camera preview from CheckInScreen
  - Remove image picker imports and related state management
  - Update check-in flow to work without selfie requirement
  - _Requirements: 3.1, 3.3_

- [ ] 2.2 Write property test for location-only check-in
  - **Property 2: Check-in works with location only**
  - **Validates: Requirements 3.2**

- [ ] 2.3 Update attendance entity model
  - Remove selfieUrl field from AttendanceEntity
  - Remove selfieUrl field from AttendanceModel
  - Update entity constructors and serialization methods
  - _Requirements: 3.4, 4.3_

- [ ] 2.4 Write property test for attendance entities
  - **Property 3: Attendance entities exclude selfie data**
  - **Validates: Requirements 3.4, 4.3**

- [ ] 2.5 Remove selfie upload from storage repository
  - Remove uploadSelfie method from StorageRepository
  - Remove selfie-related storage operations
  - Update check-in flow to not call selfie upload methods
  - _Requirements: 4.4_

- [ ] 3. Clean up dependencies and permissions
  - Remove image picker package from pubspec.yaml
  - Remove camera permissions from Android manifest
  - Update dependency injection to remove Google sign-in services
  - _Requirements: 4.2, 5.1, 5.2, 5.3_

- [ ] 3.1 Remove image picker dependency
  - Remove image_picker package from pubspec.yaml
  - Run flutter pub get to update dependencies
  - Verify no broken imports remain in codebase
  - _Requirements: 4.2, 5.3_

- [ ] 3.2 Remove camera permissions
  - Remove CAMERA permission from android/app/src/main/AndroidManifest.xml
  - Remove any iOS camera usage descriptions if present
  - _Requirements: 5.1, 5.2_

- [ ] 3.3 Update dependency injection
  - Remove GoogleSignInUseCase from injection container
  - Remove Google sign-in service registrations
  - Update AuthBloc constructor to not require GoogleSignInUseCase
  - _Requirements: 2.4_

- [ ] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4.1 Write unit tests for updated components
  - Write unit tests for updated LoginScreen without Google button
  - Write unit tests for updated CheckInScreen without camera
  - Write unit tests for updated AttendanceEntity without selfie field
  - _Requirements: All_

- [ ] 5. Final verification and cleanup
  - Verify application builds successfully without removed dependencies
  - Test authentication flow with email/password only
  - Test attendance check-in flow with location verification only
  - _Requirements: All_

- [ ] 5.1 Verify build and functionality
  - Run flutter clean and flutter pub get
  - Build application for Android and verify no compilation errors
  - Test email/password authentication flow manually
  - _Requirements: All_

- [ ] 5.2 Test attendance functionality
  - Test location-based check-in without selfie requirement
  - Verify attendance records are created successfully
  - Confirm geofence validation still works correctly
  - _Requirements: 3.2, 3.4_

- [ ] 6. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.