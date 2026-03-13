#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SOURCE_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
AVATAR_DIR="$SOURCE_DIR/avatars"
SDDM_FACE_DIR="/usr/share/sddm/faces"
SDDM_FACE_PATH="$SDDM_FACE_DIR/$USER.face.icon"
SDDM_FACE_BACKUP="$SDDM_FACE_DIR/$USER.face.icon.bkp"

info() {
    echo ":: $*"
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

prompt_input() {
    local prompt="$1"
    local placeholder="$2"
    local value=""

    if have_cmd gum; then
        value=$(gum input --header "$prompt" --placeholder "$placeholder" || true)
    else
        read -r -p "$prompt: " value
    fi

    printf '%s\n' "$value"
}

confirm() {
    local prompt="$1"

    if have_cmd gum; then
        gum confirm "$prompt"
        return
    fi

    local reply
    read -r -p "$prompt [y/N]: " reply
    [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
}

get_real_name() {
    getent passwd "$USER" | cut -d: -f5 | cut -d, -f1
}

set_real_name() {
    local full_name="$1"

    if [ -z "$full_name" ]; then
        return
    fi

    if have_cmd chfn; then
        sudo chfn -f "$full_name" "$USER"
    else
        sudo usermod -c "$full_name" "$USER"
    fi
}

open_avatar_folder() {
    if [ ! -d "$AVATAR_DIR" ]; then
        return
    fi

    if have_cmd nautilus && { [ -n "${WAYLAND_DISPLAY:-}" ] || [ -n "${DISPLAY:-}" ]; }; then
        nautilus "$AVATAR_DIR" >/dev/null 2>&1 &
    fi
}

prompt_avatar_input() {
    local value=""
    local tty_fd

    if [ ! -d "$AVATAR_DIR" ]; then
        return
    fi

    if [ -r /dev/tty ] && [ -w /dev/tty ]; then
        exec {tty_fd}< /dev/tty
        (
            cd "$AVATAR_DIR"
            read -e -r -u "$tty_fd" -p "Avatar image (Tab completes inside ./avatars): " value
            printf '%s\n' "$value"
        )
        exec {tty_fd}<&-
        return
    fi

    read -r -p "Avatar image: " value
    printf '%s\n' "$value"
}

resolve_avatar_path() {
    local raw_path="$1"

    if [ -z "$raw_path" ]; then
        return
    fi

    if [ -f "$raw_path" ]; then
        printf '%s\n' "$raw_path"
        return
    fi

    if [ -f "$AVATAR_DIR/$raw_path" ]; then
        printf '%s\n' "$AVATAR_DIR/$raw_path"
    fi
}

install_sddm_avatar() {
    local image_path="$1"
    local temp_face

    temp_face=$(mktemp)
    cp "$image_path" "$temp_face"
    magick "$temp_face" -gravity center -crop 1:1 +repage -resize 256x256 "$temp_face"

    if [ -f "$SDDM_FACE_PATH" ]; then
        sudo install -Dm644 "$SDDM_FACE_PATH" "$SDDM_FACE_BACKUP"
    fi
    sudo install -Dm644 "$temp_face" "$SDDM_FACE_PATH"

    rm -f "$temp_face"
}

main() {
    info "Checking Git configuration..."

    GIT_NAME="$(git config --global user.name || true)"
    if [ -z "$GIT_NAME" ]; then
        info "Git user.name not set."
        GIT_NAME=$(prompt_input "Enter your Git Name (for commits)" "John Doe")
        if [ -n "$GIT_NAME" ]; then
            git config --global user.name "$GIT_NAME"
            info "Git user.name set to '$GIT_NAME'"
        fi
    fi

    GIT_EMAIL="$(git config --global user.email || true)"
    if [ -z "$GIT_EMAIL" ]; then
        info "Git user.email not set."
        GIT_EMAIL=$(prompt_input "Enter your Git Email" "john@example.com")
        if [ -n "$GIT_EMAIL" ]; then
            git config --global user.email "$GIT_EMAIL"
            info "Git user.email set to '$GIT_EMAIL'"
        fi
    fi

    REAL_NAME="$(get_real_name)"
    if [ -n "$GIT_NAME" ] && [ "$REAL_NAME" != "$GIT_NAME" ]; then
        if confirm "Set your system profile full name to '$GIT_NAME'?"; then
            set_real_name "$GIT_NAME"
            info "System profile full name updated to '$GIT_NAME'"
        fi
    fi

    if [ -d "$AVATAR_DIR" ] && [ -n "$(find "$AVATAR_DIR" -maxdepth 1 -type f | head -n 1)" ]; then
        if confirm "Set your SDDM profile image now?"; then
            info "Avatar choices live in $AVATAR_DIR"
            open_avatar_folder

            while true; do
                AVATAR_INPUT=$(prompt_avatar_input)

                if [ -z "$AVATAR_INPUT" ]; then
                    info "Skipping avatar setup."
                    break
                fi

                AVATAR_PATH="$(resolve_avatar_path "$AVATAR_INPUT" || true)"
                if [ -n "$AVATAR_PATH" ] && [ -f "$AVATAR_PATH" ]; then
                    info "Installing avatar from $AVATAR_PATH"
                    install_sddm_avatar "$AVATAR_PATH"
                    info "SDDM avatar installed at $SDDM_FACE_PATH"
                    break
                fi

                info "Could not find '$AVATAR_INPUT'. Check the filename or provide a full path."
            done
        fi
    fi

    info "Git/profile configuration complete."
}

main "$@"
