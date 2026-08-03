<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--setup-ffmpeg/v1.2.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--setup-ffmpeg/v1.2.5** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

action.yaml references three actions using mutable version tags instead of pinned 40-character commit SHAs. This exposes the action to supply-chain attacks if the referenced tags are moved or overwritten. Failing references: `actions/cache/restore@v5`, `AnimMouse/tool-cache@v1`, `actions/cache/save@v5`.

Locations:

- `action.yaml:44`
- `action.yaml:62`
- `action.yaml:67`

### unpinned-uses (severity: high)

.github/workflows/test.yaml references `AnimMouse/setup-ffmpeg@main` using a mutable branch name instead of a pinned 40-character commit SHA. This is vulnerable to supply-chain attacks.

Locations:

- `.github/workflows/test.yaml:42`

### permissions (severity: medium)

missing-permissions: .github/workflows/test.yaml has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad.

Locations:

- `.github/workflows/test.yaml:1`

### github-env-injection (severity: high)

scripts/version/Unix-like.sh writes the unsanitized `$version` env var (sourced from `inputs.version` via action.yaml's env block) directly to `$GITHUB_OUTPUT` without the required `printf '%s' ... | tr -d '\n\r'` sanitization step. An attacker-controlled version string containing newlines could inject arbitrary output variables. Offending line: `echo "version=$version" >> $GITHUB_OUTPUT`.

Locations:

- `scripts/version/Unix-like.sh:22`

### github-env-injection (severity: high)

scripts/version/Windows.ps1 writes the unsanitized `$env:version` (sourced from `inputs.version`) directly to `$GITHUB_OUTPUT` via `Add-Content $env:GITHUB_OUTPUT version=$env:version` without sanitization. An attacker-controlled version string containing newlines could inject arbitrary output variables.

Locations:

- `scripts/version/Windows.ps1:11`
- `scripts/version/Windows.ps1:13`

### github-env-injection (severity: high)

scripts/release-id/Unix-like.sh writes the unsanitized `$release_id` (derived from `$version`, which is sourced from `inputs.version`) to `$GITHUB_OUTPUT` via `echo release_id=$release_id >> $GITHUB_OUTPUT` without the required sanitization step. A newline-containing version value could be used to inject additional output variables.

Locations:

- `scripts/release-id/Unix-like.sh:17`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, permissions, github-env-injection

**Notes:**

Fixed all 6 findings:
1. action.yaml: Pinned actions/cache/restore@v5 → @caa296126883cff596d87d8935842f9db880ef25, AnimMouse/tool-cache@v1 → @c58dc704bd326aa5d6f995afe80ac0486ec59c5e, actions/cache/save@v5 → @caa296126883cff596d87d8935842f9db880ef25.
2. .github/workflows/test.yaml: Pinned AnimMouse/setup-ffmpeg@main → @178e0b4a408f06ce40d896c3cd79f50fa6f8b0c3 and added top-level `permissions: {}` block.
3. scripts/version/Unix-like.sh: Sanitized both $latest_release and $version with `printf '%s' ... | tr -d '\n\r'` before writing to $GITHUB_OUTPUT.
4. scripts/version/Windows.ps1: Sanitized both $latest_release and $env:version with `-replace '[\r\n]', ''` before writing to $GITHUB_OUTPUT.
5. scripts/release-id/Unix-like.sh: Sanitized $release_id with `printf '%s' ... | tr -d '\n\r'` before writing to $GITHUB_OUTPUT.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all unquoted $version shell variable expansions across three scripts:

1. scripts/download/Unix-like.sh: Quoted $version in echo statement (line 3), two if-comparisons (lines 10, 19, 28), two OSXExperts.NET URLs (lines 14-15), two evermeet.cx URLs (lines 22-23), and the final wget URL that embeds $filename (line 36).

2. scripts/release-id/Unix-like.sh: Quoted $version in the if-comparison (line 9) and in the evermeet.cx URL (line 14).

3. scripts/version/Unix-like.sh: Already had $version properly double-quoted on line 3 — no changes needed.

All $version expansions are now double-quoted, preventing shell metacharacter injection from attacker-controlled input values.

