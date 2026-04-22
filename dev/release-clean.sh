#!/usr/bin/env bash
rel_dir="./.release"

_Main() {
  local v2="$1"

  # clean release with no zip
  if [[ -d "${rel_dir}" ]]; then
    rm -rf "${rel_dir}"
  fi

  if [[ -d "${rel_dir}" ]]; then
    echo "Failed to remove release dir"
    _ls_out=$(ls -ld "${rel_dir}" 2>&1)
    echo "  $_ls_out"
    return 1
  fi
  local cmd
  if [[ $v2 = "v2" ]]; then
    cmd="./dev/release.sh -m pkgmeta-v2.yaml -dz"
  else
    cmd="./dev/release.sh -dz"
  fi
  echo "Executing: ${cmd}" && sleep 1
  eval "${cmd}"
  echo "Build Complete: ${cmd}"

}

_Main "$@"

