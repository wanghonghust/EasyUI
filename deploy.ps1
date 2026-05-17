# EasyChat Release 构建与部署脚本
# 用法: 右键 -> 使用 PowerShell 运行，或在终端执行: .\deploy.ps1

$ErrorActionPreference = "Stop"

# 路径配置 —— 优先环境变量，回退自动检测
$ProjectRoot  = $PSScriptRoot
$BuildDir     = "$ProjectRoot\build\Desktop_Qt_6_10_3_MSVC2022_64bit-Release"
$DeployDir    = "$ProjectRoot\deploy"

# Qt 路径：优先 QT_DIR 环境变量，回退常见安装路径
$QtDir = $env:QT_DIR
if (-not $QtDir) {
    $candidates = @(
        "F:\QT\6.10.3\msvc2022_64",
        "C:\Qt\6.10.3\msvc2022_64",
        "D:\Qt\6.10.3\msvc2022_64"
    )
    foreach ($c in $candidates) {
        if (Test-Path "$c\bin\windeployqt.exe") {
            $QtDir = $c
            break
        }
    }
}
if (-not $QtDir) {
    Write-Error "找不到 Qt 安装路径，请设置 QT_DIR 环境变量"
    exit 1
}
$WinDeployQt = "$QtDir\bin\windeployqt.exe"

# VS 环境：优先 VSDEVCMD 环境变量，回退 vswhere 自动检测
$VsDevCmd = $env:VSDEVCMD
if (-not $VsDevCmd) {
    $vswhere = Get-Command vswhere -ErrorAction SilentlyContinue
    if ($vswhere) {
        $vsPath = & vswhere -latest -property installationPath 2>$null
        if ($vsPath) {
            $VsDevCmd = "$vsPath\Common7\Tools\VsDevCmd.bat"
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " EasyChat Release 构建与部署脚本" -ForegroundColor Cyan
Write-Host " ProjectRoot: $ProjectRoot" -ForegroundColor Gray
Write-Host " QtDir:      $QtDir" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan

# 1. 检查 VS 环境脚本
if (-not $VsDevCmd -or -not (Test-Path $VsDevCmd)) {
    Write-Error "找不到 VsDevCmd.bat，请设置 VSDEVCMD 环境变量"
    exit 1
}

# 2. 编译 Release
Write-Host "`n[1/5] 编译 Release ..." -ForegroundColor Yellow
$batContent = @"
@echo off
call "$VsDevCmd" -arch=amd64 >nul 2>&1
cmake --build "$BuildDir" --config Release --target EasyChat
if errorlevel 1 exit /b 1
"@
$tempBat = [System.IO.Path]::GetTempFileName() + ".bat"
[System.IO.File]::WriteAllText($tempBat, $batContent, [System.Text.Encoding]::Default)
try {
    $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $tempBat -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "编译失败"
        exit 1
    }
} finally {
    Remove-Item $tempBat -Force -ErrorAction SilentlyContinue
}
Write-Host "编译完成" -ForegroundColor Green

# 3. 准备 deploy 目录
Write-Host "`n[2/5] 准备 deploy 目录 ..." -ForegroundColor Yellow
if (Test-Path $DeployDir) {
    Remove-Item -Recurse -Force $DeployDir
}
New-Item -ItemType Directory -Path $DeployDir | Out-Null

# 4. 复制可执行文件和自定义 DLL
Write-Host "`n[3/5] 复制可执行文件和自定义 DLL ..." -ForegroundColor Yellow
$filesToCopy = @(
    "$BuildDir\EasyChat.exe",
    "$BuildDir\EasyUI.dll",
    "$BuildDir\QWKCore.dll",
    "$BuildDir\QWKQuick.dll",
    "$BuildDir\QWKWidgets.dll"
)
foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item $file $DeployDir -Force
        Write-Host "  已复制: $(Split-Path $file -Leaf)" -ForegroundColor Gray
    } else {
        Write-Warning "  文件不存在，已跳过: $file"
    }
}

# 5. 运行 windeployqt
Write-Host "`n[4/5] 运行 windeployqt 部署 Qt 依赖 ..." -ForegroundColor Yellow
& $WinDeployQt "$DeployDir\EasyChat.exe" --release --qmldir "$ProjectRoot" --no-translations
if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) {
    Write-Warning "windeployqt 返回非零退出码: $LASTEXITCODE，但通常可以忽略"
}
Write-Host "windeployqt 完成" -ForegroundColor Green

# 6. 复制自定义 QML 模块（关键！windeployqt 不会自动复制）
Write-Host "`n[5/5] 复制自定义 QML 模块 ..." -ForegroundColor Yellow
$modulesToCopy = @(
    @{ Source = "$BuildDir\EasyChat";   Target = "$DeployDir\EasyChat" },
    @{ Source = "$BuildDir\EasyUI";  Target = "$DeployDir\EasyUI" }
)
foreach ($mod in $modulesToCopy) {
    if (Test-Path $mod.Source) {
        robocopy $mod.Source $mod.Target /E /XD CMakeFiles *_autogen meta_types qmltypes /XF *.obj *.pdb *.lib *.exp *.cpp cmake_install.cmake build.ninja > $null
        Write-Host "  已复制模块: $(Split-Path $mod.Source -Leaf)" -ForegroundColor Gray
    } else {
        Write-Warning "  模块不存在: $($mod.Source)"
    }
}

# 7. 完成
Write-Host "`n========================================" -ForegroundColor Green
Write-Host " 部署完成！" -ForegroundColor Green
Write-Host " 输出目录: $DeployDir" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
