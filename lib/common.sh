#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - Common Utilities & Detection
# ==============================================================================

# ANSI Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# Resolve real user and home directory (handles execution directly or through sudo)
REAL_USER="${SUDO_USER:-${USER:-$(id -un 2>/dev/null || whoami 2>/dev/null || echo "root")}}"
REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || echo "${HOME:-}")
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    REAL_HOME="${HOME:-/root}"
fi

USER_CONFIG_DIR="$REAL_HOME/.config/Antigravity IDE/User"
MARKDOWN_CSS="$USER_CONFIG_DIR/markdown-rtl.css"
SETTINGS_JSON="$USER_CONFIG_DIR/settings.json"

# Locate Antigravity Desktop App (resources/app.asar)
ANTIGRAVITY_APP_ASAR=""
find_antigravity_app() {
    if [[ -n "${ANTIGRAVITY_APP_PATH:-}" && -f "$ANTIGRAVITY_APP_PATH" ]]; then
        ANTIGRAVITY_APP_ASAR="$ANTIGRAVITY_APP_PATH"
        return 0
    fi
    local app_candidates=(
        "$REAL_HOME/.local/share/Antigravity/resources/app.asar"
        "/opt/Antigravity/resources/app.asar"
        "/usr/lib/Antigravity/resources/app.asar"
        "/Applications/Antigravity.app/Contents/Resources/app.asar"
    )
    for c in "${app_candidates[@]}"; do
        if [[ -f "$c" ]]; then
            ANTIGRAVITY_APP_ASAR="$c"
            return 0
        fi
    done
    return 1
}

# Locate Antigravity IDE application directory
APP_DIR=""
DETECTED_VIA=""
find_app_dir() {
    if [[ -n "${ANTIGRAVITY_APP_DIR:-}" && -d "$ANTIGRAVITY_APP_DIR" && -f "$ANTIGRAVITY_APP_DIR/package.json" ]]; then
        APP_DIR="$ANTIGRAVITY_APP_DIR"
        DETECTED_VIA="Environment variable ANTIGRAVITY_APP_DIR"
        return 0
    fi

    if command -v antigravity-ide &>/dev/null; then
        local cli_bin
        cli_bin=$(command -v antigravity-ide)
        if command -v readlink &>/dev/null; then
            local resolved_bin
            resolved_bin=$(readlink -f "$cli_bin" 2>/dev/null || echo "$cli_bin")
            if [[ -n "$resolved_bin" ]]; then
                cli_bin="$resolved_bin"
            fi
        fi

        local cli_dir candidate_app
        cli_dir="$(dirname "$cli_bin")"
        candidate_app="$(dirname "$cli_dir")/resources/app"

        if [[ -d "$candidate_app" && -f "$candidate_app/package.json" ]]; then
            APP_DIR="$candidate_app"
            DETECTED_VIA="PATH command 'antigravity-ide' ($cli_bin)"
            return 0
        fi
    fi

    local candidates=(
        "/opt/antigravity-ide/resources/app"
        "/usr/lib/antigravity-ide/resources/app"
        "/usr/share/antigravity-ide/resources/app"
        "$REAL_HOME/.local/share/antigravity-ide/resources/app"
        "/Applications/Antigravity IDE.app/Contents/Resources/app"
    )

    for dir in "${candidates[@]}"; do
        if [[ -n "$dir" && -d "$dir" && -f "$dir/package.json" ]]; then
            APP_DIR="$dir"
            DETECTED_VIA="Standard location ($dir)"
            return 0
        fi
    done
    return 1
}

ensure_root() {
    if [[ -n "${APP_DIR:-}" ]]; then
        local wb_dir="$APP_DIR/out/vs/workbench"
        local html_file="$APP_DIR/out/vs/code/electron-browser/workbench/workbench.html"
        local prod_file="$APP_DIR/product.json"

        if [[ ! -w "$wb_dir" || ! -w "$html_file" || ! -w "$prod_file" ]]; then
            if [[ $EUID -ne 0 ]]; then
                echo -e "${YELLOW}${M[ADMIN_REQ]}${NC}"
                echo -e "${CYAN}${M[ADMIN_ELEVATING]}${NC}"
                exec sudo -E bash "$SCRIPT_DIR/setup.sh" "--lang=$LANG_CHOICE" "--target=$TARGET_CHOICE" "${FILTERED_ARGS[@]}"
            fi
        fi
    fi
}
