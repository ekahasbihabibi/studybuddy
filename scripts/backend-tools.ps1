$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'toolchain.ps1')
$BackendRoot = Join-Path $ProjectRoot 'backend'

function Find-StudyBuddyPhp([string]$PhpPath) {
    if ($PhpPath) {
        if (Test-Path -LiteralPath $PhpPath) { return (Resolve-Path -LiteralPath $PhpPath).Path }
        throw "PHP tidak ditemukan pada lokasi yang diberikan: $PhpPath"
    }
    $command = Get-Command php -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    foreach ($candidate in @('C:\xampp\php\php.exe', 'D:\xampp\php\php.exe')) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    throw 'PHP tidak ditemukan. Pasang XAMPP dengan PHP 8.2+, atau berikan -PhpPath ke php.exe.'
}

function Select-StudyBuddyServerIp([string]$ServerIp) {
    if (-not $ServerIp) {
        $addresses = @(Get-NetIPConfiguration | Where-Object {
            $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up'
        } | ForEach-Object { $_.IPv4Address.IPAddress } | Where-Object {
            $_ -and $_ -notmatch '^(127\.|169\.254\.)'
        } | Select-Object -Unique)
        if ($addresses.Count -eq 1) {
            $ServerIp = $addresses[0]
        } else {
            Write-Host 'IPv4 jaringan yang terdeteksi:'
            $addresses | ForEach-Object { Write-Host "  $_" }
            $ServerIp = Read-Host 'Masukkan IPv4 Wi-Fi laptop yang satu jaringan dengan HP'
        }
    }
    $parsed = $null
    if (-not [Net.IPAddress]::TryParse($ServerIp, [ref]$parsed) -or
        $parsed.AddressFamily -ne [Net.Sockets.AddressFamily]::InterNetwork -or
        [Net.IPAddress]::IsLoopback($parsed) -or $ServerIp -match '^169\.254\.') {
        throw 'Gunakan IPv4 Wi-Fi laptop, misalnya 192.168.1.10, agar server dapat dijangkau HP.'
    }
    return $ServerIp
}
