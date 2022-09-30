#!/usr/bin/env bash

# Use Common Release Dir
RELEASE_DIR="$HOME/.release"
ADDON_NAME="ActionbarPlus"
EXTLIB="Core/ExtLib"

Package() {
  local arg1=$1
  local rel_dir=$RELEASE_DIR
  # -c Skip copying files into the package directory.
  # -d Skip uploading.
  # -e Skip checkout of external repositories.
  # default: -cdzul
  # for checking debug tags: -edzul
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
  local src="${RELEASE_DIR}/${ADDON_NAME}/${EXTLIB}/WoWAce/"
  local dest="${EXTLIB}/WoWAce/"
  local cmd="rsync -aucv --progress --inplace --out-format=\"[Modified: %M] %o %n%L\" ${src} ${dest}"
  echo "Executing: $cmd"
  echo "Source: ${src}"
  echo "  Dest: ${dest}"
  echo "---------------"
  eval "$cmd"
}

SyncKapresoftLib() {
  local src="${RELEASE_DIR}/${ADDON_NAME}/${EXTLIB}/Kapresoft-LibUtil/"
  local dest="${EXTLIB}/Kapresoft-LibUtil/"
  local cmd="rsync -aucv --progress --inplace --out-format=\"[Modified: %M] %o %n%L\" ${src} ${dest}"
  echo "Executing: $cmd"
  echo "Source: ${src}"
  echo "  Dest: ${dest}"
  echo "---------------"
  eval "$cmd"
}

Package $* && SyncExtLib $* && SyncKapresoftLib