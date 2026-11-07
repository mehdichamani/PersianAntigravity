#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - فارسی ساز آنتی گرویتی
# Setup & Automation Script (Modular Architecture)
# ==============================================================================
# Project: https://github.com/mehdichamani/PersianAntigravity
# Author:  Mehdi Chamani
# License: MIT
# Target:  Antigravity IDE & Antigravity App (Linux / macOS)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Language & Target argument parsing
LANG_CHOICE=""
TARGET_CHOICE=""
FILTERED_ARGS=()

for arg in "$@"; do
    case "$arg" in
        --lang=fa|-lang=fa|--fa)
            LANG_CHOICE="fa"
            ;;
        --lang=en|-lang=en|--en)
            LANG_CHOICE="en"
            ;;
        --target=*)
            TARGET_CHOICE="${arg#*=}"
            ;;
        --ide-only)
            TARGET_CHOICE="ide"
            ;;
        --app-only)
            TARGET_CHOICE="app"
            ;;
        --all)
            TARGET_CHOICE="all"
            ;;
        *)
            FILTERED_ARGS+=("$arg")
            ;;
    esac
done

first_cmd="${FILTERED_ARGS[0]:-install}"
is_help="false"
if [[ "$first_cmd" == "help" || "$first_cmd" == "--help" || "$first_cmd" == "-h" ]]; then
    is_help="true"
fi

tty_in=""
if [ -t 0 ]; then
    tty_in="stdin"
fi

if [[ -z "$LANG_CHOICE" ]]; then
    if [[ "$is_help" != "true" && -n "$tty_in" ]]; then
        echo -e "\033[1;36m======================================================================\033[0m"
        echo -e "به پروژه فارسی ساز آنتی گرویتی (PersianAntigravity) خوش آمدید!"
        echo -e "\033[1;33mاگر این متن فارسی را بدون به‌هم‌ریختگی می‌بینید، با فارسی ادامه دهید.\033[0m"
        echo -e "----------------------------------------------------------------------"
        echo -e "If the Persian text above looks garbled or broken, continue in English."
        echo -e "\033[1;36m======================================================================\033[0m"
        echo -e "  [1] فارسی (Persian) [Default]"
        echo -e "  [2] English\n"

        read -r -p "Select language / انتخاب زبان [1/2] (Default: 1): " user_input || user_input=""

        if [[ "$user_input" =~ ^[[:space:]]*2[[:space:]]*$ ]]; then
            LANG_CHOICE="en"
            echo -e "\033[1;32mEnglish selected.\033[0m\n"
        else
            LANG_CHOICE="fa"
            echo -e "\033[1;32mزبان فارسی انتخاب شد.\033[0m\n"
        fi
    else
        LANG_CHOICE="fa"
    fi
fi

# Load Modules
# shellcheck source=lib/i18n.sh
source "$SCRIPT_DIR/lib/i18n.sh"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/fonts.sh
source "$SCRIPT_DIR/lib/fonts.sh"
# shellcheck source=lib/patch-ide.sh
source "$SCRIPT_DIR/lib/patch-ide.sh"
# shellcheck source=lib/patch-app.sh
source "$SCRIPT_DIR/lib/patch-app.sh"
# shellcheck source=lib/proxy.sh
source "$SCRIPT_DIR/lib/proxy.sh"

# Interactive Target selection (if not passed as argument and not help/proxy)
if [[ -z "$TARGET_CHOICE" ]]; then
    if [[ "$is_help" != "true" && "$first_cmd" != "proxy" && "$first_cmd" != "proxy-launcher" && -n "$tty_in" ]]; then
        echo -e "${CYAN}----------------------------------------------------------------------${NC}"
        echo -e "${BOLD}${M[SELECT_TARGET_HEADER]}${NC}"
        echo -e "  ${M[TARGET_OPT_ALL]}"
        echo -e "  ${M[TARGET_OPT_IDE]}"
        echo -e "  ${M[TARGET_OPT_APP]}\n"

        read -r -p "${M[TARGET_PROMPT]}" target_input || target_input=""

        case "$target_input" in
            2)
                TARGET_CHOICE="ide"
                ;;
            3)
                TARGET_CHOICE="app"
                ;;
            *)
                TARGET_CHOICE="all"
                ;;
        esac
        echo ""
    else
        TARGET_CHOICE="all"
    fi
fi

# Locate applications
find_antigravity_app || true
find_app_dir || true

validate_ide_dir() {
    if [[ -z "$APP_DIR" ]]; then
        echo -e "${RED}${M[ERR_APP_DIR]}${NC}"
        echo -e "${YELLOW}${M[ERR_PATH_DET]}${NC}"
        echo -e "${CYAN}${M[TRB_TITLE]}${NC}"
        echo -e "${M[TRB_STEP1]}"
        echo -e "${M[TRB_STEP2]}"
        echo -e "${M[TRB_STEP3]}"
        echo -e "     ${YELLOW}export ANTIGRAVITY_APP_DIR=\"/path/to/Antigravity IDE/resources/app\"${NC}"
        echo -e "     ${YELLOW}./setup.sh install${NC}\n"
        return 1
    fi
    return 0
}

do_install() {
    check_fonts
    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "ide" ]]; then
        if validate_ide_dir; then
            ensure_root
            echo -e "${BOLD}${BLUE}${M[INST_HEADER]}${NC}"
            patch_ide
            echo ""
            echo -e "${BOLD}${GREEN}${M[INST_SUCCESS]}${NC}"
            echo -e "${CYAN}${M[INST_RESTART]}${NC}"
        elif [[ "$TARGET_CHOICE" == "ide" ]]; then
            exit 1
        fi
    fi

    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "app" ]]; then
        patch_antigravity_app
    fi
}

do_uninstall() {
    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "ide" ]]; then
        if validate_ide_dir; then
            ensure_root
            echo -e "${BOLD}${YELLOW}${M[UNINST_HEADER]}${NC}"
            unpatch_ide
            echo ""
            echo -e "${BOLD}${GREEN}${M[UNINST_SUCCESS]}${NC}"
            echo -e "${CYAN}${M[UNINST_RESTART]}${NC}"
        elif [[ "$TARGET_CHOICE" == "ide" ]]; then
            exit 1
        fi
    fi

    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "app" ]]; then
        unpatch_antigravity_app
    fi
}

do_status() {
    echo -e "${BOLD}${M[STATUS_HEADER]}${NC}"
    echo -e "${M[STATUS_APP_DIR]}${CYAN}${APP_DIR:-${M[STATUS_MISSING]}}${NC}"
    echo -e "${M[STATUS_USER]}${CYAN}$REAL_USER${NC}"
    echo -e "${M[STATUS_CONFIG]}${CYAN}$USER_CONFIG_DIR${NC}"
    echo ""

    if [[ -n "$APP_DIR" ]]; then
        local wb_dir="$APP_DIR/out/vs/workbench"
        local html_file="$APP_DIR/out/vs/code/electron-browser/workbench/workbench.html"
        local prod_file="$APP_DIR/product.json"

        if [[ -f "$wb_dir/antigravity-chat-rtl.css" ]]; then
            echo -e "${M[STATUS_WB_CSS]}${GREEN}${M[STATUS_INSTALLED]}${NC}"
        else
            echo -e "${M[STATUS_WB_CSS]}${RED}${M[STATUS_MISSING]}${NC}"
        fi

        if [[ -f "$wb_dir/antigravity-chat-rtl.js" ]]; then
            echo -e "${M[STATUS_WB_JS]}${GREEN}${M[STATUS_INSTALLED]}${NC}"
        else
            echo -e "${M[STATUS_WB_JS]}${RED}${M[STATUS_MISSING]}${NC}"
        fi

        if grep -q "antigravity-chat-rtl.css" "$html_file" 2>/dev/null && grep -q "antigravity-chat-rtl.js" "$html_file" 2>/dev/null; then
            echo -e "${M[STATUS_HTML]}${GREEN}${M[STATUS_PATCHED]}${NC}"
        elif grep -q "antigravity-chat-rtl.css" "$html_file" 2>/dev/null; then
            echo -e "${M[STATUS_HTML]}${YELLOW}${M[STATUS_PARTIAL]}${NC}"
        else
            echo -e "${M[STATUS_HTML]}${RED}${M[STATUS_NOT_PATCHED]}${NC}"
        fi

        local chk_status
        chk_status=$(python3 -c "
import json
try:
    with open('$prod_file', 'r', encoding='utf-8') as f:
        d = json.load(f)
        if 'vs/code/electron-browser/workbench/workbench.html' in d.get('checksums', {}):
            print('present')
        else:
            print('bypassed')
except:
    print('unknown')
" 2>/dev/null || echo "error")

        if [[ "$chk_status" == "bypassed" ]]; then
            echo -e "${M[STATUS_CHK]}${GREEN}${M[STATUS_BYPASS_ACTIVE]}${NC}"
        else
            echo -e "${M[STATUS_CHK]}${YELLOW}${M[STATUS_BYPASS_PENDING]}${NC}"
        fi
    fi

    if [[ -f "$MARKDOWN_CSS" ]]; then
        echo -e "${M[STATUS_MD]}${GREEN}${M[STATUS_CONFIGURED]}${NC}"
    else
        echo -e "${M[STATUS_MD]}${YELLOW}${M[STATUS_NOT_CONFIGURED]}${NC}"
    fi

    if [[ -n "$ANTIGRAVITY_APP_ASAR" && -f "$ANTIGRAVITY_APP_ASAR" ]]; then
        if [[ -f "$ANTIGRAVITY_APP_ASAR.original" ]]; then
            echo -e "${M[STATUS_APP_ASAR]}${GREEN}${M[STATUS_PATCHED]}${NC} ($ANTIGRAVITY_APP_ASAR)"
        else
            echo -e "${M[STATUS_APP_ASAR]}${YELLOW}${M[STATUS_NOT_PATCHED]}${NC} ($ANTIGRAVITY_APP_ASAR)"
        fi
    else
        echo -e "${M[STATUS_APP_ASAR]}${RED}${M[STATUS_MISSING]}${NC}"
    fi
}

cmd="${FILTERED_ARGS[0]:-install}"
case "$cmd" in
    install|setup)
        do_install
        ;;
    uninstall|remove|restore)
        do_uninstall
        ;;
    status)
        do_status
        ;;
    proxy|proxy-launcher)
        setup_proxy_launcher
        ;;
    help|--help|-h)
        echo "Usage: $(basename "$0") [install|uninstall|status|proxy|help] [--lang=fa|--lang=en] [--target=all|ide|app]"
        echo ""
        echo "Commands:"
        echo "  install    Install RTL CSS, JS, workbench patches and Vazirmatn font styling (default)"
        echo "  proxy      Create 'antigravity-proxy' launcher command and Desktop shortcut"
        echo "  uninstall  Revert all patches and restore original workbench files"
        echo "  status     Check current installation and patch status"
        echo "  help       Show this help message"
        echo ""
        echo "Options:"
        echo "  --lang=fa  Skip prompt and run in Persian"
        echo "  --lang=en  Skip prompt and run in English"
        echo "  --target=  all | ide | app (default: all)"
        ;;
    *)
        echo -e "${RED}Unknown command: $cmd${NC}"
        echo "Usage: $(basename "$0") [install|uninstall|status|proxy|help] [--lang=fa|--lang=en] [--target=all|ide|app]"
        exit 1
        ;;
esac
