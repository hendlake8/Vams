@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ========================================
echo   VAM Release Build Script
echo ========================================
echo.

:: PowerShell을 사용하여 날짜/시간 가져오기 (로케일 독립적)
for /f %%i in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd'"') do set "DATE_FOLDER=%%i"
for /f %%i in ('powershell -Command "Get-Date -Format 'MM-dd-HH-mm'"') do set "TIMESTAMP=%%i"

:: 출력 경로 설정
set "APK_NAME=Vam_%TIMESTAMP%.apk"
set "RELEASE_DIR=Release\%DATE_FOLDER%"
set "OUTPUT_PATH=%RELEASE_DIR%\%APK_NAME%"

echo [INFO] Build Date: %DATE_FOLDER%
echo [INFO] APK Name: %APK_NAME%
echo [INFO] Output Path: %OUTPUT_PATH%
echo.

:: Release 폴더 생성
if not exist "%RELEASE_DIR%" (
    echo [INFO] Creating release directory...
    mkdir "%RELEASE_DIR%"
)

:: Flutter clean
echo [INFO] Cleaning project...
call flutter clean
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Flutter clean failed!
    pause
    exit /b 1
)

:: Flutter pub get
echo.
echo [INFO] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Flutter pub get failed!
    pause
    exit /b 1
)

:: Release APK 빌드
echo.
echo [INFO] Building Release APK...
call flutter build apk --release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Flutter build failed!
    pause
    exit /b 1
)

:: APK 복사
echo.
echo [INFO] Copying APK to release folder...
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "%OUTPUT_PATH%"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to copy APK!
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo   Output: %OUTPUT_PATH%
echo.

:: 빌드된 APK 크기 표시
for %%A in ("%OUTPUT_PATH%") do (
    set "SIZE=%%~zA"
    set /a "SIZE_MB=!SIZE! / 1048576"
    echo   Size: !SIZE_MB! MB
)

echo.
echo ========================================

:: Release 폴더 열기
explorer "%RELEASE_DIR%"

pause
