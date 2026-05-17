@echo off
setlocal EnableDelayedExpansion

:: Path config - prefer env vars, fallback to auto-detect
set PROJECT_ROOT=%~dp0
set BUILD_DIR=%PROJECT_ROOT%build\Desktop_Qt_6_10_3_MSVC2022_64bit-Release
set DEPLOY_DIR=%PROJECT_ROOT%deploy

:: Qt path: prefer QT_DIR env var, fallback to default install paths
if defined QT_DIR (
    set QT_DIR=%QT_DIR%
) else if exist "F:\QT\6.10.3\msvc2022_64\bin\windeployqt.exe" (
    set QT_DIR=F:\QT\6.10.3\msvc2022_64
) else if exist "C:\Qt\6.10.3\msvc2022_64\bin\windeployqt.exe" (
    set QT_DIR=C:\Qt\6.10.3\msvc2022_64
) else if exist "D:\Qt\6.10.3\msvc2022_64\bin\windeployqt.exe" (
    set QT_DIR=D:\Qt\6.10.3\msvc2022_64
)
set WINDEPLOYQT=%QT_DIR%\bin\windeployqt.exe

:: VS env: prefer VSDEVCMD env var, then vswhere auto-detect, then fallback to known paths
if defined VSDEVCMD (
    set VSDEVCMD=%VSDEVCMD%
) else (
    for /f "usebackq tokens=*" %%i in (`where vswhere 2^>nul`) do set VSWHERE=%%i
    if defined VSWHERE (
        for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -property installationPath`) do (
            set VSDEVCMD=%%i\Common7\Tools\VsDevCmd.bat
        )
    )
)
if not defined VSDEVCMD (
    if exist "D:\Applications\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" (
        set VSDEVCMD=D:\Applications\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" (
        set VSDEVCMD=C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat" (
        set VSDEVCMD=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" (
        set VSDEVCMD=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat
    )
)

echo ========================================
echo  EasyChat Release Build ^& Deploy Script
echo  PROJECT_ROOT: %PROJECT_ROOT%
echo  QT_DIR:       %QT_DIR%
echo ========================================

:: 1. Check VS env script
if not exist "%VSDEVCMD%" (
    echo [ERROR] Cannot find VsDevCmd.bat, please set VSDEVCMD env var
    echo         e.g.: set VSDEVCMD=D:\Applications\...\VsDevCmd.bat
    exit /b 1
)

:: 2. Load VS env and build Release
echo.
echo [1/5] Building Release ...
call "%VSDEVCMD%" -arch=amd64 >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to load VS environment
    exit /b 1
)

cmake --build "%BUILD_DIR%" --config Release --target EasyChat
if errorlevel 1 (
    echo [ERROR] Build failed
    exit /b 1
)
echo Build complete.

:: 3. Prepare deploy directory
echo.
echo [2/5] Preparing deploy directory ...
if exist "%DEPLOY_DIR%" (
    rmdir /S /Q "%DEPLOY_DIR%"
)
mkdir "%DEPLOY_DIR%"

:: 4. Copy executable and custom DLLs
echo.
echo [3/5] Copying executable and custom DLLs ...
copy /Y "%BUILD_DIR%\EasyChat.exe" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\EasyUI.dll" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\QWKCore.dll" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\QWKQuick.dll" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\QWKWidgets.dll" "%DEPLOY_DIR%\" >nul
echo Copied EasyChat.exe + DLLs.

:: 5. Run windeployqt
echo.
echo [4/5] Running windeployqt to deploy Qt dependencies ...
"%WINDEPLOYQT%" "%DEPLOY_DIR%\EasyChat.exe" --release --qmldir "%PROJECT_ROOT%." --no-translations
echo windeployqt complete.

:: 6. Copy custom QML modules (critical - windeployqt won't copy these)
echo.
echo [5/5] Copying custom QML modules and docs ...
robocopy "%BUILD_DIR%\EasyChat" "%DEPLOY_DIR%\EasyChat" /E /XD CMakeFiles *_autogen meta_types qmltypes >nul
robocopy "%BUILD_DIR%\EasyUI" "%DEPLOY_DIR%\EasyUI" /E /XD CMakeFiles *_autogen meta_types qmltypes >nul
if exist "%PROJECT_ROOT%\readme.md" copy /Y "%PROJECT_ROOT%\readme.md" "%DEPLOY_DIR%\" >nul
echo Copied EasyChat, EasyUI modules and docs.

:: 7. Done
echo.
echo ========================================
echo  Deploy complete!
echo  Output directory: %DEPLOY_DIR%
echo ========================================
pause