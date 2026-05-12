# Hardening Report: AnimMouse--setup-ffmpeg/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **AnimMouse--setup-ffmpeg/v1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable tags instead of full 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tags are moved or overwritten. Failing references: `actions/cache/restore@v4` (line 52), `AnimMouse/tool-cache@v1` (line 63), `actions/cache/save@v4` (line 69).

Locations:

- `action.yaml:52`
- `action.yaml:63`
- `action.yaml:69`

### github-env-injection (severity: high)

The attacker-controlled input `inputs.version` is passed via `env: version: ${{ inputs.version }}` into the shell scripts, where it is written directly to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). In `scripts/version/Unix-like.sh` (line 20), `echo "version=$version" >> $GITHUB_OUTPUT` writes the unsanitized value. In `scripts/version/Windows.ps1` (line 12), `Add-Content $env:GITHUB_OUTPUT version=$env:version` does the same. A malicious `inputs.version` value containing newlines could inject arbitrary key-value pairs into the GitHub Actions environment.

Locations:

- `scripts/version/Unix-like.sh:20`
- `scripts/version/Windows.ps1:12`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed three unpinned uses references in action.yaml: actions/cache/restore@v4 → @0057852bfaa89a56745cba8c7296529d2fc39830, AnimMouse/tool-cache@v1 → @c58dc704bd326aa5d6f995afe80ac0486ec59c5e, actions/cache/save@v4 → @0057852bfaa89a56745cba8c7296529d2fc39830. Fixed github-env-injection in scripts/version/Unix-like.sh by sanitizing both the latest_release and user-supplied version values with `printf '%s' ... | tr -d '\n\r'` before writing to $GITHUB_OUTPUT. Fixed github-env-injection in scripts/version/Windows.ps1 by sanitizing both values with `-replace '[\r\n]', ''` before writing to $GITHUB_OUTPUT.

