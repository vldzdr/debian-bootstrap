#!/usr/bin/env bash

set -euo pipefail

echo "=== Preparing desktop repositories ==="

apt update
apt install -y extrepo

if [[ -f /etc/apt/sources.list.d/extrepo_librewolf.sources ]]; then
    echo "LibreWolf repository already exists; updating it."
    extrepo update librewolf
else
    echo "Enabling LibreWolf repository."
    extrepo enable librewolf
    extrepo update librewolf
fi

apt update
