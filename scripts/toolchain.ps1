# Shared by the Windows setup, runner, and Flutter command wrapper.
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ToolchainFile = Join-Path $ProjectRoot '.studybuddy-tools.json'

function Assert-LastExitCode([string]$Step) {
    if ($LASTEXITCODE -ne 0) {
        throw "$Step gagal (exit code $LASTEXITCODE). Periksa pesan di atas lalu ulangi."
    }
}

function Use-StudyBuddyToolchain {
    if (-not (Test-Path -LiteralPath $ToolchainFile)) {
        throw 'Jalankan scripts/setup-windows.ps1 lebih dahulu.'
    }
    $toolchain = Get-Content -LiteralPath $ToolchainFile -Raw | ConvertFrom-Json
    foreach ($path in @(
        (Join-Path $toolchain.flutterRoot 'bin/flutter.bat'),
        (Join-Path $toolchain.javaHome 'bin/java.exe'),
        (Join-Path $toolchain.androidSdk 'platform-tools/adb.exe')
    )) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Tool tidak ditemukan: $path. Ulangi scripts/setup-windows.ps1."
        }
    }
    $env:JAVA_HOME = $toolchain.javaHome
    $env:ANDROID_HOME = $toolchain.androidSdk
    $env:ANDROID_SDK_ROOT = $toolchain.androidSdk
    $env:Path = @(
        (Join-Path $toolchain.flutterRoot 'bin'),
        (Join-Path $toolchain.javaHome 'bin'),
        (Join-Path $toolchain.androidSdk 'platform-tools'),
        $env:Path
    ) -join ';'
    return $toolchain
}
