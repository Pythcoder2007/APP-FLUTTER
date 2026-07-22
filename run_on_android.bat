@echo off
setlocal EnableExtensions
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter is not installed or not in PATH.
  pause
  exit /b 1
)
if not exist "android\app\build.gradle" if not exist "android\app\build.gradle.kts" (
  if exist ".platform_temp" rmdir /s /q ".platform_temp"
  call flutter create --platforms=android --org com.shrishakra --project-name sports_emporium_manager .platform_temp
  if errorlevel 1 exit /b 1
  xcopy ".platform_temp\android" "android" /E /I /H /Y >nul
  if exist ".platform_temp\.metadata" copy /Y ".platform_temp\.metadata" ".metadata" >nul
  rmdir /s /q ".platform_temp"
)
call flutter pub get
call flutter devices
echo.
echo Connect your Android phone with USB debugging, or start an emulator.
echo Then press any key.
pause >nul
call flutter run
pause
