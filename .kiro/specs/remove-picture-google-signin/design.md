# Design Document

## Overview

This design outlines the systematic removal of two features from the office management system: the Google sign-in authentication method and the picture capturing system used during attendance check-in. The removal will simplify the authentication flow to email/password only and streamline the attendance process to location-based verification without selfie requirements.

## Architecture

The removal affects two main feature modules:

1. **Authentication Module**: Remove Google sign-in components while preserving email/password authentication
2. **Attendance Module**: Remove camera/selfie components while preserving location-based check-in

The clean architecture structure (presentation → domain → data) will be maintained, with components simply removed rather than replaced.

## Components and Interfaces

### Authentication System Changes

**Removed Components:**
- `GoogleSignInUseCase` - Business logic for Google authentication
- `GoogleSignInRequested` event - Bloc event for triggering Google sign-in
- `signInWithGoogle()` method in `AuthRemoteDataSource`
- Google sign-in button and related UI in `LoginScreen`
- Google sign-in handling in `AuthBloc`

**Preserved Components:**
- Email/password login flow
- User registration
- Session management
- All existing user entity and repository interfaces

### Attendance System Changes

**Removed Components:**
- Selfie capture functionality in `CheckInScreen`
- Image picker integration
- Storage repository selfie upload methods
- Camera-related UI components and state management
- Selfie URL fields in attendance entities

**Preserved Components:**
- Location-based geofencing
- Attendance record creation and storage
- Check-in/check-out timing logic
- All core attendance business rules

## Data Models

### AttendanceEntity Modifications

**Before:**
```dart
class AttendanceEntity {
  final String id;
  final String userId;
  final DateTime checkIn;
  final double latitude;
  final double longitude;
  final AttendanceStatus status;
  final String? selfieUrl;  // ← Remove this field
}
```

**After:**
```dart
class AttendanceEntity {
  final String id;
  final String userId;
  final DateTime checkIn;
  final double latitude;
  final double longitude;
  final AttendanceStatus status;
  // selfieUrl field removed
}
```

### User Authentication Flow

The authentication flow will be simplified to only support email/password:

```
User Input (Email/Password) → LoginRequested Event → AuthBloc → LoginUseCase → AuthRepository → Firebase Auth
```

Google sign-in path completely removed:
```
~~Google Sign-in Button → GoogleSignInRequested Event → AuthBloc → GoogleSignInUseCase → Google Services~~
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following properties ensure the removal is complete and correct:

**Property 1: Authentication only accepts email/password**
*For any* authentication attempt, the system should only process email and password credentials and reject any other authentication methods
**Validates: Requirements 1.2**

**Property 2: Check-in works with location only**
*For any* valid check-in attempt, the attendance system should successfully process attendance based solely on location verification without requiring additional inputs like selfies
**Validates: Requirements 3.2**

**Property 3: Attendance entities exclude selfie data**
*For any* attendance record created, the entity should not contain selfie-related fields and should be valid without selfie URLs
**Validates: Requirements 3.4, 4.3**

## Error Handling

### Authentication Errors
- Invalid email/password combinations will continue to show appropriate error messages
- Network connectivity issues during authentication will be handled as before
- No Google-specific error handling will remain in the system

### Attendance Errors
- Location permission denied errors will be handled as before
- Geofence validation failures will continue to show appropriate messages
- No camera permission or image capture errors will remain in the system

### Removed Error Cases
- Google sign-in cancellation errors
- Google authentication failures
- Camera permission denied errors
- Image capture failures
- Selfie upload failures

## Testing Strategy

### Unit Testing Approach
Unit tests will verify:
- Login screen renders only email/password fields
- Check-in screen renders without camera elements
- Authentication bloc doesn't handle Google events
- Attendance entities can be created without selfie fields

### Property-Based Testing Approach
Property-based tests will use the **test** package for Dart/Flutter and will run a minimum of 100 iterations per property. Each property-based test will be tagged with a comment referencing the correctness property from this design document.

**Property Testing Library**: Flutter's built-in `test` package with custom generators for:
- Valid email/password combinations
- Location coordinates within and outside geofence boundaries
- Attendance entity creation with various valid parameters

**Test Configuration**: Each property-based test will run 100 iterations to ensure comprehensive coverage across the input space.

**Test Tagging**: Each property-based test will include a comment in this exact format:
- `**Feature: remove-picture-google-signin, Property 1: Authentication only accepts email/password**`
- `**Feature: remove-picture-google-signin, Property 2: Check-in works with location only**`
- `**Feature: remove-picture-google-signin, Property 3: Attendance entities exclude selfie data**`

### Integration Testing
- End-to-end authentication flow testing with email/password only
- Complete attendance check-in flow testing without camera interaction
- Verification that removed dependencies don't affect other system components

### Regression Testing
- Ensure existing functionality (location-based check-in, email/password auth) continues to work
- Verify no broken imports or missing dependencies after removal
- Confirm UI layouts remain functional after component removal