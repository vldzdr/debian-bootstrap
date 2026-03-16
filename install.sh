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
COMMON_INSTALL_SCRIPT="${SCRIPT_DIR}/scripts/common/install_apt_packages.sh"

bash "${COMMON_INSTALL_SCRIPT}" "${COMMON_MANIFEST}"

echo
echo "Common packages installed successfully."
