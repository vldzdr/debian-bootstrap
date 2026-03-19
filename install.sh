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

if [[ ! -f "${LIB_DIR}/config.sh" ]]; then
    echo "Missing required file: ${LIB_DIR}/config.sh"
    exit 1
fi

# shellcheck source=lib/interactive.sh
source "${LIB_DIR}/interactive.sh"

# shellcheck source=lib/config.sh
source "${LIB_DIR}/config.sh"

prompt_for_target
prompt_for_target_user
confirm_bootstrap_settings

COMMON_MANIFEST="${SCRIPT_DIR}/manifests/common/apt-packages.txt"
TARGET_MANIFEST="${SCRIPT_DIR}/manifests/${TARGET}/apt-packages.txt"
APT_INSTALL_SCRIPT="${SCRIPT_DIR}/lib/apt.sh"

VIRTUALBOX_BASH_SNIPPET="${SCRIPT_DIR}/configs/virtualbox/bash/bash.bashrc"
SYSTEM_BASHRC="/etc/bash.bashrc"

TARGET_HOME="/home/${TARGET_USER}"
TARGET_CONFIG_DIR="${TARGET_HOME}/.config"
TARGET_OWNER="${TARGET_USER}:${TARGET_USER}"

VBOX_I3_SOURCE="${SCRIPT_DIR}/configs/virtualbox/i3/config"
VBOX_I3_TARGET="${TARGET_CONFIG_DIR}/i3/config"

VBOX_ROFI_SOURCE="${SCRIPT_DIR}/configs/virtualbox/rofi/config.rasi"
VBOX_ROFI_TARGET="${TARGET_CONFIG_DIR}/rofi/config.rasi"

VBOX_POLYBAR_CONFIG_SOURCE="${SCRIPT_DIR}/configs/virtualbox/polybar/config.ini"
VBOX_POLYBAR_CONFIG_TARGET="${TARGET_CONFIG_DIR}/polybar/config.ini"

VBOX_POLYBAR_LAUNCH_SOURCE="${SCRIPT_DIR}/configs/virtualbox/polybar/launch.sh"
VBOX_POLYBAR_LAUNCH_TARGET="${TARGET_CONFIG_DIR}/polybar/launch.sh"

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

if [[ "${TARGET}" == "virtualbox" ]]; then
    if [[ -f "${VIRTUALBOX_BASH_SNIPPET}" ]]; then
        echo
        echo "=== Deploying virtualbox bash config ==="
        deploy_managed_block "${VIRTUALBOX_BASH_SNIPPET}" "${SYSTEM_BASHRC}" "virtualbox-bashrc"
    else
        echo
        echo "No virtualbox bash config snippet found at: ${VIRTUALBOX_BASH_SNIPPET}"
    fi

    echo
    echo "=== Deploying virtualbox user configs ==="
    deploy_file "${VBOX_I3_SOURCE}" "${VBOX_I3_TARGET}" "${TARGET_OWNER}" "0644"
    deploy_file "${VBOX_ROFI_SOURCE}" "${VBOX_ROFI_TARGET}" "${TARGET_OWNER}" "0644"
    deploy_file "${VBOX_POLYBAR_CONFIG_SOURCE}" "${VBOX_POLYBAR_CONFIG_TARGET}" "${TARGET_OWNER}" "0644"
    deploy_file "${VBOX_POLYBAR_LAUNCH_SOURCE}" "${VBOX_POLYBAR_LAUNCH_TARGET}" "${TARGET_OWNER}" "0755"
fi

echo
echo "Bootstrap complete."
echo "Target: ${TARGET}"
echo "Target user: ${TARGET_USER}"
