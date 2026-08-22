#!/usr/bin/env bash
# deploy.sh — build and deploy spanish.mdhenderson.com
set -euo pipefail

# Always operate on the repo root, not the caller's working directory.
cd "$(dirname "${BASH_SOURCE[0]}")/.."

REMOTE="spanish.mdhenderson.com"
REMOTE_SITE="/var/www/spanish.mdhenderson.com"

echo "==> Building site..."
# --cleanDestinationDir drops output for pages that no longer exist; without it
# rsync would upload the stale file rather than delete it from the server.
hugo --gc --minify --cleanDestinationDir

echo "==> Deploying site..."
rsync -avz --delete public/ "${REMOTE}:${REMOTE_SITE}/"

echo ""
echo "Done. https://spanish.mdhenderson.com is live."
