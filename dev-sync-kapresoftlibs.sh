#!/usr/bin/env bash

# Use Common Release Dir
RELEASE_DIR=~/.release
ADDON_NAME="ActionbarPlus"
SRC="${RELEASE_DIR}/${ADDON_NAME}/Core-Dev/ExtLib/Kapresoft-LibUtil/"
DEST="Core/ExtLib/Kapresoft-LibUtil/"
PKGMETA="-m pkgmeta-kapresoftlibs.yaml"

Package() {
  local arg1=$1
  local rel_dir=$RELEASE_DIR
  # -c Skip copying files into the package directory.
  # -d Skip uploading.
  # -e Skip checkout of external repositories.
  # default: -cdzul
  # for checking debug tags: -edzul
  local rel_cmd="release-wow-addon ${PKGMETA} -r ${RELEASE_DIR} -cdzul $*"

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

SyncKapresoftLib() {
  local cmd="rsync -aucv --exclude ${excludes} --progress --inplace --out-format=\"[Modified: %M] %o %n%L\" ${SRC} ${DEST}"

  echo "Executing: $cmd"
  echo "Source: ${SRC}"
  echo "  Dest: ${DEST}"
  eval "$cmd"
}

Package $* && SyncKapresoftLib