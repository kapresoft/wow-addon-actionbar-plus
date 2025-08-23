#!/usr/bin/env zsh
set -euo pipefail

# prevent post-substitution globbing errors (belt & suspenders)
unsetopt GLOB_SUBST
setopt NO_NOMATCH

# always run from script dir
cd "${0:A:h}"

ADDON_NAME=ActionbarPlus
COMMON_SUFFIX="/Interface/AddOns/${ADDON_NAME}"
APP_DIR="/Applications/wow"

DEST_BASES=(
  "${APP_DIR}/_classic_"
  "${APP_DIR}/_classic_era_"
  "${APP_DIR}/_retail_"
  #"${APP_DIR}/_classic_ptr_"
  #"${APP_DIR}/_classic_era_ptr_"
  #"${APP_DIR}/_classic_beta_"
  #"${APP_DIR}/_ptr_"
)

EX_PATTERNS=(
  '.*'
  '*.bak' '*.tmp' '*.yaml' '*.md'
  'Dev.toc' 'dev/' 'build/' 'doc/'
)
EXCLUDES=( "${(@)EX_PATTERNS/#/--exclude=}" )

FLAGS=( -rt --no-links --delete --delete-excluded )

# Prefer Homebrew rsync if available; override with RSYNC=/path ./script.zsh
RSYNC=${RSYNC:-/opt/homebrew/bin/rsync}
command -v "$RSYNC" >/dev/null 2>&1 || RSYNC=/usr/bin/rsync

echo "PWD is: $(pwd)"

for base in "${DEST_BASES[@]}"; do
  # ensure single slash join
  dest="${base%/}${COMMON_SUFFIX}"

  # make sure target exists (so rsync doesn't treat it as a file)
  mkdir -p "$dest"

  cmd=( "$RSYNC" "${FLAGS[@]}" "${EXCLUDES[@]}" ../ "$dest" )

  # Show exactly what will run (properly quoted)
  echo "Executing:" "${cmd[@]}"

  # Use external time, and (optionally) disable globbing on invocation
  /usr/bin/time -p "${cmd[@]}" || {
    echo "❌  Sync failed for $dest"
    exit 1
  }
  echo "✅  Sync completed for $dest"
done
