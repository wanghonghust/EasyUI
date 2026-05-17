@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: 路径配置 —— 优先环境变量，回退自动检测
set PROJECT_ROOT=%~dp0
set BUILD_DIR=%PROJECT_ROOT%build\Desktop_Qt_6_10_3_MSVC2022_64bit-Release
set DEPLOY_DIR=%PROJECT_ROOT%deploy

:: Qt 路径：优先 QT_DIR 环境变量，回退默认安装路径
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

:: VS 环境：优先 vswhere 自动检测，回退环境变量 VSDEVCMD
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

echo ========================================
echo  EasyChat Release 构建与部署脚本
echo  PROJECT_ROOT: %PROJECT_ROOT%
echo  QT_DIR:       %QT_DIR%
echo ========================================

:: 1. 检查 VS 环境脚本
if not exist "%VSDEVCMD%" (
    echo [错误] 找不到 VsDevCmd.bat，请设置 VSDEVCMD 环境变量
    echo        例如: set VSDEVCMD=D:\Applications\...\VsDevCmd.bat
    exit /b 1
)

:: 2. 加载 VS 环境并编译 Release
echo.
echo [1/5] 编译 Release ...
call "%VSDEVCMD%" -arch=amd64 >nul 2>&1
if errorlevel 1 (
    echo [错误] 加载 VS 环境失败
    exit /b 1
)

cmake --build "%BUILD_DIR%" --config Release --target EasyChat
if errorlevel 1 (
    echo [错误] 编译失败
    exit /b 1
)
echo 编译完成

:: 3. 准备 deploy 目录
echo.
echo [2/5] 准备 deploy 目录 ...
if exist "%DEPLOY_DIR%" (
    rmdir /S /Q "%DEPLOY_DIR%"
)
mkdir "%DEPLOY_DIR%"

:: 4. 复制可执行文件和自定义 DLL
echo.
echo [3/5] 复制可执行文件和自定义 DLL ...
copy /Y "%BUILD_DIR%\EasyChat.exe" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\EasyUI.dll" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\QWKCore.dll" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\QWKQuick.dll" "%DEPLOY_DIR%\" >nul
copy /Y "%BUILD_DIR%\QWKWidgets.dll" "%DEPLOY_DIR%\" >nul
echo 已复制 EasyChat.exe + DLLs

:: 5. 运行 windeployqt
echo.
echo [4/5] 运行 windeployqt 部署 Qt 依赖 ...
"%WINDEPLOYQT%" "%DEPLOY_DIR%\EasyChat.exe" --release --qmldir "%PROJECT_ROOT%" --no-translations
echo windeployqt 完成

:: 6. 复制自定义 QML 模块（关键！windeployqt 不会自动复制）
echo.
echo [5/5] 复制自定义 QML 模块和说明文档 ...
robocopy "%BUILD_DIR%\EasyChat" "%DEPLOY_DIR%\EasyChat" /E /XD CMakeFiles *_autogen meta_types qmltypes >nul
robocopy "%BUILD_DIR%\EasyUI" "%DEPLOY_DIR%\EasyUI" /E /XD CMakeFiles *_autogen meta_types qmltypes >nul
if exist "%PROJECT_ROOT%\readme.md" copy /Y "%PROJECT_ROOT%\readme.md" "%DEPLOY_DIR%\" >nul
if exist "%PROJECT_ROOT%\MarkdownView\qml\reademe.md" copy /Y "%PROJECT_ROOT%\MarkdownView\qml\reademe.md" "%DEPLOY_DIR%\" >nul
echo 已复制 EasyChat、EasyUI 模块和说明文档

:: 7. 完成
echo.
echo ========================================
echo  部署完成！
echo  输出目录: %DEPLOY_DIR%
echo ========================================
pause
