#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${REPO_DIR}/lib/config.sh"

TARGET_USER="${1:?Target user is required}"
TARGET_HOME="/home/${TARGET_USER}"
TARGET_CONFIG_DIR="${TARGET_HOME}/.config"
TARGET_OWNER="${TARGET_USER}:${TARGET_USER}"

if getent group docker >/dev/null 2>&1; then
    usermod -aG docker "${TARGET_USER}"
    echo "Added ${TARGET_USER} to docker group."
fi

BASH_SOURCE_FILE="${REPO_DIR}/configs/desktop/bash/bash.bashrc"
SYSTEM_BASHRC="/etc/bash.bashrc"

I3_SOURCE="${REPO_DIR}/configs/desktop/i3/config"
I3_TARGET="${TARGET_CONFIG_DIR}/i3/config"

ROFI_SOURCE="${REPO_DIR}/configs/desktop/rofi/config.rasi"
ROFI_TARGET="${TARGET_CONFIG_DIR}/rofi/config.rasi"

POLYBAR_CONFIG_SOURCE="${REPO_DIR}/configs/desktop/polybar/config.ini"
POLYBAR_CONFIG_TARGET="${TARGET_CONFIG_DIR}/polybar/config.ini"

POLYBAR_LAUNCH_SOURCE="${REPO_DIR}/configs/desktop/polybar/launch.sh"
POLYBAR_LAUNCH_TARGET="${TARGET_CONFIG_DIR}/polybar/launch.sh"

echo "=== Deploying desktop bash config ==="
deploy_managed_block "${BASH_SOURCE_FILE}" "${SYSTEM_BASHRC}" "desktop-bashrc"

echo
echo "=== Deploying desktop user configs ==="
deploy_file "${I3_SOURCE}" "${I3_TARGET}" "${TARGET_OWNER}" "0644"
deploy_file "${ROFI_SOURCE}" "${ROFI_TARGET}" "${TARGET_OWNER}" "0644"
deploy_file "${POLYBAR_CONFIG_SOURCE}" "${POLYBAR_CONFIG_TARGET}" "${TARGET_OWNER}" "0644"
deploy_file "${POLYBAR_LAUNCH_SOURCE}" "${POLYBAR_LAUNCH_TARGET}" "${TARGET_OWNER}" "0755"
