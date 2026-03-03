#!/bin/bash
set -euo pipefail

maxRetries=3
count=0

bash scripts/node.sh
bash scripts/downloader.sh
node source/override.js

cd ScramJet
pnpm install

until [ "$count" -ge "$maxRetries" ]; do
    echo "Attempt $((count + 1))..."

    set +e
    pnpm run dev
    exitCode=$?
    set -e

    if [ "$exitCode" -eq 0 ]; then
        echo "All commands completed successfully."
        exit 0
    fi

    if [ "$exitCode" -eq 130 ]; then
        echo "Dev server interrupted by user."
        exit 130
    fi

    echo "Dev server exited with code $exitCode. Retrying..."
    count=$((count + 1))
    sleep 2
done

echo "Failed after $maxRetries attempts."
exit 1
