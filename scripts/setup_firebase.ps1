Param(
  [string]$Platforms = "ios,android",
  [string]$OutFile = "lib/firebase_options.dart",
  [string]$Project = ""
)

$ErrorActionPreference = 'Stop'

Write-Host "Setting up FlutterFire for platforms: $Platforms" -ForegroundColor Cyan

# Ensure Flutter and Dart are available
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "Flutter is not installed or not in PATH."
}
if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
  Write-Error "Dart is not installed or not in PATH."
}

# Install flutterfire CLI if missing
if (-not (Get-Command flutterfire -ErrorAction SilentlyContinue)) {
  Write-Host "Installing flutterfire_cli..." -ForegroundColor Yellow
  dart pub global activate flutterfire_cli
}

# Add pub cache bin to PATH for current session
$pubCacheBin = Join-Path $env:USERPROFILE ".pub-cache\\bin"
if (-not ($env:PATH -like "*${pubCacheBin}*")) {
  $env:PATH = "$pubCacheBin;$env:PATH"
}

# Build flutterfire configure command
$cmd = @('flutterfire','configure','--platforms',$Platforms,'--out',$OutFile)
if ($Project -ne "") { $cmd += @('--project',$Project) }

Write-Host "Running: $($cmd -join ' ')" -ForegroundColor Cyan
& $cmd

Write-Host "FlutterFire configuration complete. Verify android/app/google-services.json and iOS plist." -ForegroundColor Green

