#!/usr/bin/env zsh

script_path=${(%):-%N}
real_path=${script_path:A}

#print "fpath: $fpath"
#autoload -Uz ts

ts() {
  date '+[%Y-%m-%d %H:%M:%S]'
}

p() {
  printf "%-9s: %-40s\n" "`ts`" "$1"
}



BUILD_DIR=./.release
RELEASE_SCRIPT=./dev/release.sh
TOC_FILE="setup.toc"
PKGMETA_FILE="setup.yml"
PKGMETA_FILE_V2="setupV2.yml"

p() {
  printf "%-9s: %-40s\n" "$1" "$2"
}
ensure_dir() {
  local dir="$1"

  if [[ ! -d "$dir" ]]; then
    p "Executing" "mkdir -p $dir"
    mkdir -p "$dir"
  fi
}
ensure_file() {
  local file="$1"
  [[ -f "$file" ]] && return 0
  return "$?"
}

usage() {
  print -u2 -- "Usage: ${script_path} [-v|--version 2]"
  print -u2 -- "Examples:"
  print -u2 -- "  ${script_path}               # Setup Dev APBV1 (Legacy)"
  print -u2 -- "  ${script_path} -v2           # Setup Dev ABPV2"
  print -u2 -- "  ${script_path} -v 2"
  print -u2 -- "  ${script_path} --version 2"
  print -u2 -- "  ${script_path} --version=2"
}

# Options:
# -d  Skip uploading.
# -u  Use Unix line-endings.
# -z  Skip zip file creation.
# -r  releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
# -m  pkgmeta.yaml  Set the pkgmeta file to use.
_Main() {
  emulate -L zsh
  local -a version_opt help_opt
  zparseopts -D -E \
    v:=version_opt -version:=version_opt \
    h=help_opt    -help=help_opt || {
      usage; return 1
    }
  if (( ${#help_opt} )); then
    usage
    return 1
  fi
  local build_version="${version_opt[2]#=}"
  if (( ${#version_opt} )); then
    printf 'Building for version: %s\n' ${build_version}
    if [[ ${build_version} != 2 ]]; then
      usage; return 1
    fi
  fi

  #  ======

  local opt=$1
  local pkgmeta_name="setup"

  local pkgmeta="${PKGMETA_FILE}"
  if [[ ${build_version} == 2 ]]; then
    pkgmeta="${PKGMETA_FILE_V2}"
  fi
  local pkgmeta_path="./dev/${pkgmeta}"
  p "pkgmeta_path=${pkgmeta_path}"

  ensure_dir "$BUILD_DIR"
  cp "${pkgmeta_path}" "_${pkgmeta_name}" || {
    p "Missing: ${pkgmeta_path}"
    return 1
  }
  ensure_file "./_${pkgmeta_name}" || {
    p "Missing: $file"
    return 1
  }
  cp ./dev/${TOC_FILE} _${TOC_FILE}

  local args="-duz -r ${BUILD_DIR} -m _${pkgmeta_name}"
  local cmd="${RELEASE_SCRIPT} ${args}"

  (eval "${cmd}" && p "Execution Complete: ${cmd}") || {
    p "Run failed."
    return 1
  }
  p "Cleaning up..." && {
    rm _${pkgmeta_name}
    rm _${TOC_FILE}
  }

}

# Usage: ./dev/setup or ./dev/setup v2

_Main "$@"
