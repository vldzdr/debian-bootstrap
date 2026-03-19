#!/usr/bin/env bash

set -euo pipefail

backup_file_once() {
    local target_file="$1"
    local backup_file="${target_file}.bak"

    if [[ -f "${target_file}" && ! -f "${backup_file}" ]]; then
        cp -a "${target_file}" "${backup_file}"
        echo "Created backup: ${backup_file}"
    fi
}

ensure_parent_dir() {
    local target_file="$1"
    local parent_dir

    parent_dir="$(dirname "${target_file}")"
    mkdir -p "${parent_dir}"
}

deploy_managed_block() {
    local source_file="$1"
    local target_file="$2"
    local block_name="$3"

    local begin_marker="# >>> debian-bootstrap:${block_name} >>>"
    local end_marker="# <<< debian-bootstrap:${block_name} <<<"

    if [[ ! -f "${source_file}" ]]; then
        echo "Managed block source file not found: ${source_file}"
        return 1
    fi

    ensure_parent_dir "${target_file}"

    if [[ ! -f "${target_file}" ]]; then
        touch "${target_file}"
    fi

    backup_file_once "${target_file}"

    local tmp_file
    tmp_file="$(mktemp)"

    awk -v begin="${begin_marker}" -v end="${end_marker}" '
        $0 == begin { in_block=1; next }
        $0 == end   { in_block=0; next }
        !in_block   { print }
    ' "${target_file}" > "${tmp_file}"

    {
        cat "${tmp_file}"
        echo
        echo "${begin_marker}"
        cat "${source_file}"
        echo "${end_marker}"
    } > "${target_file}"

    rm -f "${tmp_file}"

    echo "Deployed managed block '${block_name}' into ${target_file}"
}

deploy_file() {
    local source_file="$1"
    local target_file="$2"
    local owner="${3:-}"
    local mode="${4:-}"

    if [[ ! -f "${source_file}" ]]; then
        echo "Source file not found: ${source_file}"
        return 1
    fi

    ensure_parent_dir "${target_file}"

    if [[ -f "${target_file}" ]]; then
        backup_file_once "${target_file}"
    fi

    cp -f "${source_file}" "${target_file}"

    if [[ -n "${mode}" ]]; then
        chmod "${mode}" "${target_file}"
    fi

    if [[ -n "${owner}" ]]; then
        chown "${owner}" "${target_file}"
    fi

    echo "Deployed file: ${target_file}"
}
