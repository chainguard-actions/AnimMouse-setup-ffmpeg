$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:version -eq 'release') {
  $latest_release = gh api repos/BtbN/FFmpeg-Builds/releases/latest -q '[.assets[].name | capture("^ffmpeg-n(?<v>[0-9]+(?:\\.[0-9]+)+)-latest-") | .v] | unique | max_by(split(".") | map(tonumber))'
  if (-not $latest_release) {
    $latest_release = (Invoke-RestMethod https://endoflife.date/api/ffmpeg.json)[0].cycle
  }
  $safe_version = $latest_release -replace '[\r\n]', ''
  Add-Content $env:GITHUB_OUTPUT "version=$safe_version"
}
else {
  $safe_version = $env:version -replace '[\r\n]', ''
  Add-Content $env:GITHUB_OUTPUT "version=$safe_version"
}
