# Intellij Dev Settings

## Deployment

These are the following settings for developer deployment.

### Deployment Settings

Go to Settings, Deployment/Options or type "Options" in Settings

Exclude Items By Name:

`.svn;.cvs;.idea;.vscode;.DS_Store;.git;.hg;*.hprof;*.pyc;.github;.gitattributes;.gitignore;*.sh;dev;build;.release;_SV;Core/ExtLib/_NotDeployed;Dev.toc;pkgmeta.yaml;README.md;CHANGELOG.txt`

Or in ./idea/deployment.xml, use the follow similar setting for Mac env (Windows is similar)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="PublishConfigData" autoUpload="Always" serverName="Mac" deleteMissingItems="true" createEmptyFolders="true" exclude=".svn;.cvs;.idea;.DS_Store;.git;.hg;*.hprof;*.pyc;.github;.gitattributes;*.sh;dev;build;.release;Core/ExtLib/_NotDeployed" confirmBeforeUploading="false" confirmBeforeDeletion="false" showAutoUploadSettingsWarning="false">
    <option name="confirmBeforeDeletion" value="false" />
    <option name="confirmBeforeUploading" value="false" />
    <serverData>
      <paths name="classic-era-mac">
        <serverdata>
          <mappings>
            <mapping deploy="ActionbarPlus" local="$PROJECT_DIR$" web="/" />
          </mappings>
          <excludedPaths>
            <excludedPath local="true" path="$PROJECT_DIR$/.idea" />
            <excludedPath local="true" path="$PROJECT_DIR$/.vscode" />
            <excludedPath local="true" path="$PROJECT_DIR$/.git" />
            <excludedPath local="true" path="$PROJECT_DIR$/.github" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitattributes" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitignore" />
            <excludedPath local="true" path="$PROJECT_DIR$/Core/ExtLib/_NotDeployed" />
            <excludedPath local="true" path="$PROJECT_DIR$/package-addon.sh" />
            <excludedPath local="true" path="$PROJECT_DIR$/build" />
            <excludedPath local="true" path="$PROJECT_DIR$/dev" />
            <excludedPath local="true" path="$PROJECT_DIR$/doc" />
            <excludedPath local="true" path="$PROJECT_DIR$/_SV" />
          </excludedPaths>
        </serverdata>
      </paths>
      <paths name="classic-mac">
        <serverdata>
          <mappings>
            <mapping deploy="ActionbarPlus" local="$PROJECT_DIR$" web="/" />
          </mappings>
          <excludedPaths>
            <excludedPath local="true" path="$PROJECT_DIR$/.idea" />
            <excludedPath local="true" path="$PROJECT_DIR$/.vscode" />
            <excludedPath local="true" path="$PROJECT_DIR$/.git" />
            <excludedPath local="true" path="$PROJECT_DIR$/.github" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitattributes" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitignore" />
            <excludedPath local="true" path="$PROJECT_DIR$/.release" />
            <excludedPath local="true" path="$PROJECT_DIR$/Core/ExtLib/_NotDeployed" />
            <excludedPath local="true" path="$PROJECT_DIR$/build" />
            <excludedPath local="true" path="$PROJECT_DIR$/dev" />
            <excludedPath local="true" path="$PROJECT_DIR$/doc" />
            <excludedPath local="true" path="$PROJECT_DIR$/_SV" />
          </excludedPaths>
        </serverdata>
      </paths>
      <paths name="classic-mac-ptr">
        <serverdata>
          <mappings>
            <mapping deploy="ActionbarPlus" local="$PROJECT_DIR$" web="/" />
          </mappings>
          <excludedPaths>
            <excludedPath local="true" path="$PROJECT_DIR$/.idea" />
            <excludedPath local="true" path="$PROJECT_DIR$/.vscode" />
            <excludedPath local="true" path="$PROJECT_DIR$/.git" />
            <excludedPath local="true" path="$PROJECT_DIR$/.github" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitattributes" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitignore" />
            <excludedPath local="true" path="$PROJECT_DIR$/Core/ExtLib/_NotDeployed" />
            <excludedPath local="true" path="$PROJECT_DIR$/package-addon.sh" />
            <excludedPath local="true" path="$PROJECT_DIR$/build" />
            <excludedPath local="true" path="$PROJECT_DIR$/dev" />
            <excludedPath local="true" path="$PROJECT_DIR$/doc" />
            <excludedPath local="true" path="$PROJECT_DIR$/_SV" />
          </excludedPaths>
        </serverdata>
      </paths>
      <paths name="retail-mac">
        <serverdata>
          <mappings>
            <mapping deploy="ActionbarPlus" local="$PROJECT_DIR$" web="/" />
          </mappings>
          <excludedPaths>
            <excludedPath local="true" path="$PROJECT_DIR$/.idea" />
            <excludedPath local="true" path="$PROJECT_DIR$/.vscode" />
            <excludedPath local="true" path="$PROJECT_DIR$/.git" />
            <excludedPath local="true" path="$PROJECT_DIR$/.github" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitattributes" />
            <excludedPath local="true" path="$PROJECT_DIR$/.gitignore" />
            <excludedPath local="true" path="$PROJECT_DIR$/Core/ExtLib/_NotDeployed" />
            <excludedPath local="true" path="$PROJECT_DIR$/package-addon.sh" />
            <excludedPath local="true" path="$PROJECT_DIR$/build" />
            <excludedPath local="true" path="$PROJECT_DIR$/dev" />
            <excludedPath local="true" path="$PROJECT_DIR$/doc" />
            <excludedPath local="true" path="$PROJECT_DIR$/_SV" />
          </excludedPaths>
        </serverdata>
      </paths>
    </serverData>
    <option name="myAutoUpload" value="ALWAYS" />
  </component>
</project>
```
