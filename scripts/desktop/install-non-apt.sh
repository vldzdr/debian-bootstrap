#!/usr/bin/env bash

set -euo pipefail

TARGET_USER="${1:?Target user is required}"

echo "=== Installing Joplin Desktop ==="

runuser -u "${TARGET_USER}" -- bash -c 'curl -fsSL https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash'
