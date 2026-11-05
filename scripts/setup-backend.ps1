param(
    [string]$PhpPath = '',
    [string]$ServerIp = '',
    [int]$Port = 8080,
    [string]$Database = 'studybuddy_app',
    [int]$DbPort = 3306,
    [string]$DbAdminUser = 'root'
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'backend-tools.ps1')
$php = Find-StudyBuddyPhp $PhpPath
$ServerIp = Select-StudyBuddyServerIp $ServerIp
if ($Port -lt 1024 -or $Port -gt 65535) { throw 'Pilih port server antara 1024 dan 65535.' }
$baseUrl = "http://${ServerIp}:$Port"

Write-Host 'Pastikan MySQL sudah Start di XAMPP Control Panel. Apache tidak diperlukan untuk alur ini.'
Write-Host "Server bersama akan memakai $baseUrl"
$securePassword = Read-Host 'Password administrator MySQL (Enter jika password root XAMPP masih kosong)' -AsSecureString
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
$settings = @{
    STUDYBUDDY_DB_HOST = '127.0.0.1'
    STUDYBUDDY_DB_PORT = $DbPort.ToString()
    STUDYBUDDY_DB_NAME = $Database
    STUDYBUDDY_DB_ADMIN_USER = $DbAdminUser
    STUDYBUDDY_DB_ADMIN_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
    STUDYBUDDY_BASE_URL = $baseUrl
    STUDYBUDDY_ENV = 'development'
}
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
$previousValues = @{}
try {
    foreach ($key in $settings.Keys) {
        $previousValues[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
        [Environment]::SetEnvironmentVariable($key, $settings[$key], 'Process')
    }
    & $php (Join-Path $BackendRoot 'bin/install.php')
    Assert-LastExitCode 'Menyiapkan database StudyBuddy'
} finally {
    foreach ($key in $previousValues.Keys) {
        [Environment]::SetEnvironmentVariable($key, $previousValues[$key], 'Process')
    }
    $settings.Remove('STUDYBUDDY_DB_ADMIN_PASSWORD')
    $securePassword.Dispose()
}

$configPath = Join-Path $ProjectRoot 'config/dev.json'
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$config | Add-Member -NotePropertyName API_BASE_URL -NotePropertyValue $baseUrl -Force
[IO.File]::WriteAllText($configPath, ($config | ConvertTo-Json -Depth 10), [Text.UTF8Encoding]::new($false))
Write-Host ''
Write-Host 'Database dan konfigurasi Flutter siap. Tidak ada akun/password demo; buat akun lewat menu Daftar.'
Write-Host 'Jalankan server: powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-backend.ps1'
Write-Host "Lalu periksa dari browser HP: $baseUrl/health.php"
Write-Host 'Jika Windows Firewall meminta izin untuk PHP, izinkan pada jaringan Private yang kamu pakai.'
