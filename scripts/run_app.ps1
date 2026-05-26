# Run Aayurvani when the project lives under OneDrive (avoids stale locks).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

$ephemeral = "ios\Flutter\ephemeral"
if (Test-Path $ephemeral) {
  Remove-Item -Recurse -Force $ephemeral -ErrorAction SilentlyContinue
}

flutter pub get
flutter run -d chrome @args
