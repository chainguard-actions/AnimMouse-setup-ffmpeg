<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--setup-ffmpeg/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--setup-ffmpeg/v1** was hardened automatically. 3 finding(s) were identified and resolved across 4 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags rather than immutable 40-character SHA digests, making the action vulnerable to supply-chain attacks if the upstream tag is moved or overwritten:
- `actions/cache/restore@v5`
- `AnimMouse/tool-cache@v1`
- `actions/cache/save@v5`

Locations:

- `action.yaml:47`
- `action.yaml:64`
- `action.yaml:71`

### github-env-injection (severity: high)

The `inputs.version` value is passed into scripts via the `version` env var and then written directly to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' "$version" | tr -d '\n\r'`). An attacker-controlled `inputs.version` containing newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT, potentially hijacking subsequent step outputs.

In scripts/version/Unix-like.sh: `echo "version=$version" >> $GITHUB_OUTPUT` — no sanitization applied.
In scripts/version/Windows.ps1: `Add-Content $env:GITHUB_OUTPUT version=$env:version` — no sanitization applied.

Locations:

- `scripts/version/Unix-like.sh:20`
- `scripts/version/Windows.ps1:11`

### script-injection (severity: high)

Sub-rule (b): The `$version` shell variable (sourced from `inputs.version` via the `version` env var set in action.yaml) is used unquoted in multiple places in shell scripts, allowing shell metacharacter injection if a caller supplies a malicious value.

In scripts/download/Unix-like.sh:
- `if [ $version = master ]` (unquoted in test expression, lines ~10, 17, 32)
- `https://www.osxexperts.net/ffmpeg${version}arm.zip` (unquoted in URL)
- `wget -qO FFmpeg.7z https://evermeet.cx/ffmpeg/ffmpeg-$version.7z` (unquoted)
- `filename=ffmpeg-n$version-latest-linux$arch-gpl-$version.tar.xz` (unquoted)

In scripts/release-id/Unix-like.sh:
- `if [ $version = master ]` (unquoted in test expression)
- `curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/$version` (unquoted in URL)

All these should use double-quoted expansions: `"$version"`.

Locations:

- `scripts/download/Unix-like.sh:10`
- `scripts/download/Unix-like.sh:17`
- `scripts/download/Unix-like.sh:25`
- `scripts/download/Unix-like.sh:27`
- `scripts/download/Unix-like.sh:32`
- `scripts/release-id/Unix-like.sh:7`
- `scripts/release-id/Unix-like.sh:13`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection, script-injection

**Notes:**

Fixed all three findings: (1) Pinned actions/cache/restore@v5, AnimMouse/tool-cache@v1, and actions/cache/save@v5 to their full SHA digests in action.yaml. (2) Added newline sanitization (tr -d '\n\r' in sh, -replace '[\r\n]' in PowerShell) before writing version to GITHUB_OUTPUT in both version scripts. (3) Double-quoted all unquoted $version expansions in scripts/download/Unix-like.sh (test expressions and URL interpolations) and scripts/release-id/Unix-like.sh (test expression and curl URL).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted variable expansion in scripts/download/Unix-like.sh line 35. Changed `wget -qO- $GITHUB_SERVER_URL/BtbN/FFmpeg-Builds/releases/download/latest/$filename` to `wget -qO- "$GITHUB_SERVER_URL/BtbN/FFmpeg-Builds/releases/download/latest/$filename"`. The $filename variable is derived from the $version input (a workflow-controllable value), so the unquoted expansion allowed shell metacharacter injection. Double-quoting the entire URL prevents word splitting and glob expansion on attacker-controlled data.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in two scripts:
1. scripts/release-id/Unix-like.sh: Added sanitization step using `safe=$(printf '%s' "$release_id" | tr -d '\n\r')` and then writing `echo "release_id=$safe" >> "$GITHUB_OUTPUT"` instead of the raw value.
2. scripts/release-id/Windows.ps1: Added `$safe_release_id = $release_id -replace '[\r\n]', ''` before writing to GITHUB_OUTPUT, and updated the Add-Content call to use the sanitized variable.

### Iteration 4

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted shell variable expansions in [ ] test expressions across three scripts:

1. scripts/download/Unix-like.sh (lines 4, 5, 33): Quoted `$RUNNER_OS` and `$RUNNER_ARCH` → `"$RUNNER_OS"` and `"$RUNNER_ARCH"`.

2. scripts/release-id/Unix-like.sh (lines 2, 3): Quoted `$RUNNER_OS` and `$RUNNER_ARCH` → `"$RUNNER_OS"` and `"$RUNNER_ARCH"`.

3. scripts/version/Unix-like.sh (lines 4, 5, 18): Quoted `$RUNNER_OS`, `$RUNNER_ARCH`, and `$latest_release_linux` → `"$RUNNER_OS"`, `"$RUNNER_ARCH"`, and `"$latest_release_linux"`.

All scripts use `#!/bin/sh` shebangs and the fixes use only POSIX-compatible double-quoting, which prevents shell metacharacter injection if these environment variables are set to attacker-controlled values.

