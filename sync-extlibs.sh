#!/usr/bin/env bash

# Usage
#   ./sync-extlibs.sh
# Overwrite .release dir
#   ./sync-extlibs.sh -o

Package() {
  local arg1=$1
  local rel_dir=./.release
  local rel_cmd="release-wow-addon -cdzul"

  if [[ "$arg1" == "-h" ]]; then
    echo "Usage: $0 [-o]"
    echo "Options:  "
    echo "  -o to keep existing ./.release directory"
    exit 0
  fi

  if [[ -d ./.release ]]; then
    echo "$rel_dir dir exists"
    if [[ "$arg1" == "-o" ]]; then
      rel_cmd="${rel_cmd}o"
    fi
  fi
  echo "Executing: $rel_cmd"
  eval "$rel_cmd"
}

SyncExtLib() {

  local cmd='rsync -aucv --progress --inplace --out-format="[Modified: %M] %o %n%L" ".release/ActionbarPlus/Core/ExtLib/WoWAce/" "Core/ExtLib/WoWAce/"'
  echo "Executing: $cmd"
  eval "$cmd"
}

Package $* && SyncExtLib $*