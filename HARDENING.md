<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--setup-ffmpeg/v1.2.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--setup-ffmpeg/v1.2.5** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three composite action steps in action.yaml reference external actions using mutable version tags instead of full 40-character SHA commit digests. This exposes the action to supply-chain attacks if the referenced tags are moved or overwritten. Failing references:
- `uses: actions/cache/restore@v5` (line ~57)
- `uses: AnimMouse/tool-cache@v1` (line ~72)
- `uses: actions/cache/save@v5` (line ~78)

Locations:

- `action.yaml:57`
- `action.yaml:72`
- `action.yaml:78`

### github-env-injection (severity: high)

Multiple shell scripts write values derived from the untrusted `inputs.version` input (passed via the `$version` env var) and from external API responses directly to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled version string containing newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT, poisoning subsequent steps.

- scripts/version/Unix-like.sh: `echo "version=$version" >> $GITHUB_OUTPUT` and `echo "version=$latest_release" >> $GITHUB_OUTPUT` — both unsanitized.
- scripts/release-id/Unix-like.sh: `echo release_id=$release_id >> $GITHUB_OUTPUT` — unsanitized.
- scripts/version/Windows.ps1: `Add-Content $env:GITHUB_OUTPUT version=$latest_release` and `Add-Content $env:GITHUB_OUTPUT version=$env:version` — both unsanitized.
- scripts/release-id/Windows.ps1: `Add-Content $env:GITHUB_OUTPUT release_id=$release_id` — unsanitized.

Locations:

- `scripts/version/Unix-like.sh:20`
- `scripts/version/Unix-like.sh:22`
- `scripts/release-id/Unix-like.sh:19`
- `scripts/version/Windows.ps1:8`
- `scripts/version/Windows.ps1:11`
- `scripts/release-id/Windows.ps1:4`

### script-injection (severity: high)

Rule (b) violation: The `$version` env var (sourced from `inputs.version`, a workflow-controllable value) is expanded unquoted in multiple places in the shell scripts. An attacker-supplied version string containing shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, glob chars) could alter command execution.

Specific unquoted expansions in scripts/download/Unix-like.sh:
- Line 3: `echo ::group::Downloading FFmpeg $version for $RUNNER_OS $RUNNER_ARCH` — unquoted `$version`, `$RUNNER_OS`, `$RUNNER_ARCH`
- Line 4: `if [ $RUNNER_OS = macOS ]` — unquoted `$RUNNER_OS`
- Line 6: `if [ $RUNNER_ARCH = ARM64 ]` — unquoted `$RUNNER_ARCH`
- Line 11: `if [ $version = master ]` — unquoted `$version`
- Line 16: `https://www.osxexperts.net/ffmpeg${version}arm.zip` — unquoted `${version}` in URL
- Line 17: `https://www.osxexperts.net/ffprobe${version}arm.zip` — unquoted `${version}` in URL
- Line 22: `if [ $version = master ]` — unquoted `$version`
- Line 26: `https://evermeet.cx/ffmpeg/ffmpeg-$version.7z` — unquoted `$version` in URL
- Line 27: `https://evermeet.cx/ffprobe/ffprobe-$version.7z` — unquoted `$version` in URL
- Line 31: `if [ $RUNNER_ARCH = ARM64 ]` — unquoted `$RUNNER_ARCH`
- Line 32: `if [ $version = master ]` and `filename=ffmpeg-n$version-...` — unquoted `$version`

Similarly in scripts/version/Unix-like.sh:
- Line 3: `if [ "$version" = release ]` — this one is quoted, but line 5: `if [ $RUNNER_OS = macOS ]` — unquoted
- Line 7: `if [ $RUNNER_ARCH = ARM64 ]` — unquoted

And scripts/release-id/Unix-like.sh:
- Line 3: `if [ $RUNNER_OS = macOS ]` — unquoted
- Line 5: `if [ $RUNNER_ARCH = ARM64 ]` — unquoted
- Line 9: `if [ $version = master ]` — unquoted
- Line 13: `https://evermeet.cx/ffmpeg/info/ffmpeg/$version` — unquoted `$version` in URL

Locations:

- `scripts/download/Unix-like.sh:3`
- `scripts/download/Unix-like.sh:11`
- `scripts/download/Unix-like.sh:16`
- `scripts/download/Unix-like.sh:17`
- `scripts/download/Unix-like.sh:26`
- `scripts/download/Unix-like.sh:27`
- `scripts/download/Unix-like.sh:32`
- `scripts/version/Unix-like.sh:5`
- `scripts/version/Unix-like.sh:7`
- `scripts/release-id/Unix-like.sh:3`
- `scripts/release-id/Unix-like.sh:5`
- `scripts/release-id/Unix-like.sh:9`
- `scripts/release-id/Unix-like.sh:13`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection, script-injection

**Notes:**

Fixed all three findings:

1. unpinned-uses: Pinned all three action references in action.yaml to full 40-character SHA digests with tag comments preserved: actions/cache/restore@v5→caa296126883cff596d87d8935842f9db880ef25, AnimMouse/tool-cache@v1→c58dc704bd326aa5d6f995afe80ac0486ec59c5e, actions/cache/save@v5→caa296126883cff596d87d8935842f9db880ef25.

2. github-env-injection: Sanitized all GITHUB_OUTPUT writes in all four scripts by stripping newlines/carriage returns before writing. Used `printf '%s' "$var" | tr -d '\n\r'` pattern for shell scripts and `$var -replace '[\r\n]', ''` for PowerShell scripts.

3. script-injection: Quoted all unquoted variable expansions ($version, $RUNNER_OS, $RUNNER_ARCH) in [ ] test expressions and URL constructions across scripts/download/Unix-like.sh, scripts/version/Unix-like.sh, and scripts/release-id/Unix-like.sh.

