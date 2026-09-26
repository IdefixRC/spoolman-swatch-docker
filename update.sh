#!/bin/sh
# Install, or update to, the latest upstream release of spoolman-filament-swatch.
# Safe to run from cron; it does nothing when the latest release is already deployed.
set -eu
cd "$(dirname "$0")"

[ -f .env ] || cp .env.example .env

latest=$(curl -fsSL https://api.github.com/repos/Disane87/spoolman-filament-swatch/releases/latest \
  | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
current=$(sed -n 's/^SWATCH_VERSION=//p' .env)

if [ -z "$latest" ]; then
  echo "$(date -Is) could not read the latest release tag" >&2
  exit 1
fi
if [ "$latest" = "$current" ] && docker image inspect "spoolman-swatch:$current" >/dev/null 2>&1; then
  echo "$(date -Is) up to date at $current"
  exit 0
fi

echo "$(date -Is) deploying ${current:-nothing} -> $latest"
# Build first, and only record the new version once the build has succeeded,
# so a broken release leaves the running container and .env untouched.
SWATCH_VERSION="$latest" docker compose build
if grep -q '^SWATCH_VERSION=' .env; then
  sed -i "s/^SWATCH_VERSION=.*/SWATCH_VERSION=$latest/" .env
else
  echo "SWATCH_VERSION=$latest" >> .env
fi
docker compose up -d
docker image prune -f
