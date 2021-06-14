# terraform-upgrader script

## A script and dockerfile that can be used to do some of the legwork necessary to upgrade a repo

The script should be run from an interactive terminal within the docker container (`docker run -it <container-id> /bin/bash`)

The tool can be run within the terminal by running:
 ```
tf_upgrade.sh https://<GITHUB_USERNAME>:<GITHUB_PAT>@<GITHUB_URL>/<ORG or USER>/<REPO> \
UPGRADE_MAJOR UPGRADE_MINOR \
PRE_UPGRADE_MAJOR PRE_UPGRADE_MINOR
 ```

The tool should push a branch to the repo called `upgrade<VERSION>` that can then be used as a basis of the upgrade.

### Upgrades of 2 major versions

The tool can be used to upgrade through 2 major versions at the same time by running:
 ```
tf_upgrade.sh https://<GITHUB_USERNAME>:<GITHUB_PAT>@<GITHUB_URL>/<ORG or USER>/<REPO> \
UPGRADE_MAJOR UPGRADE_MINOR \
INTERMEDIATE_UPGRADE_MAJOR INTERMEDIATE_UPGRADE_MINOR \
PRE_UPGRADE_MAJOR PRE_UPGRADE_MINOR
 ```

The tool should then push 2 branches to the repo called `upgrade<VERSION>` that can then be used as a basis of the upgrade.
