#!/usr/bin/env bash

# Use Common Release Dir
RELEASE_DIR=~/.release
ADDON_NAME="ActionbarPlus"

Package() {
  local arg1=$1
  local rel_dir=$RELEASE_DIR
  local rel_cmd="release-wow-addon -r ${RELEASE_DIR} -cdzul $*"

  if [[ "$arg1" == "-h" ]]; then
    echo "Usage: $0 [-o]"
    echo "Options:  "
    echo "  -o to keep existing release directory"
    exit 0
  fi

  if [[ -d ${RELEASE_DIR} ]]; then
    echo "$rel_dir dir exists"
    rel_cmd="${rel_cmd}"
  fi
  echo "Executing: $rel_cmd"
  eval "$rel_cmd"
}

SyncExtLib() {
  local cmd='rsync -aucv --progress --inplace --out-format="[Modified: %M] %o %n%L" "${RELEASE_DIR}/${ADDON_NAME}/Core/ExtLib/WoWAce/" "Core/ExtLib/WoWAce/"'
  echo "Executing: $cmd"
  eval "$cmd"
}

Package $* && SyncExtLib $*