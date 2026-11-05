param(
    [string]$FlutterRoot = '',
    [string]$AndroidSdk = '',
    [string]$JavaHome = ''
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
. (Join-Path $PSScriptRoot 'toolchain.ps1')

if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem) {
    throw 'Installer ini untuk Windows 64-bit. Lihat README untuk platform lain.'
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Pasang Git for Windows dari https://git-scm.com/downloads/win lalu buka ulang VS Code dan ulangi.'
}

$toolsRoot = Join-Path $env:LOCALAPPDATA 'StudyBuddyTools'
$downloadRoot = Join-Path $toolsRoot 'downloads'
New-Item -ItemType Directory -Force -Path $downloadRoot | Out-Null

function Save-Download([string]$Url, [string]$Destination, [string]$Sha256 = '') {
    if (-not (Test-Path -LiteralPath $Destination)) {
        $partial = "$Destination.part"
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $partial
        Move-Item -LiteralPath $partial -Destination $Destination -Force
    }
    if ($Sha256 -and (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash -ne $Sha256) {
        Remove-Item -LiteralPath $Destination -Force
        throw 'Checksum download tidak cocok. File dihapus; jalankan setup kembali.'
    }
}

# Fixed SDK matching the project's Dart 3.8.1 and existing dependencies.
Write-Host '[1/6] Menyiapkan Flutter 3.32.8...'
if (-not $FlutterRoot) {
    $flutterParent = Join-Path $toolsRoot 'flutter-3.32.8'
    $FlutterRoot = Join-Path $flutterParent 'flutter'
    if (-not (Test-Path -LiteralPath (Join-Path $FlutterRoot 'bin/flutter.bat'))) {
        $flutterZip = Join-Path $downloadRoot 'flutter-3.32.8.zip'
        Save-Download 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.32.8-stable.zip' $flutterZip '6d61d2fbb3afe68675864088937ad84b45920974b12cf71a12b4d18d02eb1186'
        Expand-Archive -LiteralPath $flutterZip -DestinationPath $flutterParent -Force
    }
}
$FlutterRoot = (Resolve-Path -LiteralPath $FlutterRoot).Path
$flutter = Join-Path $FlutterRoot 'bin/flutter.bat'
if (-not (Test-Path -LiteralPath $flutter)) { throw "Flutter tidak ditemukan: $FlutterRoot" }

Write-Host '[2/6] Menyiapkan Java Development Kit 17...'
if (-not $JavaHome) {
    $jdkRoot = Join-Path $toolsRoot 'jdk17'
    $existingJdk = Get-ChildItem -LiteralPath $jdkRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin/javac.exe') } |
        Select-Object -First 1
    if (-not $existingJdk) {
        $releases = Invoke-RestMethod -Uri 'https://api.adoptium.net/v3/assets/latest/17/hotspot?architecture=x64&image_type=jdk&os=windows&vendor=eclipse'
        $release = @($releases)[0]
        if (-not $release.binary.package.link -or -not $release.binary.package.checksum) {
            throw 'Metadata Java tidak lengkap. Ulangi atau gunakan -JavaHome ke JDK 17 yang sudah ada.'
        }
        $javaZip = Join-Path $downloadRoot $release.binary.package.name
        Save-Download $release.binary.package.link $javaZip $release.binary.package.checksum
        Expand-Archive -LiteralPath $javaZip -DestinationPath $jdkRoot -Force
        $existingJdk = Get-ChildItem -LiteralPath $jdkRoot -Directory |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin/javac.exe') } |
            Select-Object -First 1
    }
    if (-not $existingJdk) { throw 'Ekstraksi JDK gagal. Ulangi setup.' }
    $JavaHome = $existingJdk.FullName
}
$JavaHome = (Resolve-Path -LiteralPath $JavaHome).Path
if (-not (Test-Path -LiteralPath (Join-Path $JavaHome 'bin/javac.exe'))) { throw 'JavaHome harus menunjuk ke JDK 17, bukan JRE.' }
$javaRelease = Get-Content -LiteralPath (Join-Path $JavaHome 'release') -Raw
if ($javaRelease -notmatch 'JAVA_VERSION="17[\."]') { throw 'Gunakan JDK 17 untuk proyek ini.' }
$env:JAVA_HOME = $JavaHome
$env:Path = "$(Join-Path $JavaHome 'bin');$(Join-Path $FlutterRoot 'bin');$env:Path"

Write-Host '[3/6] Menyiapkan Android SDK Command-line Tools...'
if (-not $AndroidSdk) { $AndroidSdk = Join-Path $toolsRoot 'android-sdk' }
New-Item -ItemType Directory -Force -Path $AndroidSdk | Out-Null
$AndroidSdk = (Resolve-Path -LiteralPath $AndroidSdk).Path
# Setup uses CLI 12.0 for compatibility with the project's JDK 17.
$cliRoot = Join-Path $AndroidSdk 'cmdline-tools/12.0'
$sdkManager = Join-Path $cliRoot 'bin/sdkmanager.bat'
if (-not (Test-Path -LiteralPath $sdkManager)) {
    $cliZip = Join-Path $downloadRoot 'android-commandlinetools-11076708.zip'
    Save-Download 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip' $cliZip
    $cliStage = Join-Path $downloadRoot 'android-cli-extracted'
    Expand-Archive -LiteralPath $cliZip -DestinationPath $cliStage -Force
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $cliRoot) | Out-Null
    if (Test-Path -LiteralPath $cliRoot) { throw "Instalasi CLI belum lengkap. Pindahkan folder $cliRoot lalu ulangi setup." }
    Move-Item -LiteralPath (Join-Path $cliStage 'cmdline-tools') -Destination $cliRoot
}
$env:ANDROID_HOME = $AndroidSdk
$env:ANDROID_SDK_ROOT = $AndroidSdk

Write-Host '[4/6] Pasang komponen Android; baca lisensi dan jawab y jika setuju.'
& $sdkManager "--sdk_root=$AndroidSdk" --install 'platform-tools' 'platforms;android-35' 'build-tools;35.0.0' 'build-tools;34.0.0' 'ndk;27.0.12077973'
Assert-LastExitCode 'Memasang Android SDK'
& $sdkManager "--sdk_root=$AndroidSdk" --licenses
Assert-LastExitCode 'Memeriksa lisensi Android'
foreach ($component in @('platform-tools/adb.exe', 'platforms/android-35/android.jar', 'build-tools/35.0.0/aapt.exe', 'ndk/27.0.12077973/source.properties')) {
    if (-not (Test-Path -LiteralPath (Join-Path $AndroidSdk $component))) {
        throw "Komponen belum terpasang: $component. Setujui lisensi saat setup dijalankan ulang."
    }
}

Write-Host '[5/6] Menghubungkan Flutter dan VS Code...'
& $flutter config --android-sdk $AndroidSdk --jdk-dir $JavaHome
Assert-LastExitCode 'Konfigurasi Flutter'
& $flutter precache --android
Assert-LastExitCode 'Mengambil komponen Flutter Android'

@{flutterRoot = $FlutterRoot; androidSdk = $AndroidSdk; javaHome = $JavaHome} |
    ConvertTo-Json | Set-Content -LiteralPath $ToolchainFile -Encoding UTF8

# Add Flutter to user PATH. Other tool variables remain scoped to this project.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$flutterBin = Join-Path $FlutterRoot 'bin'
$otherPaths = @($userPath -split ';' | Where-Object { $_ -and $_ -ne $flutterBin })
[Environment]::SetEnvironmentVariable('Path', ((@($flutterBin) + $otherPaths) -join ';'), 'User')

$settingsPath = Join-Path $ProjectRoot '.vscode/settings.json'
$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
$settings | Add-Member -NotePropertyName 'dart.flutterSdkPath' -NotePropertyValue $FlutterRoot -Force
$settings | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $settingsPath -Encoding UTF8

Write-Host '[6/6] Mengambil dependency proyek...'
Push-Location $ProjectRoot
try {
    & $flutter pub get
    Assert-LastExitCode 'Mengambil dependency'
    & $flutter doctor -v
    Assert-LastExitCode 'Memeriksa Flutter'
} finally {
    Pop-Location
}

Write-Host ''
Write-Host 'Setup selesai. Buka ulang VS Code, pasang extension Flutter, lalu hubungkan HP dengan USB debugging.'
Write-Host 'Jalankan: powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-android.ps1'
Write-Host 'Android Studio tidak perlu dipasang. Target yang harus siap adalah Android toolchain dan HP Android.'
