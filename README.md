# Aayurvani

Aayurvani is a Flutter clinical Ayurvedic prototype with a deterministic Node.js/MySQL backend.

## Essential Folders

- `lib/`: Flutter application UI.
- `android/`: Android runner project.
- `ios/`: iOS runner project.
- `test/`: Flutter widget smoke tests.
- `backend/`: Express + TypeScript API, MySQL schema, email verification, and deterministic rule engine.

## Run the app (Windows)

This project includes **Chrome** and **Windows** runners. On most PCs, Chrome is the easiest target:

```powershell
flutter pub get
flutter run -d chrome
```

Or use the helper script (clears iOS ephemeral locks first):

```powershell
.\scripts\run_app.ps1
```

In VS Code / Cursor, use **Run > Start Debugging** and pick **Aayurvani (Chrome)**.

**If the project folder is under OneDrive**, sync can lock build files. If `flutter run` or `flutter clean` fails with “file is being used” or `PathAccessException`:

1. Pause OneDrive sync for this folder, or copy the project to a local path such as `C:\dev\aayurvani_app`.
2. Close other Flutter/Chrome/Dart processes.
3. Run `flutter clean`, then `flutter pub get`, then `flutter run -d chrome`.

**Windows desktop** (`flutter run -d windows`) also requires the [Visual Studio C++ desktop workload](https://docs.flutter.dev/platform-integration/windows/setup). Use Chrome if `flutter doctor` reports a missing VS toolchain.

## Verification

Flutter:

```powershell
flutter pub get
dart analyze lib/main.dart
flutter test
```

Backend:

```powershell
cd backend
npm install
npm run typecheck
npm run build
```

Backend setup details live in `backend/README.md`.
