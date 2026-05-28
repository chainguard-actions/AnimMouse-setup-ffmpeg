# Hardening Report: AnimMouse--setup-ffmpeg/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **AnimMouse--setup-ffmpeg/v1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags instead of immutable 40-character SHA digests. This exposes the action to supply-chain attacks if the referenced actions are compromised or their tags are moved. Failing references: `actions/cache/restore@v4`, `AnimMouse/tool-cache@v1`, `actions/cache/save@v4`.

Locations:

- `action.yaml:52`
- `action.yaml:64`
- `action.yaml:72`

### github-env-injection (severity: high)

The `inputs.version` value is assigned to the `version` environment variable (action.yaml lines 23 and 31) and then written directly to `$GITHUB_OUTPUT` in the version scripts without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can supply a `version` input containing newline characters to inject arbitrary key=value pairs into `$GITHUB_OUTPUT`, potentially overwriting subsequent step outputs or poisoning the environment. Affected writes: `echo "version=$version" >> $GITHUB_OUTPUT` in Unix-like.sh and `Add-Content $env:GITHUB_OUTPUT version=$env:version` in Windows.ps1.

Locations:

- `scripts/version/Unix-like.sh:20`
- `scripts/version/Windows.ps1:12`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed three unpinned `uses:` references in action.yaml by pinning to full SHA digests: actions/cache/restore@0057852bfaa89a56745cba8c7296529d2fc39830, AnimMouse/tool-cache@c58dc704bd326aa5d6f995afe80ac0486ec59c5e, actions/cache/save@0057852bfaa89a56745cba8c7296529d2fc39830. Fixed github-env-injection in scripts/version/Unix-like.sh by using `printf '%s' ... | tr -d '\n\r'` to sanitize version values before writing to $GITHUB_OUTPUT. Fixed github-env-injection in scripts/version/Windows.ps1 by using `-replace '[\r\n]', ''` to sanitize version values before writing to $env:GITHUB_OUTPUT.

