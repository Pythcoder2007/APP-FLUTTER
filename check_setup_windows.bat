@echo off
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter is not installed or is not in PATH.
  echo Install it from: https://docs.flutter.dev/get-started/install/windows/mobile
  pause
  exit /b 1
)
flutter doctor -v
echo.
echo If Android licenses are pending, run:
echo flutter doctor --android-licenses
pause
