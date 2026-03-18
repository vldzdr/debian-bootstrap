#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

if [[ "${EUID}" -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

if [[ ! -f "${LIB_DIR}/interactive.sh" ]]; then
    echo "Missing required file: ${LIB_DIR}/interactive.sh"
    exit 1
fi

# shellcheck source=lib/interactive.sh
source "${LIB_DIR}/interactive.sh"

prompt_for_target
prompt_for_target_user
confirm_bootstrap_settings

COMMON_MANIFEST="${SCRIPT_DIR}/manifests/common/apt-packages.txt"
TARGET_MANIFEST="${SCRIPT_DIR}/manifests/${TARGET}/apt-packages.txt"
APT_INSTALL_SCRIPT="${SCRIPT_DIR}/scripts/common/install_apt_packages.sh"

if [[ ! -x "${APT_INSTALL_SCRIPT}" ]]; then
    echo "Missing or non-executable script: ${APT_INSTALL_SCRIPT}"
    exit 1
fi

echo
echo "=== Installing common packages ==="
bash "${APT_INSTALL_SCRIPT}" "${COMMON_MANIFEST}"

if [[ -f "${TARGET_MANIFEST}" ]]; then
    echo
    echo "=== Installing ${TARGET} packages ==="
    bash "${APT_INSTALL_SCRIPT}" "${TARGET_MANIFEST}"
else
    echo
    echo "No target-specific package manifest found for: ${TARGET}"
fi

echo
echo "Bootstrap package installation complete."
echo "Target: ${TARGET}"
echo "Target user: ${TARGET_USER}"
