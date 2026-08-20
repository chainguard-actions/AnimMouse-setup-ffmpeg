#!/bin/sh
set -eu
if [ "$RUNNER_OS" = macOS ]
then
  if [ "$RUNNER_ARCH" = ARM64 ]
  then
    release_id=static
  else
    if [ "$version" = master ]
    then
      release_id=$(curl -s https://evermeet.cx/ffmpeg/info/ffmpeg/snapshot | jq -r .size)
    else
      release_id=$(curl -s "https://evermeet.cx/ffmpeg/info/ffmpeg/$version" | jq -r .size)
    fi
  fi
else
  release_id=$(gh api repos/BtbN/FFmpeg-Builds/releases/latest -q .id)
fi
safe_release_id=$(printf '%s' "$release_id" | tr -d '\n\r')
printf 'release_id=%s\n' "$safe_release_id" >> "$GITHUB_OUTPUT"
