<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--setup-ffmpeg/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--setup-ffmpeg/v1** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml use mutable version tags instead of pinned 40-character SHA digests, making the action vulnerable to supply-chain attacks if those tags are moved: `actions/cache/restore@v5`, `AnimMouse/tool-cache@v1`, and `actions/cache/save@v5`.

Locations:

- `action.yaml:47`
- `action.yaml:64`
- `action.yaml:69`

### script-injection (severity: high)

Rule (b) violation: The env var `$version` (sourced from `inputs.version`, an untrusted workflow-controllable value) is expanded unquoted in multiple shell commands across the download and release-id scripts. Unquoted expansions allow shell metacharacter injection. Specific violations include: `if [ $version = master ]` (scripts/download/Unix-like.sh lines 9, 16, 33; scripts/release-id/Unix-like.sh line 9), `https://www.osxexperts.net/ffmpeg${version}arm.zip` (scripts/download/Unix-like.sh line 13), `https://evermeet.cx/ffmpeg/ffmpeg-$version.7z` (scripts/download/Unix-like.sh line 22), `filename=ffmpeg-n$version-latest-linux$arch-gpl-$version.tar.xz` (scripts/download/Unix-like.sh line 34), and `https://evermeet.cx/ffmpeg/info/ffmpeg/$version` (scripts/release-id/Unix-like.sh line 12). Additionally, `$RUNNER_OS`, `$RUNNER_ARCH`, and `$GITHUB_SERVER_URL` are used unquoted in test expressions and URLs throughout the scripts.

Locations:

- `scripts/download/Unix-like.sh:3`
- `scripts/download/Unix-like.sh:4`
- `scripts/download/Unix-like.sh:5`
- `scripts/download/Unix-like.sh:9`
- `scripts/download/Unix-like.sh:13`
- `scripts/download/Unix-like.sh:16`
- `scripts/download/Unix-like.sh:22`
- `scripts/download/Unix-like.sh:33`
- `scripts/download/Unix-like.sh:34`
- `scripts/release-id/Unix-like.sh:2`
- `scripts/release-id/Unix-like.sh:3`
- `scripts/release-id/Unix-like.sh:9`
- `scripts/release-id/Unix-like.sh:12`
- `scripts/version/Unix-like.sh:5`
- `scripts/version/Unix-like.sh:6`

### github-env-injection (severity: high)

The `$version` env var (set from `inputs.version` in action.yaml) is written directly to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' "$version" | tr -d '\n\r'`). An attacker-controlled version string containing newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT, poisoning subsequent steps. Affected writes: `echo "version=$version" >> $GITHUB_OUTPUT` in scripts/version/Unix-like.sh (else branch), and `Add-Content $env:GITHUB_OUTPUT version=$env:version` in scripts/version/Windows.ps1.

Locations:

- `scripts/version/Unix-like.sh:21`
- `scripts/version/Windows.ps1:11`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

Fixed all three findings: (1) Pinned actions/cache/restore@v5, AnimMouse/tool-cache@v1, and actions/cache/save@v5 to their full 40-character SHA digests in action.yaml. (2) Quoted all unquoted variable expansions ($version, $RUNNER_OS, $RUNNER_ARCH, $GITHUB_SERVER_URL) in test expressions and URL constructions across scripts/download/Unix-like.sh, scripts/release-id/Unix-like.sh, and scripts/version/Unix-like.sh. (3) Added newline sanitization (printf/tr -d '\n\r' for Unix, -replace '[\r\n]' for PowerShell) before writing version and release_id values to GITHUB_OUTPUT in scripts/version/Unix-like.sh, scripts/version/Windows.ps1, and scripts/release-id/Unix-like.sh.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed hardened/action/scripts/release-id/Windows.ps1: added newline sanitization before writing to $GITHUB_OUTPUT. The raw $release_id value (fetched from gh api) is now sanitized with `$safe_release_id = $release_id -replace '[\r\n]', ''` before being written as `Add-Content $env:GITHUB_OUTPUT "release_id=$safe_release_id"`. This matches the pattern already used in scripts/version/Windows.ps1 and the Unix-like counterpart (which uses `tr -d '\n\r'`), preventing an attacker-controlled API response with embedded newlines from injecting arbitrary key=value pairs into GITHUB_OUTPUT.

