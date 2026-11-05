param([string]$DeviceId = '')

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'toolchain.ps1')
$toolchain = Use-StudyBuddyToolchain
$flutter = Join-Path $toolchain.flutterRoot 'bin/flutter.bat'
$adb = Join-Path $toolchain.androidSdk 'platform-tools/adb.exe'

Push-Location $ProjectRoot
try {
    & $adb start-server
    Assert-LastExitCode 'Menjalankan ADB'
    $deviceLines = @(& $adb devices)
    Assert-LastExitCode 'Mendeteksi HP'
    $devices = @($deviceLines | ForEach-Object {
        if ($_ -match '^(\S+)\s+device$') { $Matches[1] }
    })

    if ($devices.Count -eq 0) {
        $deviceLines | ForEach-Object { Write-Host $_ }
        throw 'HP belum siap. Aktifkan USB debugging, sambungkan kabel data, lalu izinkan debugging pada layar HP. Jika kosong, pasang driver USB merek HP.'
    }
    if ($DeviceId) {
        if ($devices -notcontains $DeviceId) { throw "Device '$DeviceId' belum terhubung/diizinkan." }
    } elseif ($devices.Count -eq 1) {
        $DeviceId = $devices[0]
    } else {
        Write-Host 'Perangkat Android yang terhubung:'
        for ($index = 0; $index -lt $devices.Count; $index++) {
            Write-Host "  $($index + 1). $($devices[$index])"
        }
        $selection = 0
        $answer = Read-Host 'Pilih nomor perangkat'
        if (-not [int]::TryParse($answer, [ref]$selection) -or $selection -lt 1 -or $selection -gt $devices.Count) {
            throw 'Nomor perangkat tidak valid.'
        }
        $DeviceId = $devices[$selection - 1]
    }

    & $flutter pub get
    Assert-LastExitCode 'Mengambil dependency'
    & $flutter run -d $DeviceId '--dart-define-from-file=config/dev.json'
    Assert-LastExitCode 'Menjalankan StudyBuddy'
} finally {
    Pop-Location
}
