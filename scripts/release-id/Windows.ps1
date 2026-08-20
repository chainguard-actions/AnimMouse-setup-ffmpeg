$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$release_id = (gh api repos/BtbN/FFmpeg-Builds/releases/latest -q .id)
$safe_release_id = $release_id -replace '[\r\n]', ''
Add-Content $env:GITHUB_OUTPUT "release_id=$safe_release_id"
