param([string]$PhpPath = '', [int]$Port = 0)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'backend-tools.ps1')
$php = Find-StudyBuddyPhp $PhpPath
$configPath = Join-Path $BackendRoot 'config.local.php'
if (-not (Test-Path -LiteralPath $configPath)) {
    throw 'Jalankan scripts/setup-backend.ps1 dahulu dan pastikan MySQL sudah aktif.'
}
$infoJson = & $php (Join-Path $BackendRoot 'bin/server-info.php') $configPath
Assert-LastExitCode 'Membaca konfigurasi backend'
$info = ($infoJson -join '') | ConvertFrom-Json
if ($info.environment -ne 'development') {
    throw 'Server ini dikonfigurasi untuk production. Gunakan Apache/Nginx + PHP dan HTTPS sesuai panduan BACKEND_SERVER.md.'
}
$address = [Uri]$info.base_url
if ($Port -eq 0) { $Port = $address.Port }
if ($Port -ne $address.Port) { throw 'Port harus sama dengan konfigurasi. Jalankan setup-backend.ps1 -Port sesuai kebutuhan.' }

Write-Host "Server StudyBuddy: $($info.base_url)"
Write-Host "Cek di browser HP: $($info.base_url)/health.php"
Write-Host 'Biarkan terminal ini tetap terbuka. Gunakan terminal kedua untuk menjalankan Flutter.'
Write-Host 'Server ini untuk pengujian pada jaringan lokal tepercaya; panduan hosting HTTPS ada di BACKEND_SERVER.md.'
$previousPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    & $php -S "0.0.0.0:$Port" -t (Join-Path $BackendRoot 'public') (Join-Path $BackendRoot 'router.php')
    $serverExitCode = $LASTEXITCODE
} finally {
    $ErrorActionPreference = $previousPreference
}
if ($serverExitCode -ne 0) { throw 'Server berhenti. Periksa apakah port dipakai aplikasi lain atau MySQL belum aktif.' }
