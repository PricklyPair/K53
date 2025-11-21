# Elite Quiz App

This is very short guide and insufficient, for more detailed information,
please be sure to check the [documentation](https://wrteamdev.github.io/Elite_Quiz_Doc) or Offline Doc provided in with the code.

#### IGNORE THE .githooks folder and setup-hooks.sh file, it is only for our development process.
#### it doesn't affect the app code in any way.

## How to run the app in Android (real or emulator)
### Android
1. Get the packages
```shell Get the packages
flutter pub get
```
2. Run the app
```shell
flutter run
```
### IOS (Simulator)
1. Get the packages
```shell Get the packages
flutter pub get
```
2. Get the Pods
```shell
cd ios
pod install
cd ..
```
3. Run the app
```shell
flutter run
```

## How to get your DEBUG SHA keys
- prerequisite: ensure that you are able to use the ``keytool`` command in your terminal.
If not, please check your Java installation. Only continue after you are able to use the ``keytool`` command.

- debug keystore is automatically created when you install the Android Studio for the first time.
- and when you sign the app with in debug mode, it will use that debug keystore.

If you are using Mac or Linux, you can use the following command to get the SHA keys:

```shell
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -keypass android -storepass android
```
and if you are using Windows, you can use the following command to get the SHA keys:

```shell
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -keypass android -storepass android
```

- You can find more about this in app [documentation](https://wrteamdev.github.io/Elite_Quiz_Doc/#:~:text=SHA%20keys%20and%20Keystore%20Basics).

# Rebranding

## How to change the app package name

To change the package name of the app, you can use the change_app_package_name package:

Run the following command, replacing `com.your.package.name` with your desired package name:
```shell
dart run change_app_package_name:main com.your.package.name
```

## How to customize app launcher icons
The app uses flutter_launcher_icons to generate launcher icons for both Android and iOS. Follow these steps to customize the icons:

1. **Prepare your icon images:**
   - Create a square PNG image for your app icon (recommended size: 1024x1024px)
   - Place your icon files in the `assets/config/launcher_icons/` directory

2. **Configure the `flutter_launcher_icons.yaml` file:**
   - The configuration file is already set up in the project root
   - Update the image paths to point to your new icon files:
   ```yaml
    # Example configuration
    flutter_icons:
      android: true
      ios: true
      image_path: "assets/config/launcher_icons/your_icon.png"
   ```

3. **Generate the icons:**
   - Run the following command to generate all the required icon sizes:

   ```shell
   dart run flutter_launcher_icons
   ```

4. **Verify the icons:**
   - Android icons will be generated in `android/app/src/main/res/`
   - iOS icons will be generated in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

5. **Additional options:**
- For platform-specific icons, you can use `image_path_android` and `image_path_ios`
- To remove alpha channel from iOS icons, add `remove_alpha_ios: true`

After generating the icons, rebuild your app to see the changes:

```shell
flutter clean
flutter pub get
flutter run
```

## How to build the release version of the app (for Play Store)
prerequisite:
- make sure you are using correct app version (you can change it from pubspec.yaml then run `flutter pub get`)
- you will need to first create a new release keystore for the app.
- And sign the app with it, also add the SHA keys (of keystore) in firebase, re-download the google-services.json file.
- Run the app with release keystore make sure to check if login works fine.

```shell Build App Bundle
flutter build appbundle --release
open build/app/outputs/bundle/release/
```

firebase deploy --only firestore
