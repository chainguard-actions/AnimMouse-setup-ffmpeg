<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--setup-ffmpeg/v1.2.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--setup-ffmpeg/v1.2.5** was hardened automatically. 11 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

action.yaml composite steps use mutable tag refs instead of full commit SHAs: 'uses: actions/cache/restore@v5', 'uses: AnimMouse/tool-cache@v1', 'uses: actions/cache/save@v5'.

Locations:

- `action.yaml:54`
- `action.yaml:76`
- `action.yaml:83`

### github-env-injection (severity: high)

Step 'Get FFmpeg version for Unix-like' runs scripts/version/Unix-like.sh. That script writes the workflow-controlled env var $version (from inputs.version) to $GITHUB_OUTPUT without sanitizing it first: 'echo "version=$version" >> $GITHUB_OUTPUT'. It also writes remotely fetched $latest_release the same way. A newline in the value would inject extra outputs. Fix: run printf '%s' ... | tr -d '\n\r' on the value before the write.

Locations:

- `scripts/version/Unix-like.sh:23`
- `scripts/version/Unix-like.sh:21`
- `action.yaml:21`

### github-env-injection (severity: high)

Step 'Get FFmpeg version for Windows' runs scripts/version/Windows.ps1. That script writes $env:version (from inputs.version) to $env:GITHUB_OUTPUT without removing newlines: 'Add-Content $env:GITHUB_OUTPUT version=$env:version'.

Locations:

- `scripts/version/Windows.ps1:11`
- `action.yaml:30`

### github-env-injection (severity: high)

scripts/release-id/Unix-like.sh writes $release_id to $GITHUB_OUTPUT unquoted and without newline stripping: 'echo release_id=$release_id >> $GITHUB_OUTPUT'. The value comes from a remote API response requested with the workflow-controlled $version.

Locations:

- `scripts/release-id/Unix-like.sh:19`
- `action.yaml:39`

### script-injection (severity: high)

Rule (b): the download and release-id scripts expand the workflow-controlled env var $version (from inputs.version / steps outputs) without double quotes. Examples: 'if [ $version = master ]', 'wget ... https://www.osxexperts.net/ffmpeg${version}arm.zip', 'wget -qO FFmpeg.7z https://evermeet.cx/ffmpeg/ffmpeg-$version.7z', 'filename=ffmpeg-n$version-...', 'wget -qO- $GITHUB_SERVER_URL/.../$filename | tar ...', 'echo ::group::Downloading FFmpeg $version ...', and in release-id 'curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/$version'.

Locations:

- `scripts/download/Unix-like.sh:3`
- `scripts/download/Unix-like.sh:10`
- `scripts/download/Unix-like.sh:15`
- `scripts/download/Unix-like.sh:25`
- `scripts/download/Unix-like.sh:34`
- `scripts/download/Unix-like.sh:35`
- `scripts/release-id/Unix-like.sh:9`
- `scripts/release-id/Unix-like.sh:13`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yaml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yaml b/action.yaml
index 0a368c9..77452ff 100644
--- a/action.yaml
+++ b/action.yaml
@@ -10,10 +10,26 @@ inputs:
   token:
     description: GitHub token to avoid API rate limiting
     default: ${{ github.token }}
-    
 runs:
   using: composite
   steps:
     - name: Get FFmpeg version for Unix-like
       id: version-unix-like
       if: runner.os == 'Linux' || runner.os == 'macOS'
@@ -22,7 +38,6 @@ runs:
       env:
         version: ${{ inputs.version }}
         GITHUB_TOKEN: ${{ inputs.token }}
-        
     - name: Get FFmpeg version for Windows
       id: version-windows
       if: runner.os == 'Windows'
@@ -31,7 +46,6 @@ runs:
       env:
         version: ${{ inputs.version }}
         GITHUB_TOKEN: ${{ inputs.token }}
-        
     - name: Get FFmpeg release ID for Unix-like
       id: release-id-unix-like
       if: runner.os == 'Linux' || runner.os == 'macOS'
@@ -40,7 +54,6 @@ runs:
       env:
         version: ${{ steps.version-unix-like.outputs.version }}
         GITHUB_TOKEN: ${{ inputs.token }}
-        
     - name: Get FFmpeg release ID for Windows
       id: release-id-windows
       if: runner.os == 'Windows'
@@ -48,14 +61,12 @@ runs:
       run: '& $env:GITHUB_ACTION_PATH\scripts\release-id\Windows.ps1'
       env:
         GITHUB_TOKEN: ${{ inputs.token }}
-        
     - name: Restore FFmpeg cache
       id: cache
       uses: actions/cache/restore@v5
       with:
         path: ${{ runner.tool_cache }}/FFmpeg
         key: FFmpeg-${{ steps.version-unix-like.outputs.version || steps.version-windows.outputs.version }}-${{ steps.release-id-unix-like.outputs.release_id || steps.release-id-windows.outputs.release_id }}-${{ runner.os }}-${{ runner.arch }}
-        
     - name: Download FFmpeg for Unix-like
       if: (runner.os == 'Linux' || runner.os == 'macOS') && ! steps.cache.outputs.cache-hit
       shell: bash
@@ -63,7 +74,6 @@ runs:
       run: $GITHUB_ACTION_PATH/scripts/download/Unix-like.sh
       env:
         version: ${{ steps.version-unix-like.outputs.version }}
-        
     - name: Download FFmpeg for Windows
       if: runner.os == 'Windows' && ! steps.cache.outputs.cache-hit
       shell: pwsh
@@ -71,16 +81,14 @@ runs:
       run: '& $env:GITHUB_ACTION_PATH\scripts\download\Windows.ps1'
       env:
         version: ${{ steps.version-windows.outputs.version }}
-        
     - name: Install FFmpeg on tool cache
       uses: AnimMouse/tool-cache@v1
       with:
         folder_name: FFmpeg
         cache_hit: ${{ steps.cache.outputs.cache-hit }}
-        
     - name: Save FFmpeg cache
       if: '! steps.cache.outputs.cache-hit'
       uses: actions/cache/save@v5
       with:
         path: ${{ runner.tool_cache }}/FFmpeg
-        key: FFmpeg-${{ steps.version-unix-like.outputs.version || steps.version-windows.outputs.version }}-${{ steps.release-id-unix-like.outputs.release_id || steps.release-id-windows.outputs.release_id }}-${{ runner.os }}-${{ runner.arch }}
\ No newline at end of file
+        key: FFmpeg-${{ steps.version-unix-like.outputs.version || steps.version-windows.outputs.version }}-${{ steps.release-id-unix-like.outputs.release_id || steps.release-id-windows.outputs.release_id }}-${{ runner.os }}-${{ runner.arch }}

```

Locations:

- `action.yaml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed scripts/download/Unix-like.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/scripts/download/Unix-like.sh b/scripts/download/Unix-like.sh
index 0266b02..f2f64f6 100755
--- a/scripts/download/Unix-like.sh
+++ b/scripts/download/Unix-like.sh
@@ -1,37 +1,37 @@
 #!/bin/sh
 set -eu
-echo ::group::Downloading FFmpeg $version for $RUNNER_OS $RUNNER_ARCH
+echo "::group::Downloading FFmpeg $version for $RUNNER_OS $RUNNER_ARCH"
 mkdir FFmpeg
-if [ $RUNNER_OS = macOS ]
+if [ "$RUNNER_OS" = macOS ]
 then
-  if [ $RUNNER_ARCH = ARM64 ]
+  if [ "$RUNNER_ARCH" = ARM64 ]
   then
     ext=zip
-    if [ $version = master ]
+    if [ "$version" = master ]
     then
-      echo ::error::OSXExperts.NET currently does not have macOS ARM64 master builds.
+      echo "::error::OSXExperts.NET currently does not have macOS ARM64 master builds."
       exit 1
     else
-      wget -qO FFmpeg.zip -cw 10 --random-wait https://www.osxexperts.net/ffmpeg${version}arm.zip
-      wget -qO FFprobe.zip -cw 10 --random-wait https://www.osxexperts.net/ffprobe${version}arm.zip
+      wget -qO FFmpeg.zip -cw 10 --random-wait "https://www.osxexperts.net/ffmpeg${version}arm.zip"
+      wget -qO FFprobe.zip -cw 10 --random-wait "https://www.osxexperts.net/ffprobe${version}arm.zip"
     fi
   else
     ext=7z
-    if [ $version = master ]
+    if [ "$version" = master ]
     then
       wget -qO FFmpeg.7z https://evermeet.cx/ffmpeg/get
       wget -qO FFprobe.7z https://evermeet.cx/ffmpeg/get/ffprobe
     else
-      wget -qO FFmpeg.7z https://evermeet.cx/ffmpeg/ffmpeg-$version.7z
-      wget -qO FFprobe.7z https://evermeet.cx/ffprobe/ffprobe-$version.7z
+      wget -qO FFmpeg.7z "https://evermeet.cx/ffmpeg/ffmpeg-$version.7z"
+      wget -qO FFprobe.7z "https://evermeet.cx/ffprobe/ffprobe-$version.7z"
     fi
   fi
-  7z e FFmpeg.$ext ffmpeg -oFFmpeg
-  7z e FFprobe.$ext ffprobe -oFFmpeg
-  rm FFmpeg.$ext FFprobe.$ext
+  7z e "FFmpeg.$ext" ffmpeg -oFFmpeg
+  7z e "FFprobe.$ext" ffprobe -oFFmpeg
+  rm "FFmpeg.$ext" "FFprobe.$ext"
 else
-  if [ $RUNNER_ARCH = ARM64 ]; then arch=arm64; else arch=64; fi
-  if [ $version = master ]; then filename=ffmpeg-master-latest-linux$arch-gpl.tar.xz; else filename=ffmpeg-n$version-latest-linux$arch-gpl-$version.tar.xz; fi
-  wget -qO- $GITHUB_SERVER_URL/BtbN/FFmpeg-Builds/releases/download/latest/$filename | tar -xJC FFmpeg --strip-components 2 --no-anchored ffmpeg ffprobe
+  if [ "$RUNNER_ARCH" = ARM64 ]; then arch=arm64; else arch=64; fi
+  if [ "$version" = master ]; then filename=ffmpeg-master-latest-linux${arch}-gpl.tar.xz; else filename=ffmpeg-n${version}-latest-linux${arch}-gpl-${version}.tar.xz; fi
+  wget -qO- "$GITHUB_SERVER_URL/BtbN/FFmpeg-Builds/releases/download/latest/$filename" | tar -xJC FFmpeg --strip-components 2 --no-anchored ffmpeg ffprobe
 fi
-echo ::endgroup::
\ No newline at end of file
+echo "::endgroup::"

```

Locations:

- `scripts/download/Unix-like.sh`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed scripts/release-id/Unix-like.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/scripts/release-id/Unix-like.sh b/scripts/release-id/Unix-like.sh
index c4fee3b..85c5860 100755
--- a/scripts/release-id/Unix-like.sh
+++ b/scripts/release-id/Unix-like.sh
@@ -1,19 +1,20 @@
 #!/bin/sh
 set -eu
-if [ $RUNNER_OS = macOS ]
+if [ "$RUNNER_OS" = macOS ]
 then
-  if [ $RUNNER_ARCH = ARM64 ]
+  if [ "$RUNNER_ARCH" = ARM64 ]
   then
     release_id=static
   else
-    if [ $version = master ]
+    if [ "$version" = master ]
     then
       release_id=$(curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/snapshot | jq -r .size)
     else
-      release_id=$(curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/$version | jq -r .size)
+      release_id=$(curl -s "https://evermeet.cx/ffmpeg/info/ffmpeg/$version" | jq -r .size)
     fi
   fi
 else
   release_id=$(gh api repos/BtbN/FFmpeg-Builds/releases/latest -q .id)
 fi
-echo release_id=$release_id >> $GITHUB_OUTPUT
\ No newline at end of file
+safe=$(printf '%s' "$release_id" | tr -d '\n\r')
+echo "release_id=$safe" >> "$GITHUB_OUTPUT"

```

Locations:

- `scripts/release-id/Unix-like.sh`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed scripts/release-id/Windows.ps1 without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/scripts/release-id/Windows.ps1 b/scripts/release-id/Windows.ps1
index e1257e8..1ed9f11 100644
--- a/scripts/release-id/Windows.ps1
+++ b/scripts/release-id/Windows.ps1
@@ -1,4 +1,5 @@
-$ErrorActionPreference = 'Stop'
-Set-StrictMode -Version Latest
-$release_id = (gh api repos/BtbN/FFmpeg-Builds/releases/latest -q .id)
-Add-Content $env:GITHUB_OUTPUT release_id=$release_id
\ No newline at end of file
+$ErrorActionPreference = 'Stop'
+Set-StrictMode -Version Latest
+$release_id = (gh api repos/BtbN/FFmpeg-Builds/releases/latest -q .id)
+$safe = ($release_id -replace '[\r\n]', '')
+Add-Content $env:GITHUB_OUTPUT "release_id=$safe"

```

Locations:

- `scripts/release-id/Windows.ps1`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed scripts/version/Unix-like.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/scripts/version/Unix-like.sh b/scripts/version/Unix-like.sh
index 32dbc55..571c317 100755
--- a/scripts/version/Unix-like.sh
+++ b/scripts/version/Unix-like.sh
@@ -2,9 +2,9 @@
 set -eu
 if [ "$version" = release ]
 then
-  if [ $RUNNER_OS = macOS ]
+  if [ "$RUNNER_OS" = macOS ]
   then
-    if [ $RUNNER_ARCH = ARM64 ]
+    if [ "$RUNNER_ARCH" = ARM64 ]
     then
       latest_release=$(curl -s https://www.osxexperts.net | grep -o 'https://www.osxexperts.net/ffmpeg[0-9.]*arm.zip' | awk -F 'ffmpeg|arm.zip' '{print $2}')
     else
@@ -12,13 +12,15 @@ then
     fi
   else
     latest_release_linux=$(gh api repos/BtbN/FFmpeg-Builds/releases/latest -q '[.assets[].name | capture("^ffmpeg-n(?<v>[0-9]+(?:\\.[0-9]+)+)-latest-") | .v] | unique | max_by(split(".") | map(tonumber))')
-    if [ -z $latest_release_linux ]
+    if [ -z "$latest_release_linux" ]
     then
       latest_release_linux=$(curl -s https://endoflife.date/api/ffmpeg.json | jq -r .[0].cycle)
     fi
     latest_release=$latest_release_linux
   fi
-  echo "version=$latest_release" >> $GITHUB_OUTPUT
+  safe=$(printf '%s' "$latest_release" | tr -d '\n\r')
+  echo "version=$safe" >> "$GITHUB_OUTPUT"
 else
-  echo "version=$version" >> $GITHUB_OUTPUT
-fi
\ No newline at end of file
+  safe=$(printf '%s' "$version" | tr -d '\n\r')
+  echo "version=$safe" >> "$GITHUB_OUTPUT"
+fi

```

Locations:

- `scripts/version/Unix-like.sh`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed scripts/version/Windows.ps1 without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/scripts/version/Windows.ps1 b/scripts/version/Windows.ps1
index d9b344e..1d0cde2 100644
--- a/scripts/version/Windows.ps1
+++ b/scripts/version/Windows.ps1
@@ -1,12 +1,14 @@
-$ErrorActionPreference = 'Stop'
-Set-StrictMode -Version Latest
-if ($env:version -eq 'release') {
-  $latest_release = gh api repos/BtbN/FFmpeg-Builds/releases/latest -q '[.assets[].name | capture("^ffmpeg-n(?<v>[0-9]+(?:\\.[0-9]+)+)-latest-") | .v] | unique | max_by(split(".") | map(tonumber))'
-  if (-not $latest_release) {
-    $latest_release = (Invoke-RestMethod https://endoflife.date/api/ffmpeg.json)[0].cycle
-  }
-  Add-Content $env:GITHUB_OUTPUT version=$latest_release
-}
-else {
-  Add-Content $env:GITHUB_OUTPUT version=$env:version
-}
\ No newline at end of file
+$ErrorActionPreference = 'Stop'
+Set-StrictMode -Version Latest
+if ($env:version -eq 'release') {
+  $latest_release = gh api repos/BtbN/FFmpeg-Builds/releases/latest -q '[.assets[].name | capture("^ffmpeg-n(?<v>[0-9]+(?:\\.[0-9]+)+)-latest-") | .v] | unique | max_by(split(".") | map(tonumber))'
+  if (-not $latest_release) {
+    $latest_release = (Invoke-RestMethod https://endoflife.date/api/ffmpeg.json)[0].cycle
+  }
+  $safe = ($latest_release -replace '[\r\n]', '')
+  Add-Content $env:GITHUB_OUTPUT "version=$safe"
+}
+else {
+  $safe = ($env:version -replace '[\r\n]', '')
+  Add-Content $env:GITHUB_OUTPUT "version=$safe"
+}

```

Locations:

- `scripts/version/Windows.ps1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection, script-injection, prior-fix

**Notes:**

Pinned actions/cache/restore and save (v5 → caa296126883cff596d87d8935842f9db880ef25) and AnimMouse/tool-cache (v1 → c58dc704bd326aa5d6f995afe80ac0486ec59c5e) to full SHAs, with the tag kept as a trailing comment. Every GITHUB_OUTPUT write in scripts/version and scripts/release-id, both the Unix sh and Windows ps1 versions, now strips CR/LF from the value before writing it (tr -d '\n\r' in sh, -replace '[\r\n]' in PowerShell). Each value is quoted when written, and so is the $GITHUB_OUTPUT path. Every $version, $RUNNER_OS, $RUNNER_ARCH, $ext and URL/filename expansion in the download and release-id sh scripts is now double-quoted. This re-applies the previous harden's changes. The scripts keep #!/bin/sh and stay POSIX. I left the ps1 invocations in action.yaml as they were because they already use '& ...'. Nothing was run to test these changes.

