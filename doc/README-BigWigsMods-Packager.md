## BigWigsMods Packager

> BigWigsMods is what packages your addon in CurseForge.  We want to be able to verify that our package works before releasing.

### Pull the repo from github

```shell
$ git@github.com:BigWigsMods/packager.git
# I'll refer to this path as PACKAGER_HOME for the purpose of this documentation.
```

### Link the script to a new name called "release-wow-addon" 

The script used here "release-wow-addon" is a link to BigWigMods/release.sh
see [PACKAGER.md](PACKAGER.md) for more details.

```shell
$ ln -s ${PACKAGER_HOME}/release.sh $HOME/bin/release-wow-addon
```

#### Check this script in a shell

```shell
l $(which release-wow-addon)

# Output
/Users/playaz/bin/release-wow-addon@ -> /Users/playaz/sandbox/github/wow/packager/release.sh
```

#### Check the script by running with a '-h' option

```shell
$ release-wow-addon -h

# Output:::
# Usage: release.sh [options]
#   -c               Skip copying files into the package directory.
#   -d               Skip uploading.
#   -e               Skip checkout of external repositories.
#   -l               Skip @localization@ keyword replacement.
#   -L               Only do @localization@ keyword replacement (skip upload to CurseForge).
#   -o               Keep existing package directory, overwriting its contents.
#   -s               Create a stripped-down "nolib" package.
#   -S               Create a package supporting multiple game types from a single TOC file.
#   -u               Use Unix line-endings.
#   -z               Skip zip file creation.
#   -t topdir        Set top-level directory of checkout.
#   -r releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
#   -p curse-id      Set the project id used on CurseForge for localization and uploading. (Use 0 to unset the TOC value)
#   -w wowi-id       Set the addon id used on WoWInterface for uploading. (Use 0 to unset the TOC value)
#   -a wago-id       Set the project id used on Wago Addons for uploading. (Use 0 to unset the TOC value)
#   -g game-version  Set the game version to use for uploading.
#   -m pkgmeta.yaml  Set the pkgmeta file to use.
#   -n "{template}"  Set the package zip file name and upload label. Use "-n help" for more info.
```