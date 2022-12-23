#!/usr/bin/env zsh
# 1. Pull down libraries from source control
# 2. Extract to ~/.release dir
# 3. Sync with local dev environment

IncludeBase() {
  local fnn="script-functions.sh"
  local fn="dev/${fnn}"
  if [ -f "${fn}" ]; then
    # shellcheck disable=SC1090
    source "${fn}"
  elif [ -f "${fnn}" ]; then
    source "${fnn}"
  else
    echo "${fn} not found" && exit 1
  fi
}
IncludeBase && Validate && InitExtDir

# --------------------------------------------
# Sync Sandbox mode
# --------------------------------------------
SyncSandbox() {
  local src="${WOW_LIB_UTIL_SANDBOX_HOME}/"
  local dest="./${EXT_UTIL_LIB_DIR}/"
  echo "Pulling source from sandbox.."
  local excludes="--exclude={'.idea','.*','*.sh','*.toc','*.md','dev','External','LICENSE'}"
  SyncDir "${src}" "${dest}" "${excludes}"
}
if [[ "$1" = "sandbox" ]]; then
  SyncSandbox
  return 0
fi

# --------------------------------------------
# Sync External
# --------------------------------------------

# Use Common Release Dir
RELEASE_DIR="${dev_release_dir}"

# Source must be the same as where it is extracted in pkgmeta-kapresoftlibs.yaml
PKGMETA_EXTRACT_DIR="Core/ExtLib/Kapresoft-LibUtil"

PKGMETA="-m ${PKG_META_UTIL}"

Package() {
  local arg1=$1
  local rel_dir=$RELEASE_DIR
  # -c Skip copying files into the package directory.
  # -d Skip uploading.
  # -e Skip checkout of external repositories.
  # default: -cdzul
  # for checking debug tags: -edzul
  local rel_cmd="${release_script} ${PKGMETA} -r ${RELEASE_DIR} -cdzul $*"

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
SyncUtil() {
  local src="${RELEASE_DIR}/${ADDON_NAME}/${PKGMETA_EXTRACT_DIR}"
  local dest="${EXT_LIB}/."
  SyncDir "${src}" "${dest}"
}
#Package $*
#SyncDir $SRC $DEST
Package $* && SyncUtil