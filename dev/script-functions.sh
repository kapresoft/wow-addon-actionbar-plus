this_file="${(%):-%x}"
Print() {
  printf "%-9s: %-40s\n" "$1" "$2"
}
#printf "%-10s: %-40s\n", "Sourcing" "${this_file}"
Print "Sourcing" "${this_file}"

# --------------------------------------------
# vars
# --------------------------------------------
proj_dir="ActionbarPlus"
pre_release_dir="$HOME/.wow-pre-release"
dev_release_dir="$HOME/.wow-dev"
release_script="./dev/release.sh"

ADDON_NAME="${proj_dir}"
EXT_LIB="Core/ExtLib"
INTERFACE_LIB="Core/Interface"
EXT_UTIL_LIB_DIR="${EXT_LIB}/Kapresoft-LibUtil"
WOW_ACE_LIB_DIR="${EXT_LIB}/WowAce"
WOW_API_INTERFACE_LIB_DIR="${INTERFACE_LIB}/Kapresoft-Wow-Api-Interface"
WOW_LIB_UTIL_SANDBOX_HOME="$HOME/sandbox/github/kapresoft/wow/wow-lib-util"
WOW_API_INTERFACE_SANDBOX_HOME="$HOME/sandbox/github/kapresoft/wow/wow-api-interface"
PKG_META_UTIL="./dev/pkgmeta-kapresoftlibs.yaml"
PKG_META_INTERFACE="./dev/pkgmeta-kapresoftlibs-interface.yaml"

RELEASE_DIR="${dev_release_dir}"

# --------------------------------------------
# functions
# --------------------------------------------
Validate() {
  local check_file="README.md"
  if [[ ! -f "${check_file}" ]]; then
      echo "Validation failed.  Should run script in project home dir. Current dir is $(pwd)" && exit 1
  fi
}

SyncDir() {
  local src="$1"
  local dest="$2"
  local excludes="$3"

  if [ ! -d "${src}" ]; then
    echo "[ERROR] Source dir invalid: ${src}"
    return 1
  elif [ ! -d "${dest}" ]; then
    echo "[ERROR] Dest dir invalid: ${dest}"
    return 1
  fi

  if [ "${excludes}" = "" ]; then
    excludes="--exclude={'.idea','.*','*.sh'}"
  fi

  Print "Source" "${src}"
  Print "Dest" "${dest}"

  local excludes="--exclude={'.idea','.*','*.sh'}"
  local rsync_opts="--exclude ${excludes} --progress --inplace --out-format=\"[Modified: %M] %o %n%L\""
  local cmd="rsync -aucv ${rsync_opts} ${src} ${dest}"
  echo "Executing: ${cmd}"
  echo "------------------------------------"
  eval "${cmd}"
}

InitDirs() {
  if [[ ! -d "./${INTERFACE_LIB}" ]]; then
    mkdir -p ./${INTERFACE_LIB}
    echo "Creating dir: ./${INTERFACE_LIB}"
  fi
  if [[ ! -d "./${EXT_UTIL_LIB_DIR}" ]]; then
    mkdir -p ./${EXT_UTIL_LIB_DIR}
    echo "Creating dir: ./${EXT_UTIL_LIB_DIR}"
  fi
  if [[ ! -d "./${WOW_ACE_LIB_DIR}" ]]; then
    mkdir -p ./${WOW_ACE_LIB_DIR}
    echo "Creating dir: ./${WOW_ACE_LIB_DIR}"
  fi
  if [[ ! -d "./${WOW_API_INTERFACE_LIB_DIR}" ]]; then
    mkdir -p ./${WOW_API_INTERFACE_LIB_DIR}
    echo "Creating dir: ./${WOW_API_INTERFACE_LIB_DIR}"
  fi
}
