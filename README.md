# calendar_journal

A new Flutter project.

## change without losing data

`flutter build apk `

`adb install build/app/outputs/flutter-apk/app.apk`

change also in android/app/build.gradle
> buildTypes {
        release {
            signingConfig signingConfigs.debug
           //signingConfig signingConfigs.release
        }
    }

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
