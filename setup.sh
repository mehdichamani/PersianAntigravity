#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - فارسی ساز آنتی گرویتی
# Setup & Automation Script
# ==============================================================================
# Project: https://github.com/mehdichamani/PersianAntigravity
# Author:  Mehdi Chamani
# License: MIT
# Target:  Antigravity IDE & Antigravity App (Linux / macOS)
# ==============================================================================

set -euo pipefail

# ANSI Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
elif [[ -n "${0:-}" && -f "${0:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" &>/dev/null && pwd)"
fi

# Language Selection (Interactive Persian test / Terminal compatibility)
LANG_CHOICE=""
FILTERED_ARGS=()
TARGET_CHOICE="all"
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
        *)
            FILTERED_ARGS+=("$arg")
            ;;
    esac
done

if [[ -z "$LANG_CHOICE" ]]; then
    # Don't prompt if help requested
    first_arg="${FILTERED_ARGS[0]:-}"
    if [[ "$first_arg" != "help" && "$first_arg" != "--help" && "$first_arg" != "-h" ]]; then
        # Check if we have an interactive TTY available (stdin or /dev/tty when piped)
        tty_in=""
        if [ -t 0 ]; then
            tty_in="stdin"
        elif [ -r /dev/tty ]; then
            tty_in="/dev/tty"
        fi

        if [[ -n "$tty_in" ]]; then
            echo -e "${CYAN}======================================================================${NC}"
            echo -e "به پروژه فارسی ساز آنتی گرویتی (PersianAntigravity) خوش آمدید!"
            echo -e "${YELLOW}اگر این متن فارسی را بدون به‌هم‌ریختگی می‌بینید، با فارسی ادامه دهید.${NC}"
            echo -e "----------------------------------------------------------------------"
            echo -e "If the Persian text above looks garbled or broken, continue in English."
            echo -e "${CYAN}======================================================================${NC}"
            echo -e "  [1] فارسی (Persian) [Default]"
            echo -e "  [2] English\n"

            if [[ "$tty_in" == "/dev/tty" ]]; then
                read -r -p "Select language / انتخاب زبان [1/2] (Default: 1): " user_input < /dev/tty || user_input=""
            else
                read -r -p "Select language / انتخاب زبان [1/2] (Default: 1): " user_input || user_input=""
            fi

            if [[ "$user_input" =~ ^[[:space:]]*2[[:space:]]*$ ]]; then
                LANG_CHOICE="en"
                echo -e "${GREEN}English selected.${NC}\n"
            else
                LANG_CHOICE="fa"
                echo -e "${GREEN}زبان فارسی انتخاب شد.${NC}\n"
            fi
        else
            LANG_CHOICE="fa"
        fi
    else
        LANG_CHOICE="fa"
    fi
fi

# Localization dictionary
declare -A M
if [[ "$LANG_CHOICE" == "fa" ]]; then
    M[ERR_APP_DIR]="\n[✗] خطا: پوشه resources/app نرم‌افزار Antigravity IDE پیدا نشد!"
    M[ERR_PATH_DET]="    دستور antigravity-ide در PATH یافت نشد و مسیرهای پیش‌فرض نیز وجود ندارند.\n"
    M[TRB_TITLE]="راهنما و روش‌های رفع مشکل:"
    M[TRB_STEP1]="  1. اطمینان حاصل کنید که Antigravity IDE روی سیستم شما نصب است."
    M[TRB_STEP2]="  2. مسیر حاوی antigravity-ide را به متغیر PATH سیستم خود اضافه کنید."
    M[TRB_STEP3]="  3. یا متغیر محیطی ANTIGRAVITY_APP_DIR را قبل از اجرای اسکریپت export کنید:"
    M[ERR_MISSING]="\n[✗] خطا: فایل‌های اصلی و حیاتی Antigravity IDE یافت نشدند در: "
    M[MISSING_ITEM]="    یافت نشد: "
    M[TRB_CORRUPT]="نصب برنامه ناقص یا آسیب‌دیده به نظر می‌رسد. لطفاً Antigravity IDE را مجدداً نصب کنید.\n"
    M[SUCCESS_DETECT]="[✓] نرم‌افزار Antigravity IDE با موفقیت شناسایی شد از طریق: "
    M[APP_DIR_LBL]="    مسیر برنامه: "
    M[CORE_VERIFIED]="[✓] تمام فایل‌های هسته برنامه تأیید شدند. سیستم آماده اعمال فارسی‌سازی و راست‌چین‌سازی است!\n"
    M[ADMIN_REQ]="[!] برای تغییر فایل‌های Antigravity IDE به دسترسی مدیر (sudo) نیاز است."
    M[ADMIN_ELEVATING]="[*] در حال ارتقای دسترسی از طریق sudo..."
    M[FONT_LOCAL]="[*] در حال نصب قلم وزیرمتن از مخزن محلی..."
    M[FONT_LOCAL_OK]="[✓] قلم وزیرمتن با موفقیت نصب شد."
    M[FONT_WARN]="[!] هشدار: قلم وزیرمتن روی سیستم شما شناسایی نشد."
    M[FONT_ARCH]="    دستور نصب در Arch/Omarchy:  "
    M[FONT_DEB]="    دستور نصب در Debian/Ubuntu: "
    M[FONT_DETECTED]="[✓] قلم وزیرمتن شناسایی شد."
    M[WRITE_CSS]="[*] در حال نوشتن فایل CSS محیط کاری -> "
    M[WRITE_JS]="[*] در حال نوشتن فایل JS محیط کاری -> "
    M[PATCH_HTML]="[*] در حال پچ کردن "
    M[BACKUP_CREATED]="[i] نسخه پشتیبان ایجاد شد: "
    M[INJECT_CSS]="[✓] استایل antigravity-chat-rtl.css به workbench.html اضافه شد."
    M[CSS_EXISTS]="[i] لینک CSS قبلاً در workbench.html وجود دارد."
    M[INJECT_JS]="[✓] اسکریپت antigravity-chat-rtl.js به workbench.html اضافه شد."
    M[JS_EXISTS]="[i] تگ اسکریپت JS قبلاً در workbench.html وجود دارد."
    M[REMOVE_CHK]="[*] در حال غیرفعال‌سازی بررسی چک‌سام در product.json..."
    M[CHK_BYPASSED]="[✓] بای‌پس چک‌سام اعمال شد (جلوگیری از خطای corrupt/unsupported)."
    M[CFG_MD]="[*] در حال تنظیم پیش‌نمایش مارک‌داون (Ctrl+Shift+V)..."
    M[MD_CONFIGURED]="[✓] استایل‌ها و تنظیمات مارک‌داون راست‌چین پیکربندی شد."
    M[INST_HEADER]="=== در حال نصب فارسی ساز آنتی گرویتی (PersianAntigravity) ==="
    M[INST_SUCCESS]="✔ فارسی ساز آنتی گرویتی (PersianAntigravity) با موفقیت نصب شد!"
    M[INST_RESTART]="لطفاً برنامه یا محیط توسعه را ببندید و دوباره باز کنید تا تغییرات اعمال گردند."
    M[PROXY_HEADER]="=== ایجاد میانبر لانچر پروکسی Antigravity IDE ==="
    M[PROXY_BIN_INSTALLED]="[✓] اسکریپت کمکی در مسیر کاربر نصب شد: "
    M[PROXY_DESKTOP_INSTALLED]="[✓] فایل میانبر دسکتاپ ایجاد شد: "
    M[PROXY_INFO_MSG]="از این پس می‌توانید با دستور 'antigravity-proxy' در ترمینال یا از منوی برنامه‌ها، IDE را با پروکسی سیستم اجرا نمایید."
    M[UNINST_HEADER]="=== بازگردانی تغییرات فارسی ساز آنتی گرویتی (PersianAntigravity) ==="
    M[RESTORE_HTML]="[✓] فایل workbench.html از نسخه پشتیبان بازگردانی شد."
    M[REMOVE_TAGS]="[✓] تگ‌های راست‌چین از workbench.html حذف گردید."
    M[REMOVE_CSS]="[✓] فایل antigravity-chat-rtl.css حذف شد."
    M[REMOVE_JS]="[✓] فایل antigravity-chat-rtl.js حذف شد."
    M[RESTORE_PROD]="[✓] فایل product.json از نسخه پشتیبان بازگردانی شد."
    M[REMOVE_MD_CSS]="[✓] فایل markdown-rtl.css حذف شد."
    M[CLEAN_MD_SETTING]="[✓] استایل‌های مارک‌داون از settings.json پاکسازی شد."
    M[UNINST_SUCCESS]="✔ فارسی ساز آنتی گرویتی (PersianAntigravity) با موفقیت حذف گردید."
    M[UNINST_RESTART]="لطفاً نرم‌افزار را مجدداً راه‌اندازی کنید."
    M[STATUS_HEADER]="=== وضعیت فارسی ساز آنتی گرویتی (PersianAntigravity) ==="
    M[STATUS_APP_DIR]="  مسیر برنامه:        "
    M[STATUS_USER]="  کاربر هدف:          "
    M[STATUS_CONFIG]="  تنظیمات کاربر:      "
    M[STATUS_WB_CSS]="  استایل CSS محیط:    "
    M[STATUS_WB_JS]="  اسکریپت JS محیط:    "
    M[STATUS_HTML]="  workbench.html:   "
    M[STATUS_CHK]="  بای‌پس چک‌سام:      "
    M[STATUS_MD]="  پیش‌نمایش مارک‌داون:  "
    M[STATUS_INSTALLED]="نصب شده"
    M[STATUS_MISSING]="یافت نشد"
    M[STATUS_PATCHED]="پچ شده (CSS و JS متصل هستند)"
    M[STATUS_PARTIAL]="پچ ناقص (فقط CSS)"
    M[STATUS_NOT_PATCHED]="پچ نشده"
    M[STATUS_BYPASS_ACTIVE]="فعال (بدون خطای خراب بودن فایل)"
    M[STATUS_BYPASS_PENDING]="غیرفعال / در انتظار"
    M[STATUS_CONFIGURED]="پیکربندی شده"
    M[STATUS_NOT_CONFIGURED]="پیکربندی نشده"
    M[APP_NOT_FOUND_WARN]="[!] نرم‌افزار Antigravity App یافت نشد (اختیاری)."
    M[APP_PATCHING]="[*] در حال پچ کردن Antigravity App (app.asar)..."
    M[APP_EXTRACTING]="[*] در حال استخراج app.asar با @electron/asar..."
    M[APP_PACKING]="[*] در حال بسته‌بندی مجدد app.asar..."
    M[APP_PATCHED_OK]="[✓] نرم‌افزار Antigravity App با موفقیت پچ شد."
    M[APP_RESTORE_OK]="[✓] نرم‌افزار Antigravity App از نسخه پشتیبان بازگردانی شد."
    M[STATUS_APP_ASAR]="  Antigravity App:    "
    M[NEED_NODE_ASAR]="[!] برای پچ کردن Antigravity App ابزار npx و Node.js نیاز است."

else
    M[ERR_APP_DIR]="\n[✗] Error: Antigravity IDE 'resources/app' directory could not be found!"
    M[ERR_PATH_DET]="    The 'antigravity-ide' command was not found in your PATH, and default directories were missing.\n"
    M[TRB_TITLE]="Troubleshooting & Solutions:"
    M[TRB_STEP1]="  1. Ensure Antigravity IDE is installed on your machine."
    M[TRB_STEP2]="  2. Make sure the directory containing 'antigravity-ide' is added to your PATH."
    M[TRB_STEP3]="  3. Or export ANTIGRAVITY_APP_DIR before running this script:"
    M[ERR_MISSING]="\n[✗] Error: Required Antigravity IDE core files are missing in: "
    M[MISSING_ITEM]="    Missing: "
    M[TRB_CORRUPT]="Your installation seems corrupted or incomplete. Please reinstall Antigravity IDE.\n"
    M[SUCCESS_DETECT]="[✓] Antigravity IDE detected successfully via: "
    M[APP_DIR_LBL]="    App Directory: "
    M[CORE_VERIFIED]="[✓] All core files verified. Environment is ready to apply RTL patches!\n"
    M[ADMIN_REQ]="[!] Administrative privileges required to modify Antigravity IDE files."
    M[ADMIN_ELEVATING]="[*] Elevating privileges via sudo..."
    M[FONT_LOCAL]="[*] Installing Vazirmatn from local repository..."
    M[FONT_LOCAL_OK]="[✓] Vazirmatn font installed successfully."
    M[FONT_WARN]="[!] Warning: Vazirmatn font not detected on your system."
    M[FONT_ARCH]="    To install on Arch/Omarchy: "
    M[FONT_DEB]="    To install on Debian/Ubuntu: "
    M[FONT_DETECTED]="[✓] Vazirmatn font detected."
    M[WRITE_CSS]="[*] Writing workbench CSS -> "
    M[WRITE_JS]="[*] Writing workbench JS -> "
    M[PATCH_HTML]="[*] Patching "
    M[BACKUP_CREATED]="[i] Created backup: "
    M[INJECT_CSS]="[✓] Injected antigravity-chat-rtl.css into workbench.html"
    M[CSS_EXISTS]="[i] CSS link already present in workbench.html"
    M[INJECT_JS]="[✓] Injected antigravity-chat-rtl.js into workbench.html"
    M[JS_EXISTS]="[i] JS script already present in workbench.html"
    M[REMOVE_CHK]="[*] Removing checksum verification for workbench.html in "
    M[CHK_BYPASSED]="[✓] Checksum bypass applied (prevents unsupported / corrupt warnings)."
    M[CFG_MD]="[*] Configuring user Markdown preview (Ctrl+Shift+V)..."
    M[MD_CONFIGURED]="[✓] Markdown RTL preview styles & settings configured."
    M[INST_HEADER]="=== Installing PersianAntigravity ==="
    M[INST_SUCCESS]="✔ PersianAntigravity and Vazirmatn successfully installed!"
    M[INST_RESTART]="Please restart Antigravity to apply all visual changes."
    M[PROXY_HEADER]="=== Setting up Antigravity IDE Proxy Launcher ==="
    M[PROXY_BIN_INSTALLED]="[✓] Helper launcher script installed to: "
    M[PROXY_DESKTOP_INSTALLED]="[✓] Desktop entry created: "
    M[PROXY_INFO_MSG]="You can now launch Antigravity IDE with automatic system proxy injection via 'antigravity-proxy' CLI or from your applications menu."
    M[UNINST_HEADER]="=== Reverting PersianAntigravity Setup ==="
    M[RESTORE_HTML]="[✓] Restored workbench.html from backup."
    M[REMOVE_TAGS]="[✓] Removed RTL tags from workbench.html."
    M[REMOVE_CSS]="[✓] Removed antigravity-chat-rtl.css."
    M[REMOVE_JS]="[✓] Removed antigravity-chat-rtl.js."
    M[RESTORE_PROD]="[✓] Restored product.json from backup."
    M[REMOVE_MD_CSS]="[✓] Removed markdown-rtl.css."
    M[CLEAN_MD_SETTING]="[✓] Cleaned up markdown styles from settings.json."
    M[UNINST_SUCCESS]="✔ PersianAntigravity uninstalled cleanly."
    M[UNINST_RESTART]="Please restart Antigravity."
    M[STATUS_HEADER]="=== PersianAntigravity Status ==="
    M[STATUS_APP_DIR]="  App Directory:    "
    M[STATUS_USER]="  Target User:      "
    M[STATUS_CONFIG]="  User Config:      "
    M[STATUS_WB_CSS]="  Workbench CSS:    "
    M[STATUS_WB_JS]="  Workbench JS:     "
    M[STATUS_HTML]="  workbench.html:   "
    M[STATUS_CHK]="  Checksum Bypass:  "
    M[STATUS_MD]="  Markdown Preview: "
    M[STATUS_INSTALLED]="Installed"
    M[STATUS_MISSING]="Missing"
    M[STATUS_PATCHED]="Patched (CSS & JS linked)"
    M[STATUS_PARTIAL]="Partially Patched (CSS only)"
    M[STATUS_NOT_PATCHED]="Not Patched"
    M[STATUS_BYPASS_ACTIVE]="Active (No corrupt warning)"
    M[STATUS_BYPASS_PENDING]="Pending / Not Bypassed"
    M[STATUS_CONFIGURED]="Configured"
    M[STATUS_NOT_CONFIGURED]="Not Configured"
    M[APP_NOT_FOUND_WARN]="[!] Antigravity App not found (optional)."
    M[APP_PATCHING]="[*] Patching Antigravity App (app.asar)..."
    M[APP_EXTRACTING]="[*] Extracting app.asar via @electron/asar..."
    M[APP_PACKING]="[*] Repacking app.asar..."
    M[APP_PATCHED_OK]="[✓] Antigravity App successfully patched."
    M[APP_RESTORE_OK]="[✓] Antigravity App restored from original backup."
    M[STATUS_APP_ASAR]="  Antigravity App:    "
    M[NEED_NODE_ASAR]="[!] Node.js and npx are required to patch Antigravity App."

fi

# Resolve real user and home directory (handles execution directly or through sudo)
REAL_USER="${SUDO_USER:-${USER:-$(id -un 2>/dev/null || whoami 2>/dev/null || echo "root")}}"
REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || echo "${HOME:-}")
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    REAL_HOME="${HOME:-/root}"
fi

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
find_antigravity_app || true

# Locate Antigravity IDE application directory
APP_DIR=""
DETECTED_VIA=""

find_app_dir() {
    # Priority 1: Environment variable ANTIGRAVITY_APP_DIR
    if [[ -n "${ANTIGRAVITY_APP_DIR:-}" && -d "$ANTIGRAVITY_APP_DIR" && -f "$ANTIGRAVITY_APP_DIR/package.json" ]]; then
        APP_DIR="$ANTIGRAVITY_APP_DIR"
        DETECTED_VIA="Environment variable ANTIGRAVITY_APP_DIR"
        return 0
    fi

    # Priority 2: Locate via 'antigravity-ide' CLI in PATH
    if command -v antigravity-ide &>/dev/null; then
        local cli_bin
        cli_bin=$(command -v antigravity-ide)
        # Resolve symlink if applicable
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

    # Priority 3: Standard fallback paths
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

if ! find_app_dir; then
    echo -e "${RED}${M[ERR_APP_DIR]}${NC}"
    echo -e "${YELLOW}${M[ERR_PATH_DET]}${NC}"
    echo -e "${CYAN}${M[TRB_TITLE]}${NC}"
    echo -e "${M[TRB_STEP1]}"
    echo -e "${M[TRB_STEP2]}"
    echo -e "${M[TRB_STEP3]}"
    echo -e "     ${YELLOW}export ANTIGRAVITY_APP_DIR=\"/path/to/Antigravity IDE/resources/app\"${NC}"
    echo -e "     ${YELLOW}./setup.sh install${NC}\n"
    exit 1
fi

WORKBENCH_DIR="$APP_DIR/out/vs/workbench"
HTML_FILE="$APP_DIR/out/vs/code/electron-browser/workbench/workbench.html"
PRODUCT_JSON="$APP_DIR/product.json"

# Integrity & Health Check of required files
missing_files=()
[[ -f "$APP_DIR/package.json" ]] || missing_files+=("package.json")
[[ -d "$WORKBENCH_DIR" ]] || missing_files+=("out/vs/workbench")
[[ -f "$HTML_FILE" ]] || missing_files+=("out/vs/code/electron-browser/workbench/workbench.html")
[[ -f "$PRODUCT_JSON" ]] || missing_files+=("product.json")

if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo -e "${RED}${M[ERR_MISSING]}${APP_DIR}${NC}"
    for mf in "${missing_files[@]}"; do
        echo -e "${YELLOW}${M[MISSING_ITEM]}$mf${NC}"
    done
    echo -e "\n${CYAN}Troubleshooting:${NC} ${M[TRB_CORRUPT]}"
    exit 1
fi

echo -e "${GREEN}${M[SUCCESS_DETECT]}${DETECTED_VIA}${NC}"
echo -e "${M[APP_DIR_LBL]}${CYAN}${APP_DIR}${NC}"
echo -e "${GREEN}${M[CORE_VERIFIED]}${NC}"
USER_CONFIG_DIR="$REAL_HOME/.config/Antigravity IDE/User"
MARKDOWN_CSS="$USER_CONFIG_DIR/markdown-rtl.css"
SETTINGS_JSON="$USER_CONFIG_DIR/settings.json"

# Elevation check for core IDE files in /opt or system directories
ensure_root() {
    if [[ ! -w "$WORKBENCH_DIR" || ! -w "$HTML_FILE" || ! -w "$PRODUCT_JSON" ]]; then
        if [[ $EUID -ne 0 ]]; then
            echo -e "${YELLOW}${M[ADMIN_REQ]}${NC}"
            echo -e "${CYAN}${M[ADMIN_ELEVATING]}${NC}"
            if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
                exec sudo -E bash "${BASH_SOURCE[0]}" "--lang=$LANG_CHOICE" "${FILTERED_ARGS[@]}"
            elif [[ -f "${0:-}" ]]; then
                exec sudo -E bash "$0" "--lang=$LANG_CHOICE" "${FILTERED_ARGS[@]}"
            else
                local tmp_script
                tmp_script="$(mktemp /tmp/persian-antigravity-setup.XXXXXX.sh)"
                if curl -fsSL "https://raw.githubusercontent.com/mehdichamani/PersianAntigravity/main/setup.sh" -o "$tmp_script"; then
                    chmod +x "$tmp_script"
                    exec sudo -E bash "$tmp_script" "--lang=$LANG_CHOICE" "${FILTERED_ARGS[@]}"
                else
                    echo -e "${RED}[✗] Sudo elevation failed in one-liner mode. Please run with sudo or clone repo.${NC}"
                    exit 1
                fi
            fi
        fi
    fi
}

check_fonts() {
    if command -v fc-list &>/dev/null; then
        if ! fc-list : family | grep -iq "vazirmatn"; then
            local repo_fonts="$REAL_HOME/.local/share/chezmoi/private_dot_local/private_share/fonts"
            if compgen -G "$repo_fonts/Vazirmatn-*.ttf" > /dev/null 2>&1; then
                echo -e "${CYAN}${M[FONT_LOCAL]}${NC}"
                mkdir -p "$REAL_HOME/.local/share/fonts"
                cp -f "$repo_fonts"/Vazirmatn-*.ttf "$REAL_HOME/.local/share/fonts/"
                fc-cache -f "$REAL_HOME/.local/share/fonts" &>/dev/null || true
                echo -e "${GREEN}${M[FONT_LOCAL_OK]}${NC}"
            else
                echo -e "${YELLOW}${M[FONT_WARN]}${NC}"
                echo -e "${CYAN}${M[FONT_ARCH]}${NC}yay -S --needed ttf-vazirmatn"
                echo -e "${CYAN}${M[FONT_DEB]}${NC}sudo apt install fonts-vazirmatn"
            fi
        else
            echo -e "${GREEN}${M[FONT_DETECTED]}${NC}"
        fi
    fi
}

write_css_file() {
    local target="$WORKBENCH_DIR/antigravity-chat-rtl.css"
    echo -e "${CYAN}${M[WRITE_CSS]}$target${NC}"

    if [[ -f "$SCRIPT_DIR/styles/antigravity-chat-rtl.css" ]]; then
        cp -f "$SCRIPT_DIR/styles/antigravity-chat-rtl.css" "$target"
    else
        cat <<'EOF' > "$target"
/* ==============================================================================
 * PersianAntigravity - فارسی ساز آنتی گرویتی
 * Project: https://github.com/mehdichamani/PersianAntigravity
 * ============================================================================== */

.antigravity-agent-side-panel,
.antigravity-agent-side-panel p,
.antigravity-agent-side-panel span,
.antigravity-agent-side-panel li,
.antigravity-agent-side-panel h1,
.antigravity-agent-side-panel h2,
.antigravity-agent-side-panel h3,
.antigravity-agent-side-panel h4,
.antigravity-agent-side-panel textarea,
.antigravity-agent-side-panel input,
.antigravity-agent-side-panel [contenteditable="true"],
.jetski-custom-editor-pane,
.jetski-custom-editor-pane p,
.jetski-custom-editor-pane span,
.jetski-custom-editor-pane li,
.jetski-custom-editor-pane h1,
.jetski-custom-editor-pane h2,
.jetski-custom-editor-pane h3 {
    font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif !important;
}

.antigravity-is-rtl {
    direction: rtl !important;
    text-align: right !important;
}

.jetski-custom-editor-pane .antigravity-is-rtl {
    line-height: 1.8 !important;
}

.jetski-custom-editor-pane ol.antigravity-is-rtl,
.jetski-custom-editor-pane ul.antigravity-is-rtl {
    padding-right: 2.25rem !important;
    padding-left: 1rem !important;
    margin-right: 0.5rem !important;
}

.jetski-custom-editor-pane li.antigravity-is-rtl {
    padding-right: 0.35rem !important;
    margin-bottom: 0.4rem !important;
}

.jetski-custom-editor-pane > div,
.jetski-custom-editor-pane .pb-6 {
    padding-right: 2rem !important;
    padding-left: 2rem !important;
}

/* Force RTL and right-alignment for prompt input box and contenteditable fields */
.antigravity-agent-side-panel textarea,
.antigravity-agent-side-panel input,
.antigravity-agent-side-panel [contenteditable="true"],
.antigravity-agent-side-panel [role="textbox"],
.antigravity-agent-side-panel [role="combobox"],
.antigravity-app textarea,
.antigravity-app input,
.antigravity-app [contenteditable="true"],
.antigravity-app [role="textbox"],
[contenteditable="true"],
[aria-label="Message input"] {
    direction: rtl !important;
    text-align: right !important;
}

[aria-label="Message input"] ~ p,
.pointer-events-none.absolute.left-2.right-2 {
    direction: rtl !important;
    text-align: right !important;
}

.antigravity-agent-side-panel pre,
.antigravity-agent-side-panel code,
.antigravity-agent-side-panel pre *,
.antigravity-agent-side-panel code *,
.antigravity-agent-side-panel .interactive-result-code-block,
.antigravity-agent-side-panel .code-block-container,
.jetski-custom-editor-pane pre,
.jetski-custom-editor-pane code,
.jetski-custom-editor-pane pre *,
.jetski-custom-editor-pane code *,
.antigravity-is-rtl pre,
.antigravity-is-rtl code,
.antigravity-is-rtl .interactive-result-code-block,
.antigravity-is-rtl .code-block-container {
    direction: ltr !important;
    unicode-bidi: isolate !important;
    text-align: left !important;
    font-family: 'JetBrainsMono Nerd Font', 'Jet Brains Mono Nerd Font', 'JetBrainsMono NF', monospace !important;
}

.codicon,
.codicon[class*='codicon-'],
[class*='codicon'],
.material-symbols-outlined,
.material-icons,
[class*='lucide'] {
    font-family: codicon, 'Material Symbols Outlined', 'Material Icons', inherit !important;
}

.antigravity-is-rtl table,
.jetski-custom-editor-pane table {
    direction: ltr !important;
    text-align: left !important;
}

#antigravity-rtl-toggle-btn {
    font-size: 14px !important;
    font-weight: bold !important;
    transition: opacity 0.2s, background 0.2s;
    text-decoration: none !important;
    cursor: pointer !important;
}
#antigravity-rtl-toggle-btn.antigravity-rtl-active {
    color: #4facfe !important;
}
EOF
    fi
    chmod 644 "$target"
}

write_js_file() {
    local target="$WORKBENCH_DIR/antigravity-chat-rtl.js"
    echo -e "${CYAN}[*] Writing workbench JS -> $target${NC}"

    if [[ -f "$SCRIPT_DIR/scripts/antigravity-chat-rtl.js" ]]; then
        cp -f "$SCRIPT_DIR/scripts/antigravity-chat-rtl.js" "$target"
    else
        cat <<'EOF' > "$target"
(function() {
    'use strict';
    var RTL_REGEX = /[\u0590-\u05FF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]/;

    function updateRtlElements() {
        var selectors = [
            '.antigravity-agent-side-panel .whitespace-pre-wrap.text-sm',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > p',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > ul',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > ol',
            '.antigravity-agent-side-panel .leading-relaxed.select-text li',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h1',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h2',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h3',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h4',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > blockquote',
            '.jetski-custom-editor-pane p',
            '.jetski-custom-editor-pane ul',
            '.jetski-custom-editor-pane ol',
            '.jetski-custom-editor-pane li',
            '.jetski-custom-editor-pane h1',
            '.jetski-custom-editor-pane h2',
            '.jetski-custom-editor-pane h3',
            '.jetski-custom-editor-pane h4',
            '.jetski-custom-editor-pane h5',
            '.jetski-custom-editor-pane h6',
            '.jetski-custom-editor-pane blockquote'
        ].join(', ');

        var elements = document.querySelectorAll(selectors);
        elements.forEach(function(el) {
            if (el.tagName === 'PRE' || el.tagName === 'CODE' || el.closest('pre') || el.closest('.interactive-result-code-block') || el.closest('.code-block-container')) {
                return;
            }
            if (RTL_REGEX.test(el.textContent)) {
                el.classList.add('antigravity-is-rtl');
            } else {
                el.classList.remove('antigravity-is-rtl');
            }
        });
    }

    var updateTimeout = null;
    function scheduleUpdate() {
        if (updateTimeout) return;
        updateTimeout = setTimeout(function() {
            updateTimeout = null;
            updateRtlElements();
        }, 100);
    }

    var observer = new MutationObserver(function() {
        scheduleUpdate();
    });
    observer.observe(document.body, { childList: true, subtree: true });

    if (document.readyState !== 'loading') {
        scheduleUpdate();
    } else {
        document.addEventListener('DOMContentLoaded', scheduleUpdate);
    }
})();
EOF
    fi
    chmod 644 "$target"
}

patch_workbench_html() {
    echo -e "${CYAN}${M[PATCH_HTML]}$HTML_FILE${NC}"
    if [[ ! -f "$HTML_FILE.bak" ]]; then
        cp "$HTML_FILE" "$HTML_FILE.bak"
        echo -e "${BLUE}${M[BACKUP_CREATED]}$HTML_FILE.bak${NC}"
    fi

    # Inject CSS link before </head>
    if ! grep -q "antigravity-chat-rtl.css" "$HTML_FILE"; then
        sed -i '/<\/head>/i \	<link rel="stylesheet" href="../../../workbench/antigravity-chat-rtl.css">' "$HTML_FILE"
        echo -e "${GREEN}${M[INJECT_CSS]}${NC}"
    else
        echo -e "${YELLOW}${M[CSS_EXISTS]}${NC}"
    fi

    # Inject JS script before </html>
    if ! grep -q "antigravity-chat-rtl.js" "$HTML_FILE"; then
        sed -i '/<\/html>/i \	<script src="../../../workbench/antigravity-chat-rtl.js"></script>' "$HTML_FILE"
        echo -e "${GREEN}${M[INJECT_JS]}${NC}"
    else
        echo -e "${YELLOW}${M[JS_EXISTS]}${NC}"
    fi
}

patch_product_json() {
    echo -e "${CYAN}${M[REMOVE_CHK]}$PRODUCT_JSON${NC}"
    if [[ ! -f "$PRODUCT_JSON.bak" ]]; then
        cp "$PRODUCT_JSON" "$PRODUCT_JSON.bak"
        echo -e "${BLUE}${M[BACKUP_CREATED]}$PRODUCT_JSON.bak${NC}"
    fi

    python3 -c "
import json

product_path = '$PRODUCT_JSON'
with open(product_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

checksums = data.get('checksums', {})
target_key = 'vs/code/electron-browser/workbench/workbench.html'
if target_key in checksums:
    del checksums[target_key]
    with open(product_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print('REMOVED')
else:
    print('ALREADY_REMOVED')
" 2>/dev/null || true
    echo -e "${GREEN}${M[CHK_BYPASSED]}${NC}"
}

# ------------------------------------------------------------------------------
# Antigravity App (app.asar) Management
# ------------------------------------------------------------------------------
patch_antigravity_app() {
    if [[ -z "$ANTIGRAVITY_APP_ASAR" || ! -f "$ANTIGRAVITY_APP_ASAR" ]]; then
        echo -e "${YELLOW}${M[APP_NOT_FOUND_WARN]}${NC}"
        return 0
    fi

    if ! command -v npx &>/dev/null; then
        echo -e "${RED}${M[NEED_NODE_ASAR]}${NC}"
        return 1
    fi

    local asar_path="$ANTIGRAVITY_APP_ASAR"
    local backup_path="$asar_path.original"

    echo -e "${BOLD}${BLUE}${M[APP_PATCHING]}${NC}"
    echo -e "    Target: ${CYAN}$asar_path${NC}"

    if [[ ! -f "$backup_path" ]]; then
        cp -f "$asar_path" "$backup_path"
        echo -e "${BLUE}${M[BACKUP_CREATED]}$backup_path${NC}"
    fi

    local tmp_extract
    tmp_extract="$(mktemp -d /tmp/antigravity-asar.XXXXXX)"
    echo -e "${CYAN}${M[APP_EXTRACTING]}${NC}"
    if ! npx -y @electron/asar extract "$asar_path" "$tmp_extract"; then
        echo -e "${RED}[✗] Failed to extract app.asar${NC}"
        rm -rf "$tmp_extract"
        return 1
    fi

    local preload_file="$tmp_extract/dist/preload.js"
    if [[ ! -f "$preload_file" ]]; then
        echo -e "${RED}[✗] preload.js not found in extracted app.asar${NC}"
        rm -rf "$tmp_extract"
        return 1
    fi

    local css_file="$SCRIPT_DIR/styles/antigravity-chat-rtl.css"
    local js_file="$SCRIPT_DIR/scripts/antigravity-chat-rtl.js"
    local css_content=""
    local js_content=""

    if [[ -f "$css_file" ]]; then
        css_content="$(cat "$css_file")"
    fi
    if [[ -f "$js_file" ]]; then
        js_content="$(cat "$js_file")"
    fi

    node -e '
const fs = require("fs");
const preloadPath = process.argv[1];
const cssText = process.argv[2];
const jsText = process.argv[3];

let content = fs.readFileSync(preloadPath, "utf8");
const markerStart = "// ==PersianAntigravity-Injection-Start==";
const markerEnd = "// ==PersianAntigravity-Injection-End==";

if (content.includes(markerStart)) {
    const p1 = content.split(markerStart)[0];
    const p2 = content.split(markerEnd)[1];
    content = p1 + p2;
} else if (content.includes("// ==PersianAntigravityIDE-Injection-Start==")) {
    const p1 = content.split("// ==PersianAntigravityIDE-Injection-Start==")[0];
    const p2 = content.split("// ==PersianAntigravityIDE-Injection-End==")[1];
    content = p1 + p2;
}

const snippet = `
${markerStart}
(function() {
    function injectPersianStyles() {
        try {
            if (!document.head) return;
            if (document.getElementById("persian-antigravity-rtl-style")) return;

            var style = document.createElement("style");
            style.id = "persian-antigravity-rtl-style";
            style.textContent = ${JSON.stringify(cssText)};
            document.head.appendChild(style);

            var script = document.createElement("script");
            script.id = "persian-antigravity-rtl-script";
            script.textContent = ${JSON.stringify(jsText)};
            document.head.appendChild(script);
        } catch(e) {
            console.error("[PersianAntigravity] Injection error:", e);
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", injectPersianStyles);
    } else {
        injectPersianStyles();
    }
})();
${markerEnd}
`;

content = content.trim() + "\n" + snippet;
fs.writeFileSync(preloadPath, content, "utf8");
' "$preload_file" "$css_content" "$js_content"

    echo -e "${CYAN}${M[APP_PACKING]}${NC}"
    local pack_args=("--unpack-dir" "node_modules/chrome-devtools-mcp")
    local tmp_asar
    tmp_asar="$(mktemp /tmp/antigravity-repack.XXXXXX.asar)"

    if npx -y @electron/asar pack "$tmp_extract" "$tmp_asar" "${pack_args[@]}"; then
        mv -f "$tmp_asar" "$asar_path"
        chmod 644 "$asar_path"
        rm -rf "$tmp_extract" "$tmp_asar"
        echo -e "${GREEN}${M[APP_PATCHED_OK]}${NC}"
    else
        echo -e "${RED}[✗] Failed to repack app.asar${NC}"
        rm -rf "$tmp_extract" "$tmp_asar"
        return 1
    fi
}

unpatch_antigravity_app() {
    if [[ -z "$ANTIGRAVITY_APP_ASAR" || ! -f "$ANTIGRAVITY_APP_ASAR" ]]; then
        return 0
    fi
    local asar_path="$ANTIGRAVITY_APP_ASAR"
    local backup_path="$asar_path.original"

    if [[ -f "$backup_path" ]]; then
        cp -f "$backup_path" "$asar_path"
        rm -f "$backup_path"
        echo -e "${GREEN}${M[APP_RESTORE_OK]}${NC}"
    fi
}

setup_markdown_preview() {
    echo -e "${CYAN}${M[CFG_MD]}${NC}"
    mkdir -p "$USER_CONFIG_DIR"

    if [[ -f "$SCRIPT_DIR/styles/markdown-rtl.css" ]]; then
        cp -f "$SCRIPT_DIR/styles/markdown-rtl.css" "$MARKDOWN_CSS"
    else
        cat <<'EOF' > "$MARKDOWN_CSS"
body {
    font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, 'Ubuntu', 'Droid Sans', sans-serif !important;
}

p, h1, h2, h3, h4, h5, h6, li, blockquote, td, th {
    unicode-bidi: plaintext;
    text-align: start;
}

pre, code, tt {
    direction: ltr !important;
    unicode-bidi: isolate !important;
    text-align: left !important;
    font-family: 'JetBrainsMono Nerd Font', 'Jet Brains Mono Nerd Font', monospace !important;
}

li:dir(rtl) {
    direction: rtl;
    text-align: right;
}
EOF
    fi

    # Safely merge into settings.json using python3
    python3 -c "
import json, os

settings_path = '$SETTINGS_JSON'
markdown_css_path = '$MARKDOWN_CSS'

data = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception:
        data = {}

data['markdown.preview.fontFamily'] = \"'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, 'Ubuntu', 'Droid Sans', sans-serif\"

styles = data.get('markdown.styles', [])
if not isinstance(styles, list):
    styles = []
if markdown_css_path not in styles:
    styles.append(markdown_css_path)
data['markdown.styles'] = styles

with open(settings_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
" 2>/dev/null || true

    # Fix ownership for user config directory
    if id "$REAL_USER" &>/dev/null; then
        chown -R "$REAL_USER:$(id -gn "$REAL_USER")" "$USER_CONFIG_DIR" 2>/dev/null || true
    fi

    echo -e "${GREEN}${M[MD_CONFIGURED]}${NC}"
}

do_install() {
    check_fonts
    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "ide" ]]; then
        ensure_root "$@"
        echo -e "${BOLD}${BLUE}${M[INST_HEADER]}${NC}"
        write_css_file
        write_js_file
        patch_workbench_html
        patch_product_json
        setup_markdown_preview
        echo ""
        echo -e "${BOLD}${GREEN}${M[INST_SUCCESS]}${NC}"
        echo -e "${CYAN}${M[INST_RESTART]}${NC}"
    fi

    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "app" ]]; then
        patch_antigravity_app
    fi
}

do_uninstall() {
    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "ide" ]]; then
        ensure_root "$@"
        echo -e "${BOLD}${YELLOW}${M[UNINST_HEADER]}${NC}"

    # Restore workbench.html
    if [[ -f "$HTML_FILE" ]]; then
        if [[ -f "$HTML_FILE.bak" ]]; then
            cp -f "$HTML_FILE.bak" "$HTML_FILE"
            rm -f "$HTML_FILE.bak"
            echo -e "${GREEN}${M[RESTORE_HTML]}${NC}"
        else
            sed -i '/antigravity-chat-rtl\.css/d' "$HTML_FILE"
            sed -i '/antigravity-chat-rtl\.js/d' "$HTML_FILE"
            echo -e "${GREEN}${M[REMOVE_TAGS]}${NC}"
        fi
    fi

    # Remove CSS and JS
    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.css" ]]; then
        rm -f "$WORKBENCH_DIR/antigravity-chat-rtl.css"
        echo -e "${GREEN}${M[REMOVE_CSS]}${NC}"
    fi

    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.js" ]]; then
        rm -f "$WORKBENCH_DIR/antigravity-chat-rtl.js"
        echo -e "${GREEN}${M[REMOVE_JS]}${NC}"
    fi

    # Restore product.json
    if [[ -f "$PRODUCT_JSON.bak" ]]; then
        cp -f "$PRODUCT_JSON.bak" "$PRODUCT_JSON"
        rm -f "$PRODUCT_JSON.bak"
        echo -e "${GREEN}${M[RESTORE_PROD]}${NC}"
    fi

    # Clean up markdown css & settings
    if [[ -f "$MARKDOWN_CSS" ]]; then
        rm -f "$MARKDOWN_CSS"
        echo -e "${GREEN}${M[REMOVE_MD_CSS]}${NC}"
    fi

    if [[ -f "$SETTINGS_JSON" ]]; then
        python3 -c "
import json, os
settings_path = '$SETTINGS_JSON'
markdown_css_path = '$MARKDOWN_CSS'
if os.path.exists(settings_path):
    try:
        with open(settings_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        styles = data.get('markdown.styles', [])
        if isinstance(styles, list) and markdown_css_path in styles:
            styles.remove(markdown_css_path)
            data['markdown.styles'] = styles
        with open(settings_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
    except Exception:
        pass
" 2>/dev/null || true
        echo -e "${GREEN}${M[CLEAN_MD_SETTING]}${NC}"
    fi

    echo ""
    echo -e "${BOLD}${GREEN}${M[UNINST_SUCCESS]}${NC}"
    echo -e "${CYAN}${M[UNINST_RESTART]}${NC}"
    fi

    if [[ "$TARGET_CHOICE" == "all" || "$TARGET_CHOICE" == "app" ]]; then
        unpatch_antigravity_app
    fi
}

do_status() {
    echo -e "${BOLD}${M[STATUS_HEADER]}${NC}"
    echo -e "${M[STATUS_APP_DIR]}${CYAN}$APP_DIR${NC}"
    echo -e "${M[STATUS_USER]}${CYAN}$REAL_USER${NC}"
    echo -e "${M[STATUS_CONFIG]}${CYAN}$USER_CONFIG_DIR${NC}"
    echo ""

    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.css" ]]; then
        echo -e "${M[STATUS_WB_CSS]}${GREEN}${M[STATUS_INSTALLED]}${NC}"
    else
        echo -e "${M[STATUS_WB_CSS]}${RED}${M[STATUS_MISSING]}${NC}"
    fi

    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.js" ]]; then
        echo -e "${M[STATUS_WB_JS]}${GREEN}${M[STATUS_INSTALLED]}${NC}"
    else
        echo -e "${M[STATUS_WB_JS]}${RED}${M[STATUS_MISSING]}${NC}"
    fi

    if grep -q "antigravity-chat-rtl.css" "$HTML_FILE" 2>/dev/null && grep -q "antigravity-chat-rtl.js" "$HTML_FILE" 2>/dev/null; then
        echo -e "${M[STATUS_HTML]}${GREEN}${M[STATUS_PATCHED]}${NC}"
    elif grep -q "antigravity-chat-rtl.css" "$HTML_FILE" 2>/dev/null; then
        echo -e "${M[STATUS_HTML]}${YELLOW}${M[STATUS_PARTIAL]}${NC}"
    else
        echo -e "${M[STATUS_HTML]}${RED}${M[STATUS_NOT_PATCHED]}${NC}"
    fi

    local chk_status
    chk_status=$(python3 -c "
import json
try:
    with open('$PRODUCT_JSON', 'r', encoding='utf-8') as f:
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

do_proxy() {
    echo -e "${CYAN}${M[PROXY_HEADER]}${NC}"

    local bin_dir="$REAL_HOME/.local/bin"
    local app_dir_desk="$REAL_HOME/.local/share/applications"
    mkdir -p "$bin_dir" "$app_dir_desk"

    local target_script="$bin_dir/antigravity-proxy"
    local source_script=""
    if [[ -n "$SCRIPT_DIR" ]]; then
        source_script="$SCRIPT_DIR/scripts/antigravity-proxy.sh"
    fi

    if [[ -n "$source_script" && -f "$source_script" ]]; then
        cp -f "$source_script" "$target_script"
    else
        # Fallback inline creation if running via curl pipe
        cat << 'EOF' > "$target_script"
#!/usr/bin/env bash
TARGET_CMD="antigravity-ide"
DETECTED_PROXY=""
if [[ -n "${http_proxy:-}" ]]; then DETECTED_PROXY="$http_proxy"; elif [[ -n "${HTTP_PROXY:-}" ]]; then DETECTED_PROXY="$HTTP_PROXY"; elif [[ -n "${all_proxy:-}" ]]; then DETECTED_PROXY="$all_proxy"; fi
if [[ -z "$DETECTED_PROXY" ]] && command -v gsettings &>/dev/null; then
    MODE=$(gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'")
    if [[ "$MODE" == "manual" ]]; then
        H=$(gsettings get org.gnome.system.proxy.http host 2>/dev/null | tr -d "'")
        P=$(gsettings get org.gnome.system.proxy.http port 2>/dev/null)
        [[ -n "$H" && "$P" -gt 0 ]] && DETECTED_PROXY="http://${H}:${P}"
    fi
fi
if [[ -z "$DETECTED_PROXY" ]] && command -v kreadconfig6 &>/dev/null; then
    [[ $(kreadconfig6 --file kioslaverc --group "Proxy Settings" --key "ProxyType" 2>/dev/null) == "1" ]] && DETECTED_PROXY=$(kreadconfig6 --file kioslaverc --group "Proxy Settings" --key "httpProxy" 2>/dev/null)
fi
if [[ -z "$DETECTED_PROXY" ]] && command -v kreadconfig5 &>/dev/null; then
    [[ $(kreadconfig5 --file kioslaverc --group "Proxy Settings" --key "ProxyType" 2>/dev/null) == "1" ]] && DETECTED_PROXY=$(kreadconfig5 --file kioslaverc --group "Proxy Settings" --key "httpProxy" 2>/dev/null)
fi
if [[ -n "$DETECTED_PROXY" ]]; then
    [[ ! "$DETECTED_PROXY" =~ ^[a-zA-Z0-9]+:// ]] && DETECTED_PROXY="http://$DETECTED_PROXY"
    export http_proxy="$DETECTED_PROXY" https_proxy="$DETECTED_PROXY" HTTP_PROXY="$DETECTED_PROXY" HTTPS_PROXY="$DETECTED_PROXY" all_proxy="$DETECTED_PROXY" ALL_PROXY="$DETECTED_PROXY"
fi
exec "$TARGET_CMD" "$@"
EOF
    fi

    chmod +x "$target_script"
    echo -e "${GREEN}${M[PROXY_BIN_INSTALLED]}$target_script${NC}"

    # Create Desktop Entry
    local desktop_entry="$app_dir_desk/antigravity-proxy.desktop"
    cat << EOF > "$desktop_entry"
[Desktop Entry]
Name=Antigravity IDE (Proxy)
Comment=Launch Antigravity IDE with System Proxy
Exec=$target_script %F
Terminal=false
Type=Application
Icon=antigravity-ide
Categories=Development;IDE;
StartupWMClass=Antigravity IDE
EOF
    chmod +x "$desktop_entry"
    echo -e "${GREEN}${M[PROXY_DESKTOP_INSTALLED]}$desktop_entry${NC}"

    echo ""
    echo -e "${CYAN}${M[PROXY_INFO_MSG]}${NC}"
}

cmd="${FILTERED_ARGS[0]:-install}"
rest_args=()
if [[ ${#FILTERED_ARGS[@]} -gt 1 ]]; then
    rest_args=("${FILTERED_ARGS[@]:1}")
fi

case "$cmd" in
    install|setup)
        do_install "${rest_args[@]}"
        ;;
    uninstall|remove|restore)
        do_uninstall "${rest_args[@]}"
        ;;
    status)
        do_status
        ;;
    proxy|proxy-launcher)
        do_proxy
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
        ;;
    *)
        echo -e "${RED}Unknown command: $cmd${NC}"
        echo "Usage: $(basename "$0") [install|uninstall|status|proxy|help] [--lang=fa|--lang=en] [--target=all|ide|app]"
        exit 1
        ;;
esac

