#!/usr/bin/env zsh

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

# Options:
# -d  Skip uploading.
# -u  Use Unix line-endings.
# -z  Skip zip file creation.
# -r  releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
# -m  pkgmeta.yaml  Set the pkgmeta file to use.
_Release() {
    local opt=$1
    local pkgmeta_name="setup"

    local pkgmeta="${PKGMETA_FILE}"
    if [[ "$opt" == "v2" ]]; then
      pkgmeta="${PKGMETA_FILE_V2}"
    fi
    local pkgmeta_path="./dev/${pkgmeta}"
    echo "pkgmeta_path=${pkgmeta_path}"

    ensure_dir "$BUILD_DIR"
    cp "${pkgmeta_path}" "_${pkgmeta_name}" || {
      echo "Missing: ${pkgmeta_path}"
      return 1
    }
    ensure_file "./_${pkgmeta_name}" || {
      p "Missing: $file"
      return 1
    }
    cp ./dev/${TOC_FILE} _${TOC_FILE}

    local args="-duz -r ${BUILD_DIR} -m _${pkgmeta_name}"
    local cmd="${RELEASE_SCRIPT} ${args}"
    echo "Executing: ${cmd}"
    (eval "${cmd}" && echo "Execution Complete: ${cmd}") || {
      echo "Run failed."
      return 1
    }
    echo "Cleaning up..." && {
      rm _${pkgmeta_name}
      rm _${TOC_FILE}
    }
}

_Release $*
