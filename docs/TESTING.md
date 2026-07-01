# TESTING.md

> Testing strategy and execution for the Learn Loop project. Covers automated unit/widget tests and manual/mobile physical device testing.

## 🧪 Automated Testing

Automated tests ensure the correctness of individual widgets, configurations, and the low-level PDF rendering logic.

### Commands

Run all tests locally before proposing changes or merging pull requests:

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widgets/worksheet_editor_layout_test.dart
```

### Test Suite Structure

The tests are located in the `test/` directory and match the structure of the application:
- **Unit Tests**: Verify configuration models (`lib/models/`), helper functions, and coordinate math (e.g., standard margins, conversions from millimeters to points).
- **Widget Tests**: Verify interactive widget behaviors, settings input changes, layout responsiveness, and layout adjustments.

---

## 📱 Manual & Mobile Device Testing

Because this application dynamically generates print-friendly PDF files and supports both mobile (tabbed view) and tablet/desktop (split-screen) layouts, testing directly on physical mobile devices is critical.

### Android Testing (Linux, macOS, Windows)

#### Option A: Live Debugging via USB (Recommended)
This approach connects your phone to your development machine and supports **Hot Reload** for rapid iteration.

1. **Enable Developer Options on your Android device**:
   - Go to **Settings** > **About Phone**.
   - Tap **Build Number** 7 times until you see the confirmation message.
2. **Enable USB Debugging**:
   - Go to **Settings** > **System** > **Developer Options**.
   - Turn on **USB Debugging**.
3. **Connect to your computer**:
   - Connect the device via a USB cable.
   - Authorize the connection when prompted on your phone screen.
4. **Identify and Run**:
   - Verify the device is detected by running:
     ```bash
     flutter devices
     ```
   - Launch the application:
     ```bash
     flutter run -d <your-device-id>
     ```
     *(Or simply `flutter run` if it is the only connected target).*

#### Option B: Standalone APK Build
To install the app independently or share it offline:
1. Build the release APK:
   ```bash
   flutter build apk --release
   ```
2. Locate the APK package in:
   `build/app/outputs/flutter-apk/app-release.apk`
3. Transfer the APK to your device to install it.

> [!TIP]
> For a detailed guide on pushing the built APK directly to your device via ADB command line, splitting APKs per CPU architecture, and troubleshooting connection or signature errors, see the [Android Device Testing & Deployment Guide](file:///mnt/workbench/repos/learn-loop/docs/ANDROID_DEVICE_TESTING.md).

---

### iOS Testing (Requires macOS)

> [!NOTE]
> Testing on a physical iOS device requires Xcode and a free or paid Apple Developer ID for code signing.

#### Option A: Live Debugging via Xcode
1. **Connect your iPhone/iPad** to your Mac.
2. **Configure Code Signing**:
   - Open the iOS sub-project in Xcode:
     ```bash
     open ios/Runner.xcworkspace
     ```
   - Select the root **Runner** project in the left navigation.
   - Go to the **Signing & Capabilities** tab.
   - Check **Automatically manage signing** and select your Developer Team.
3. **Trust Developer Certificate**:
   - When launching for the first time, go to **Settings** > **General** > **VPN & Device Management** on your iOS device.
   - Trust your Developer Account profile.
4. **Enable iOS Developer Mode** (iOS 16+):
   - Go to **Settings** > **Privacy & Security** > **Developer Mode** and turn it on. Restart the device.
5. **Run the app**:
   ```bash
   flutter run -d <your-device-id>
   ```

---

## 🛠️ Verification Checklist for Mobile Layouts

When manual testing on a mobile device, verify the following flows:

- **Layout Responsiveness**: Ensure the screen switches to the tabbed layout (Settings tab and Preview tab) rather than the side-by-side desktop layout.
- **Gesture Control**: Ensure tabs swipe smoothly and the PDF preview zooms/scrolls correctly.
- **PDF Generation**: Configure parameters and verify the generated PDF generates immediately on the mobile UI.
