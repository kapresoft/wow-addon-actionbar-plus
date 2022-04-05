# Release Checklist

## PRE-Release

### README.md
- Create a new version section in [CHANGELOG.txt](../CHANGELOG.txt) file
- Outline changes

### Commit Changes and check CurseForge Build Page

## Release
> After checking that the build passed in CourseForge, clear for release

- https://authors.curseforge.com/dashboard/builds

### Create Tag and Push

**Example:**
```console
# check existing tags
$ git tag

# create tag - note that the tag will be the `@project-version` in the ActionbarPlus*.toc files
$ git tag 1.0.0

# push tags
$ git push --tags
```
### Verify CurseForge Build Page is Green (Success)

- https://authors.curseforge.com/dashboard/builds

## Post-Release

### Edit New Uploaded File info in ActionbarPlus/files section
- https://www.curseforge.com/wow/addons/actionbarplus/files
- Manually apply new file to all other versions of wow
  - hopefully this can be automated in pkgmeta.yaml in the future

### Verify Addon in CurseForge
- Verify that the new version is showing in CurseForge app
- Use an account that has the addon installed and upgrade to the new version. Note that WoW retail takes a little longer to publish


