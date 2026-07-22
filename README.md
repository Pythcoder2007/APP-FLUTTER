# Sports Emporium Manager — Flutter Android App

This is the Windows-friendly Android rewrite of the original Python/Tkinter application.
It does **not** need Ubuntu, Linux, WSL, Buildozer, Kivy, or Python.

## Included features

- Password login (default: `12345678`)
- Dashboard with daily, monthly and yearly revenue
- Inventory search, add, edit and delete
- Low-stock warnings
- Billing cart with quantity, discount, tax and payment mode
- Customer records and total spending
- Billing history and receipt viewer
- Revenue, cost, profit and top-product reports
- Shop name, address, phone, tax, currency and password settings
- Offline SQLite storage on the Android device

## One-time Windows setup

1. Install **Flutter SDK for Windows**.
2. Install **Android Studio** and let it install the Android SDK.
3. Open Command Prompt and run:

   ```cmd
   flutter doctor
   flutter doctor --android-licenses
   ```

4. Fix any red Android-related items shown by `flutter doctor`.

## Build the APK

Double-click:

```text
build_apk_windows.bat
```

The script creates the Android platform folder automatically and builds the release APK.
The final file will be placed at:

```text
APK_OUTPUT\SportsEmporium-release.apk
```

## Test on a phone or emulator

Enable Developer Options and USB debugging on the Android phone, connect it, then double-click:

```text
run_on_android.bat
```

## Important

The first build downloads Android and Flutter dependencies and can be several gigabytes. After that, later builds are much faster.

The original desktop print-window feature is represented as an in-app receipt viewer. Direct Bluetooth/thermal-printer support can be added later because printer models use different protocols.
