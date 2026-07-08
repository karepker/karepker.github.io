#! /bin/bash
set -euo pipefail

webzone_dir="$(cd "$(dirname "$0")/../"; pwd -P)"

# Local, untracked overrides for host/group/path (see deploy_local.env.example).
config="${webzone_dir}/_util/deploy_local.env"
[ -f "$config" ] && source "$config"

: "${DEPLOY_HOST:?set DEPLOY_HOST in _util/deploy_local.env}"
: "${DEPLOY_PATH:?set DEPLOY_PATH in _util/deploy_local.env}"
: "${DEPLOY_CHOWN:?set DEPLOY_CHOWN in _util/deploy_local.env}"

rsync -rptogz --info=progress2 \
  --chown="${DEPLOY_CHOWN}" --chmod=D550,F440 --delete \
  "${webzone_dir}/_site/" "${DEPLOY_HOST}:${DEPLOY_PATH}"
