#!/usr/bin/env zsh

# Sync sandbox into this workspace

IncludeBase() {
  local fnn="script-functions.sh"
  local fn="dev/${fnn}"
  if [ -f "${fn}" ]; then
    source "${fn}"
  elif [ -f "${fnn}" ]; then
    source "${fnn}"
  else
    echo "${fn} not found" && exit 1
  fi
}
IncludeBase && Validate && InitDirs

# --------------------------------------------
# Vars / Support Functions
# --------------------------------------------
SRC="${WOW_API_INTERFACE_SANDBOX_HOME}/"
DEST="./${WOW_API_INTERFACE_LIB_DIR}/"
excludes="--exclude={'.idea','.*','*.sh','*.toc','*.md','dev','External','LICENSE'}"
# --------------------------------------------
# Main
# --------------------------------------------

SyncDir "${SRC}" "${DEST}" "${excludes}"

