# Android Device Testing & Deployment Guide

> Step-by-step instructions for building debug/release APKs and installing them directly onto connected physical Android devices or emulators.

---

## 🛠️ Step 1: Build the APK

Before installing the app onto a device, you need to compile it into an Android Package (APK).

### 1. Build a Unified Release APK
This builds a single, large "fat" APK containing binaries for all target architectures (`armeabi-v7a`, `arm64-v8a`, `x86_64`):
```bash
flutter build apk --release
```
* **Output Path**: `build/app/outputs/flutter-apk/app-release.apk`
* **Best For**: General distribution, sharing with beta testers via file sharing.

### 2. Build Split-ABI APKs (Recommended for Testing)
To reduce file size, you can split the build so that it generates a separate APK for each CPU architecture:
```bash
flutter build apk --release --split-per-abi
```
* **Output Paths**:
  * `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (Older 32-bit ARM devices)
  * `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (Modern 64-bit ARM devices/phones)
  * `build/app/outputs/flutter-apk/app-x86_64-release.apk` (Emulators)
* **Best For**: Deploying manually to a specific target device to save installation time and space.

---

## 📱 Step 2: Prepare the Android Device

To install the APK via command line, your computer needs permission to communicate with your Android device.

1. **Enable Developer Options**:
   * Open the **Settings** app on your Android device.
   * Go to **About Phone** (or **System > About Phone**).
   * Scroll down to find the **Build Number** and tap it **7 times** until you see the toast: *"You are now a developer!"*
2. **Enable USB Debugging**:
   * Go back to the main **Settings** page.
   * Tap on **System > Developer Options** (or search Settings for "Developer Options").
   * Scroll down and toggle on **USB Debugging**.
3. **Connect Device to Computer**:
   * Connect your phone to your computer using a high-quality USB cable.
   * A prompt will appear on your device screen asking: *"Allow USB debugging?"*
   * Check **Always allow from this computer** and tap **Allow**.

---

## 🔍 Step 3: Verify the Connection

Ensure that your device is correctly detected by your development machine.

1. **Check via ADB (Android Debug Bridge)**:
   ```bash
   adb devices
   ```
   * *Expected Output*:
     ```text
     List of devices attached
     abcdef1234567890    device
     ```
   * *Note*: If it says `unauthorized` next to the device name, unlock your phone screen and accept the authentication prompt.

2. **Check via Flutter**:
   ```bash
   flutter devices
   ```
   * This lists all connected phones, tablets, and running emulators recognized by Flutter.

---

## 🚀 Step 4: Install/Push the APK to the Device

You can install the APK using either **ADB** or the **Flutter CLI**.

### Method A: Install via ADB (Fastest for Pre-built APKs)
If you have already run the `flutter build apk` command, you can push the compiled APK directly:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

* **To upgrade/reinstall without losing app data**:
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```
* **If multiple devices are connected**, specify the target device ID (from `adb devices`):
  ```bash
  adb -s abcdef1234567890 install -r build/app/outputs/flutter-apk/app-release.apk
  ```

### Method B: Install via Flutter CLI
Flutter provides helper commands that compile and install in a single step.

* **Run on Device directly (in Release mode)**:
  ```bash
  flutter run --release
  ```
  * If multiple devices are connected, it will prompt you to choose one or you can specify it:
    ```bash
    flutter run -d abcdef1234567890 --release
    ```

* **Install without running**:
  If you just want to install the previously built APK onto the device without launching a debug/run session:
  ```bash
  flutter install
  ```

---

## ⚠️ Troubleshooting

*   **Error: "No devices found"**
    *   Ensure your USB cable supports data transfer (some cables only support charging).
    *   Restart the ADB server:
        ```bash
        adb kill-server
        adb start-server
        ```
*   **Error: "INSTALL_FAILED_ALREADY_EXISTS"**
    *   Use the `-r` flag with adb to overwrite: `adb install -r <apk_path>`.
*   **Error: "INSTALL_FAILED_UPDATE_INCOMPATIBLE"**
    *   This happens when the version on the device was signed with a different key (e.g., debug vs release key).
    *   Uninstall the existing app first:
        ```bash
        adb uninstall com.madeonweekends.learnloop
        ```
        *(Or uninstall it manually by long-pressing the app icon on the device and choosing Uninstall).*
