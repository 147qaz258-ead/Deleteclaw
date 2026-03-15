#!/usr/bin/env bash
cd "$(dirname "$0")"
if ! command -v node >/dev/null 2>&1; then
    echo "Error: Node.js is not installed."
    read -p "Press enter to exit..."
    exit 1
fi
node index.js
read -p "Press enter to exit..."
