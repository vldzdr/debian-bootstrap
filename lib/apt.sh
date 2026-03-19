#!/usr/bin/env bash

set -euo pipefail

MANIFEST="${1}"

if [[ ! -f "${MANIFEST}" ]]; then
    echo "Manifest file not found: ${MANIFEST}"
    exit 1
fi

echo
echo "Installing packages from manifest:"
echo "  ${MANIFEST}"
echo

PACKAGES=()

while IFS= read -r line; do
    # remove leading/trailing whitespace
    line="$(echo "$line" | xargs)"

    # skip comments and empty lines
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue

    PACKAGES+=("$line")

done < "$MANIFEST"

if [[ "${#PACKAGES[@]}" -eq 0 ]]; then
    echo "No packages found in manifest."
    exit 0
fi

echo "Packages to install:"
printf '  %s\n' "${PACKAGES[@]}"
echo

apt update
apt install -y "${PACKAGES[@]}"
