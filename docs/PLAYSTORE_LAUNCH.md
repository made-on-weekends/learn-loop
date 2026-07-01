# Play Store Launch Guide

> Step-by-step guide for packaging, signing, and publishing the Learn Loop application to the Google Play Store.

## 📋 Prerequisites
1. **Google Play Developer Account**: Sign up at [Google Play Console](https://play.google.com/console/signup) ($25 USD one-time registration fee).
2. **Flutter SDK**: Properly configured and doctor-checked on your local machine.

---

## 🛠️ Step 1: Release Configuration

### 1. Unique Package ID (Application ID)
Every app on the Play Store requires a unique package name.
- Open [android/app/build.gradle](file:///mnt/workbench/repos/learn-loop/android/app/build.gradle).
- Update the `applicationId` to your final unique domain:
  ```groovy
  defaultConfig {
      applicationId "com.madeonweekends.learnloop" // Replace with your production package name
      ...
  }
  ```

### 2. Set App Name & Launcher Icon
- **App Name**: Update the `android:label` attribute under `application` inside [android/app/src/main/AndroidManifest.xml](file:///mnt/workbench/repos/learn-loop/android/app/src/main/AndroidManifest.xml).
- **Launcher Icons**: Make sure your custom icon assets are generated and placed in `android/app/src/main/res/mipmap-*` folders.

---

## 🔑 Step 2: Code Signing (Keystore Configuration)

Android requires all apps to be digitally signed before they can be installed or updated.

### 1. Generate an Upload Keystore
Generate a keystore file using the command-line `keytool` utility. Keep the password and file secure (do not check the keystore file into git).

* **Linux/macOS:**
  ```bash
  keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

* **Windows (PowerShell):**
  ```powershell
  keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

### 2. Configure Credentials File
Create a properties file at [android/key.properties](file:///mnt/workbench/repos/learn-loop/android/key.properties). This file contains sensitive credentials and is ignored by Git by default:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

### 3. Update Build Script
Configure the app Gradle build script at [android/app/build.gradle](file:///mnt/workbench/repos/learn-loop/android/app/build.gradle) to read signing credentials and configure the signing configurations:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new java.io.FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties['storeFile'])
                storePassword = keystoreProperties['storePassword']
                keyAlias = keystoreProperties['keyAlias']
                keyPassword = keystoreProperties['keyPassword']
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

---

## 📦 Step 3: Build the App Bundle (AAB)

Google Play Console requires the **Android App Bundle (AAB)** format for submissions. This format allows Google to compile optimized APKs tailored to each user's device configuration.

Build the release app bundle:
```bash
flutter build appbundle --release
```

The output file will be created at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 🚀 Step 4: Submission to Google Play Console

1. **Create an App**: Click **Create App** in the Play Console. Provide details (App/Game, Free/Paid, Default Language).
2. **Complete Initial Declarations**:
   - Set up **Privacy Policy URL**.
   - Fill in **Content Rating questionnaire** (declare details about child/education content).
   - Set up **Target Audience** (Learn Loop targeting kids/homeschooling must declare suitable age range).
3. **Configure Store Listing**:
   - Short/Full descriptions.
   - Screenshots: Upload at least two screenshots for phones, 7-inch tablets, and 10-inch tablets.
   - Upload high-resolution App Icon (512x512 PNG) and Feature Graphic (1024x500 PNG).
4. **Create a Production Release**:
   - Navigate to **Production** under the Release section.
   - Click **Create new release**.
   - Drag and drop your `.aab` file (`app-release.aab`).
   - Fill in the release notes.
   - Click **Review release** and click **Start rollout to Production**.
