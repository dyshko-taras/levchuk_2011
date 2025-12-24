Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Push-Location (Split-Path -Parent $PSScriptRoot)
try {
  flutter pub run build_runner watch --delete-conflicting-outputs
} finally {
  Pop-Location
}

