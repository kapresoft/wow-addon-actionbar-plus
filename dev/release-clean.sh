#!/usr/bin/env zsh

rel_dir="./.release"
script_path=${(%):-%N}
real_path=${script_path:A}

ts() {
  date '+[%Y-%m-%d %H:%M:%S]'
}

p() {
  printf "%-9s: %-40s\n" "`ts`" "$1"
}

usage() {
  print -- "release-clean.sh - Run a clean addon build into ./$(basename $PWD)/.release using the"
  print -- "  BigWigsMods packager."
  print -- "Usage:"
  print -- "  release-clean.sh [options]"
  print -- "Options:"
  print -- "  -h, --help              Show this help and exit"
  print
}

_Main() {
  emulate -L zsh
  local -a help_opt

  zparseopts -D -E \
    v:=version_opt -version:=version_opt \
    h=help_opt -help=help_opt || {
      usage; return 1
    }

  if (( ${#help_opt} )); then
    usage; return 0
  fi

  local build_version="${version_opt[2]#=}"
  if (( ${#version_opt} )); then
    printf 'Building for version: %s\n' ${build_version}
    if [[ ${build_version} != 2 ]]; then
      usage; return 1
    fi
  fi

  # ------

  local -a cmd
  if [[ -d $rel_dir ]]; then
    cmd=(rm -rf -- "$rel_dir")
    p "Existing .release found."
    p "Executing: ${cmd[*]}"
    if "${cmd[@]}"; then
      p "Done: ${cmd[*]}"
    else
      p "Failed: ${cmd[*]}"
      return 1
    fi
  fi

  local ls_out

  if [[ -d $rel_dir ]]; then
    p "Failed to remove release dir: $rel_dir"
    ls_out=$(ls -ld -- "$rel_dir" 2>&1)
    p "$ls_out"
    return 1
  fi

  cmd=(./dev/release.sh -dz)
if [[ $build_version == 2 ]]; then
    cmd=(./dev/release.sh -m pkgmeta-v2.yaml -dz)
  fi

  p "Executing: ${cmd[*]}"
  if "${cmd[@]}"; then
    p "Done: ${cmd[*]}"
  else
    p "Failed: ${cmd[*]}"
    return 1
  fi
}

_Main "$@"

