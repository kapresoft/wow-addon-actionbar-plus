#!/usr/bin/env bash

SRC="$HOME/sandbox/github/kapresoft/wow/wow-lib-util/"
DEST="./Core/ExtLib/Kapresoft-LibUtilx/"

SyncExtLib() {
  local excludes="--exclude={'.idea','.*','*.sh'}"
  local cmd="rsync -aucv --exclude ${excludes} --progress --inplace --out-format=\"[Modified: %M] %o %n%L\" ${SRC} ${DEST}"
  echo "Executing: $cmd"
  eval "$cmd"
}

SyncExtLib
