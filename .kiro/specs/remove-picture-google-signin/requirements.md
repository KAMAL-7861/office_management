# Requirements Document

## Introduction

This specification outlines the removal of two features from the office management system: the picture capturing system used during attendance check-in and the Google sign-in functionality from the authentication system. These features will be completely removed to simplify the application and reduce dependencies.

## Glossary

- **Picture Capturing System**: The functionality that requires employees to take a selfie during attendance check-in, including camera access, image storage, and related UI components
- **Google Sign-in**: The authentication method that allows users to sign in using their Google accounts instead of email/password
- **Authentication System**: The system responsible for user login, logout, and session management
- **Attendance System**: The system responsible for tracking employee check-ins and check-outs
- **Image Picker**: The Flutter plugin used for accessing device camera and photo gallery
- **Storage Repository**: The service responsible for uploading and managing user-generated content like selfie images

## Requirements

### Requirement 1

**User Story:** As a system administrator, I want the Google sign-in option removed from the login screen, so that users can only authenticate using email and password credentials.

#### Acceptance Criteria

1. WHEN a user views the login screen, THE Authentication System SHALL display only email and password input fields with a standard login button
2. WHEN a user attempts to authenticate, THE Authentication System SHALL only process email and password credentials
3. WHEN the login screen is rendered, THE Authentication System SHALL not display any Google sign-in button or related UI elements
4. WHEN the authentication flow is executed, THE Authentication System SHALL not invoke any Google sign-in services or APIs

### Requirement 2

**User Story:** As a developer, I want all Google sign-in related code removed from the codebase, so that the application has no dependencies on Google authentication services.

#### Acceptance Criteria

1. WHEN the application is built, THE Authentication System SHALL not include any Google sign-in use cases or business logic
2. WHEN the authentication data source is instantiated, THE Authentication System SHALL not contain methods for Google authentication
3. WHEN the authentication bloc processes events, THE Authentication System SHALL not handle Google sign-in requests
4. WHEN the application starts, THE Authentication System SHALL not initialize any Google sign-in services

### Requirement 3

**User Story:** As an employee, I want to check in to work without taking a selfie, so that the attendance process is faster and more privacy-friendly.

#### Acceptance Criteria

1. WHEN an employee accesses the check-in screen, THE Attendance System SHALL display location-based check-in options without camera functionality
2. WHEN an employee initiates check-in, THE Attendance System SHALL process attendance based on location verification only
3. WHEN the check-in screen is rendered, THE Attendance System SHALL not display selfie capture buttons or camera preview
4. WHEN attendance records are created, THE Attendance System SHALL not require or store selfie image URLs

### Requirement 4

**User Story:** As a developer, I want all picture capturing functionality removed from the attendance system, so that the application has no camera dependencies.

#### Acceptance Criteria

1. WHEN the attendance check-in flow is executed, THE Attendance System SHALL not access device camera or image picker services
2. WHEN the application is built, THE Attendance System SHALL not include image picker dependencies or camera permissions
3. WHEN attendance entities are processed, THE Attendance System SHALL not include selfie-related fields or properties
4. WHEN the storage repository is used, THE Attendance System SHALL not upload or manage selfie images

### Requirement 5

**User Story:** As a system administrator, I want camera permissions removed from the application, so that the app requests minimal device permissions.

#### Acceptance Criteria

1. WHEN the application is installed, THE Authentication System SHALL not request camera permissions from the device
2. WHEN the application manifest is processed, THE Authentication System SHALL not declare camera usage permissions
3. WHEN the application dependencies are resolved, THE Authentication System SHALL not include image picker or camera-related packages
4. WHEN the application runs, THE Authentication System SHALL not access any camera hardware or services