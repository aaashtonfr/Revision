#!/bin/bash
set -euo pipefail

ScramJet="./ScramJet"
Cache="$ScramJet/RevisionCache.json"
URL="https://raw.githubusercontent.com/MercuryWorkshop/scramjet/refs/heads/main/package.json"

mkdir -p "$ScramJet"

if [[ -f "$Cache" ]]; then
    localVersion=$(jq -r '.installed // "-1"' "$Cache" 2>/dev/null)
else
    localVersion="-1"
fi

remoteVersion=$(curl -s "$URL" | jq -r '.version')

if [[ -z "$remoteVersion" || "$remoteVersion" == "null" ]]; then
    echo "Failed to resolve remote ScramJet version."
    exit 1
fi

if [ "$localVersion" != "-1" ] && [ ! -d "$ScramJet/node_modules" ]; then
    pnpm --dir "$ScramJet" install
fi

if [[ "$localVersion" != "$remoteVersion" ]]; then
    echo "Version mismatch or uninitialized, reinstalling ScramJet..."

    echo '{ "precheck": { "usingAny": false, "PORT": -1 }, "PORTInfo": {} }' | jq '.' > cache.json

    if [ -d "$ScramJet/.git" ]; then
        git -C "$ScramJet" reset --hard
        git -C "$ScramJet" pull --ff-only
    else
        rm -rf "$ScramJet"
        git clone --depth 1 https://github.com/MercuryWorkshop/ScramJet.git "$ScramJet"
    fi

    echo "{ \"installed\": \"$remoteVersion\" }" | jq '.' > "$Cache"
    echo "Cloned ScramJet version $remoteVersion"
    bash scripts/ScramJetInstaller.sh
else
    echo "ScramJet is on the latest version ($localVersion)."
fi
