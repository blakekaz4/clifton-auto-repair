#!/usr/bin/env bash
set -euo pipefail

GH_BIN="/tmp/gh-cli/gh_2.67.0_macOS_$(uname -m | sed 's/x86_64/amd64/;s/arm64/arm64/')/bin/gh"
REPO_NAME="clifton-auto-repair"

if ! "$GH_BIN" auth status >/dev/null 2>&1; then
  echo "GitHub login required. Run:"
  echo "  $GH_BIN auth login --hostname github.com --git-protocol https --web"
  exit 1
fi

OWNER="$("$GH_BIN" api user -q .login)"
echo "Deploying to github.com/${OWNER}/${REPO_NAME} ..."

if "$GH_BIN" repo view "${OWNER}/${REPO_NAME}" >/dev/null 2>&1; then
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/${OWNER}/${REPO_NAME}.git"
  git push -u origin main
else
  "$GH_BIN" repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

"$GH_BIN" api -X POST "/repos/${OWNER}/${REPO_NAME}/pages" -f build_type=workflow >/dev/null 2>&1 || true

echo
echo "Site will be live at:"
echo "  https://${OWNER}.github.io/${REPO_NAME}/"
echo
echo "GitHub Pages may take 1-2 minutes to build on first deploy."
