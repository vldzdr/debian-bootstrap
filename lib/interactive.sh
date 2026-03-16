#!/usr/bin/env bash

prompt_for_target() {
    while true; do
        echo "Select target:"
        echo "1) server"
        echo "2) virtualbox"
        echo "3) desktop"
        printf "Enter choice [1-3]: "
        read -r choice

        case "$choice" in
            1)
                TARGET="server"
                break
                ;;
            2)
                TARGET="virtualbox"
                break
                ;;
            3)
                TARGET="desktop"
                break
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

prompt_for_target_user() {
    while true; do
        printf "Enter target user: "
        read -r TARGET_USER

        if [[ -z "$TARGET_USER" ]]; then
            echo "Target user cannot be empty."
            continue
        fi

        if ! id "$TARGET_USER" >/dev/null 2>&1; then
            echo "User '$TARGET_USER' does not exist on this system."
            continue
        fi

        break
    done
}

confirm_bootstrap_settings() {
    echo
    echo "Bootstrap configuration:"
    echo "  Target: $TARGET"
    echo "  Target user: $TARGET_USER"
    echo
    printf "Continue? [y/N]: "
    read -r confirm

    case "$confirm" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            echo "Aborted."
            exit 1
            ;;
    esac
}
