<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--setup-ffmpeg/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--setup-ffmpeg/v1** was hardened automatically. 8 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

action.yaml contains three `uses:` references pinned to mutable tags instead of immutable 40-character SHA commits: `actions/cache/restore@v5`, `AnimMouse/tool-cache@v1`, and `actions/cache/save@v5`. These can be silently updated by the upstream maintainer, enabling supply-chain attacks.

Locations:

- `action.yaml:53`
- `action.yaml:72`
- `action.yaml:77`

### github-env-injection (severity: high)

scripts/version/Unix-like.sh writes the `$version` env var (sourced from `inputs.version`) and `$latest_release` (from external API) directly to `$GITHUB_OUTPUT` without sanitization (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled `inputs.version` containing newlines could inject arbitrary output variables. Offending lines: `echo "version=$latest_release" >> $GITHUB_OUTPUT` and `echo "version=$version" >> $GITHUB_OUTPUT`.

Locations:

- `scripts/version/Unix-like.sh:21`
- `scripts/version/Unix-like.sh:23`

### github-env-injection (severity: high)

scripts/version/Windows.ps1 writes `$latest_release` and `$env:version` (sourced from `inputs.version`) to `$GITHUB_OUTPUT` without sanitization. An attacker-controlled `inputs.version` containing newlines could inject arbitrary output variables. Offending lines: `Add-Content $env:GITHUB_OUTPUT version=$latest_release` and `Add-Content $env:GITHUB_OUTPUT version=$env:version`.

Locations:

- `scripts/version/Windows.ps1:8`
- `scripts/version/Windows.ps1:11`

### github-env-injection (severity: high)

scripts/release-id/Unix-like.sh writes `$release_id` (derived from API responses, with `$version` from `inputs.version` used in the API URL) to `$GITHUB_OUTPUT` without sanitization (`echo release_id=$release_id >> $GITHUB_OUTPUT`). A malicious API response or attacker-controlled version string could inject newlines into the output.

Locations:

- `scripts/release-id/Unix-like.sh:16`

### github-env-injection (severity: high)

scripts/release-id/Windows.ps1 writes `$release_id` (from an API response) to `$GITHUB_OUTPUT` without sanitization (`Add-Content $env:GITHUB_OUTPUT release_id=$release_id`). A malicious API response could inject newlines into the output.

Locations:

- `scripts/release-id/Windows.ps1:4`

### script-injection (severity: high)

Rule (b): scripts/version/Unix-like.sh uses unquoted shell variable expansions of workflow-controllable env vars in test expressions and output writes. `$RUNNER_OS`, `$RUNNER_ARCH` (from `runner.*` context) and `$version` (from `inputs.version`) are expanded unquoted in `[ $RUNNER_OS = macOS ]`, `[ $RUNNER_ARCH = ARM64 ]`, `[ -z $latest_release_linux ]`, and `echo "version=$version" >> $GITHUB_OUTPUT`. Unquoted expansions allow shell metacharacter injection.

Locations:

- `scripts/version/Unix-like.sh:3`
- `scripts/version/Unix-like.sh:4`
- `scripts/version/Unix-like.sh:6`
- `scripts/version/Unix-like.sh:14`
- `scripts/version/Unix-like.sh:23`

### script-injection (severity: high)

Rule (b): scripts/release-id/Unix-like.sh uses unquoted shell variable expansions of workflow-controllable env vars. `$RUNNER_OS`, `$RUNNER_ARCH` (from `runner.*`), and `$version` (from `steps.version-unix-like.outputs.version`, itself derived from `inputs.version`) are expanded unquoted in `[ $RUNNER_OS = macOS ]`, `[ $RUNNER_ARCH = ARM64 ]`, `[ $version = master ]`, and in the URL `https://evermeet.cx/ffmpeg/info/ffmpeg/$version`. Unquoted expansions allow shell metacharacter injection.

Locations:

- `scripts/release-id/Unix-like.sh:2`
- `scripts/release-id/Unix-like.sh:3`
- `scripts/release-id/Unix-like.sh:7`
- `scripts/release-id/Unix-like.sh:9`

### script-injection (severity: high)

Rule (b): scripts/download/Unix-like.sh uses unquoted shell variable expansions of workflow-controllable env vars. `$RUNNER_OS`, `$RUNNER_ARCH` (from `runner.*`), and `$version` (from `inputs.version`) are expanded unquoted in `[ $RUNNER_OS = macOS ]`, `[ $RUNNER_ARCH = ARM64 ]`, `[ $version = master ]`, and embedded unquoted in URLs such as `https://www.osxexperts.net/ffmpeg${version}arm.zip`, `https://evermeet.cx/ffmpeg/ffmpeg-$version.7z`, and the constructed `$filename` variable. Unquoted expansions allow shell metacharacter injection.

Locations:

- `scripts/download/Unix-like.sh:4`
- `scripts/download/Unix-like.sh:5`
- `scripts/download/Unix-like.sh:10`
- `scripts/download/Unix-like.sh:14`
- `scripts/download/Unix-like.sh:18`
- `scripts/download/Unix-like.sh:30`
- `scripts/download/Unix-like.sh:31`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection, script-injection

**Notes:**

Fixed all 8 findings:
1. action.yaml: Pinned actions/cache/restore@v5 → SHA caa296126883cff596d87d8935842f9db880ef25, AnimMouse/tool-cache@v1 → SHA c58dc704bd326aa5d6f995afe80ac0486ec59c5e, actions/cache/save@v5 → SHA caa296126883cff596d87d8935842f9db880ef25.
2. scripts/version/Unix-like.sh: Quoted all variable expansions ($version, $RUNNER_OS, $RUNNER_ARCH, $latest_release_linux) to prevent shell metacharacter injection; sanitized output values with 'tr -d \n\r' before writing to $GITHUB_OUTPUT.
3. scripts/version/Windows.ps1: Sanitized $latest_release and $env:version with '-replace [\r\n], ""' before writing to $GITHUB_OUTPUT.
4. scripts/release-id/Unix-like.sh: Quoted all variable expansions ($RUNNER_OS, $RUNNER_ARCH, $version) including URL-embedded $version; sanitized release_id with 'tr -d \n\r' before writing to $GITHUB_OUTPUT.
5. scripts/release-id/Windows.ps1: Sanitized $release_id with '-replace [\r\n], ""' before writing to $GITHUB_OUTPUT.
6. scripts/download/Unix-like.sh: Quoted all variable expansions ($RUNNER_OS, $RUNNER_ARCH, $version) and all URL-embedded variables to prevent shell metacharacter injection.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions

**Notes:**

Fixed .github/workflows/test.yaml: (1) Pinned `AnimMouse/setup-ffmpeg@main` to the full commit SHA `178e0b4a408f06ce40d896c3cd79f50fa6f8b0c3` with a `# main` comment for readability. (2) Added `permissions: {}` at the top level to explicitly deny all GITHUB_TOKEN permissions, since the test workflow only runs ffmpeg/ffprobe binaries and requires no GitHub API access.

