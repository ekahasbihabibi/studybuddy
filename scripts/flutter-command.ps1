# Keep all Flutter arguments, including flags such as --debug and -v.
$flutterArguments = $args
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'toolchain.ps1')
$toolchain = Use-StudyBuddyToolchain
$flutter = Join-Path $toolchain.flutterRoot 'bin/flutter.bat'
Push-Location $ProjectRoot
try {
    & $flutter @flutterArguments
    $commandExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $commandExitCode
