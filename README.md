# ml_test

A Flutter application integrating Google ML Kit for Face Detection and Text Recognition, along with secure local database storage using SQLite and SQLCipher.

## Features

*   **Machine Learning**: Face detection and text recognition powered by Google ML Kit.
*   **Camera & Image Processing**: Capture photos using the device camera or pick images from the gallery. Includes perspective correction, cropping and before/after comparisons for faces.
*   **Secure Storage**: Local data persistence with an encrypted SQLite database (`sqflite_sqlcipher`) and secure key management (`flutter_secure_storage`).
*   **History & Review**: View a list of previously processed results with detailed metadata and options to copy extracted text.
*   **State Management**: Built using GetX for reactive state management, routing, and dependency injection.
*   **Export/Sharing**: PDF generation on device to export processed text and images.

## Dependencies

This project relies on several key Flutter packages:

*   **[get](https://pub.dev/packages/get)** (^4.7.3): State management, dependency injection, and route management.
*   **[google_mlkit_face_detection](https://pub.dev/packages/google_mlkit_face_detection)** (^0.13.2): For recognizing faces in images.
*   **[google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition)** (^0.15.1): For extracting text from images.
*   **[camera](https://pub.dev/packages/camera)** (^0.11.3+1) & **[image_picker](https://pub.dev/packages/image_picker)** (^1.2.1): For capturing and selecting images to process.
*   **[image](https://pub.dev/packages/image)** (^4.5.4): Image manipulation library.
*   **[sqflite](https://pub.dev/packages/sqflite)** (^2.4.2) & **[sqflite_sqlcipher](https://pub.dev/packages/sqflite_sqlcipher)** (^3.4.0): Secure local database storage.
*   **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)** (^10.0.0): Securely storing encryption keys for the database.
*   **[permission_handler](https://pub.dev/packages/permission_handler)** (^12.0.1): Request and check necessary permissions (Camera, Photos).
*   **[pdf](https://pub.dev/packages/pdf)** (^3.11.3): Generating PDF files.

## Setup Instructions

### Prerequisites

Ensure you have the following installed on your system:

1.  [Flutter SDK](https://docs.flutter.dev/get-started/install) (The project requires Dart SDK `^3.11.0`)
2.  An IDE like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
3.  Target devices or emulators set up for iOS or Android.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd ml_test
    ```

2.  **Get dependencies:**
    Run the following command in the terminal from the root directory to download all required packages:
    ```bash
    flutter pub get
    ```

3.  **Platform Specific Setup:**
    *   **iOS**: Navigate to the `ios` directory and install pods. This step requires a Mac with Xcode installed.
        ```bash
        cd ios
        pod install
        cd ..
        ```
    *   **Android**: Ensure your `minSdkVersion` in `android/app/build.gradle` meets the requirements for the ML Kit and SQLCipher packages (typically 21 or higher).

### Running the App

Run the application on a connected device or emulator using:
```bash
flutter run
```

## Copyright & License

Copyright (c) 2026. All rights reserved.

This project is submitted solely for the purpose of a challenge evaluation. No license is granted to use, modify, reproduce, distribute, or create derivative works from this code beyond the evaluation process. See the [LICENSE](LICENSE) file for details.
