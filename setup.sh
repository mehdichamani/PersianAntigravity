#!/usr/bin/env bash
# ==============================================================================
# Antigravity IDE RTL & Vazirmatn Setup & Automation Script
# ==============================================================================
# Project: https://github.com/mehdichamani/antigravity-rtl
# Author:  Mehdi Chamani
# License: MIT
# Target:  Antigravity IDE (Linux / macOS)
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Resolve real user and home directory (handles execution directly or through sudo)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || echo "$HOME")
if [[ -z "$REAL_HOME" || ! -d "$REAL_HOME" ]]; then
    REAL_HOME="$HOME"
fi

# Locate Antigravity IDE application directory
find_app_dir() {
    local candidates=(
        "${ANTIGRAVITY_APP_DIR:-}"
        "/opt/antigravity-ide/resources/app"
        "/usr/lib/antigravity-ide/resources/app"
        "/usr/share/antigravity-ide/resources/app"
        "$REAL_HOME/.local/share/antigravity-ide/resources/app"
        "/Applications/Antigravity IDE.app/Contents/Resources/app"
    )

    for dir in "${candidates[@]}"; do
        if [[ -n "$dir" && -d "$dir" && -f "$dir/package.json" ]]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

APP_DIR=$(find_app_dir || true)

if [[ -z "$APP_DIR" ]]; then
    echo -e "${RED}[✗] Error: Antigravity IDE resources/app directory not found.${NC}"
    echo -e "${YELLOW}    Please ensure Antigravity IDE is installed or set ANTIGRAVITY_APP_DIR.${NC}"
    exit 1
fi

WORKBENCH_DIR="$APP_DIR/out/vs/workbench"
HTML_FILE="$APP_DIR/out/vs/code/electron-browser/workbench/workbench.html"
PRODUCT_JSON="$APP_DIR/product.json"
USER_CONFIG_DIR="$REAL_HOME/.config/Antigravity IDE/User"
MARKDOWN_CSS="$USER_CONFIG_DIR/markdown-rtl.css"
SETTINGS_JSON="$USER_CONFIG_DIR/settings.json"

# Elevation check for core IDE files in /opt or system directories
ensure_root() {
    if [[ ! -w "$WORKBENCH_DIR" || ! -w "$HTML_FILE" || ! -w "$PRODUCT_JSON" ]]; then
        if [[ $EUID -ne 0 ]]; then
            echo -e "${YELLOW}[!] Administrative privileges required to modify Antigravity IDE files.${NC}"
            echo -e "${CYAN}[*] Elevating privileges via sudo...${NC}"
            exec sudo -E bash "$0" "$@"
        fi
    fi
}

check_fonts() {
    if command -v fc-list &>/dev/null; then
        if ! fc-list : family | grep -iq "vazirmatn"; then
            local repo_fonts="$REAL_HOME/.local/share/chezmoi/private_dot_local/private_share/fonts"
            if compgen -G "$repo_fonts/Vazirmatn-*.ttf" > /dev/null 2>&1; then
                echo -e "${CYAN}[*] Installing Vazirmatn from local repository...${NC}"
                mkdir -p "$REAL_HOME/.local/share/fonts"
                cp -f "$repo_fonts"/Vazirmatn-*.ttf "$REAL_HOME/.local/share/fonts/"
                fc-cache -f "$REAL_HOME/.local/share/fonts" &>/dev/null || true
                echo -e "${GREEN}[✓] Vazirmatn font installed successfully.${NC}"
            else
                echo -e "${YELLOW}[!] Warning: Vazirmatn font not detected on your system.${NC}"
                echo -e "${CYAN}    To install on Arch/Omarchy:${NC} yay -S --needed ttf-vazirmatn"
                echo -e "${CYAN}    To install on Debian/Ubuntu:${NC} sudo apt install fonts-vazirmatn"
            fi
        else
            echo -e "${GREEN}[✓] Vazirmatn font detected.${NC}"
        fi
    fi
}

write_css_file() {
    local target="$WORKBENCH_DIR/antigravity-chat-rtl.css"
    echo -e "${CYAN}[*] Writing workbench CSS -> $target${NC}"

    if [[ -f "$SCRIPT_DIR/styles/antigravity-chat-rtl.css" ]]; then
        cp -f "$SCRIPT_DIR/styles/antigravity-chat-rtl.css" "$target"
    else
        cat <<'EOF' > "$target"
/* ==============================================================================
 * Antigravity IDE RTL & Persian/Arabic Typography Stylesheet
 * Project: https://github.com/mehdichamani/antigravity-rtl
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

.antigravity-agent-side-panel textarea,
.antigravity-agent-side-panel input,
.antigravity-agent-side-panel [contenteditable="true"] {
    unicode-bidi: plaintext !important;
    text-align: start !important;
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
    echo -e "${CYAN}[*] Patching $HTML_FILE${NC}"
    if [[ ! -f "$HTML_FILE.bak" ]]; then
        cp "$HTML_FILE" "$HTML_FILE.bak"
        echo -e "${BLUE}[i] Created backup: $HTML_FILE.bak${NC}"
    fi

    # Inject CSS link before </head>
    if ! grep -q "antigravity-chat-rtl.css" "$HTML_FILE"; then
        sed -i '/<\/head>/i \	<link rel="stylesheet" href="../../../workbench/antigravity-chat-rtl.css">' "$HTML_FILE"
        echo -e "${GREEN}[✓] Injected antigravity-chat-rtl.css into workbench.html${NC}"
    else
        echo -e "${YELLOW}[i] CSS link already present in workbench.html${NC}"
    fi

    # Inject JS script before </html>
    if ! grep -q "antigravity-chat-rtl.js" "$HTML_FILE"; then
        sed -i '/<\/html>/i \	<script src="../../../workbench/antigravity-chat-rtl.js"></script>' "$HTML_FILE"
        echo -e "${GREEN}[✓] Injected antigravity-chat-rtl.js into workbench.html${NC}"
    else
        echo -e "${YELLOW}[i] JS script already present in workbench.html${NC}"
    fi
}

patch_product_json() {
    echo -e "${CYAN}[*] Removing checksum verification for workbench.html in $PRODUCT_JSON${NC}"
    if [[ ! -f "$PRODUCT_JSON.bak" ]]; then
        cp "$PRODUCT_JSON" "$PRODUCT_JSON.bak"
        echo -e "${BLUE}[i] Created backup: $PRODUCT_JSON.bak${NC}"
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
    echo -e "${GREEN}[✓] Checksum bypass applied (prevents unsupported / corrupt warnings).${NC}"
}

setup_markdown_preview() {
    echo -e "${CYAN}[*] Configuring user Markdown preview (Ctrl+Shift+V)...${NC}"
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

    echo -e "${GREEN}[✓] Markdown RTL preview styles & settings configured.${NC}"
}

do_install() {
    ensure_root "$@"
    echo -e "${BOLD}${BLUE}=== Installing Antigravity IDE RTL & Vazirmatn Font ===${NC}"
    check_fonts
    write_css_file
    write_js_file
    patch_workbench_html
    patch_product_json
    setup_markdown_preview
    echo ""
    echo -e "${BOLD}${GREEN}✔ Antigravity IDE RTL successfully installed!${NC}"
    echo -e "${CYAN}Please restart Antigravity IDE to apply all visual changes.${NC}"
}

do_uninstall() {
    ensure_root "$@"
    echo -e "${BOLD}${YELLOW}=== Reverting Antigravity IDE RTL Setup ===${NC}"

    # Restore workbench.html
    if [[ -f "$HTML_FILE" ]]; then
        if [[ -f "$HTML_FILE.bak" ]]; then
            cp -f "$HTML_FILE.bak" "$HTML_FILE"
            rm -f "$HTML_FILE.bak"
            echo -e "${GREEN}[✓] Restored workbench.html from backup.${NC}"
        else
            sed -i '/antigravity-chat-rtl\.css/d' "$HTML_FILE"
            sed -i '/antigravity-chat-rtl\.js/d' "$HTML_FILE"
            echo -e "${GREEN}[✓] Removed RTL tags from workbench.html.${NC}"
        fi
    fi

    # Remove CSS and JS
    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.css" ]]; then
        rm -f "$WORKBENCH_DIR/antigravity-chat-rtl.css"
        echo -e "${GREEN}[✓] Removed antigravity-chat-rtl.css.${NC}"
    fi

    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.js" ]]; then
        rm -f "$WORKBENCH_DIR/antigravity-chat-rtl.js"
        echo -e "${GREEN}[✓] Removed antigravity-chat-rtl.js.${NC}"
    fi

    # Restore product.json
    if [[ -f "$PRODUCT_JSON.bak" ]]; then
        cp -f "$PRODUCT_JSON.bak" "$PRODUCT_JSON"
        rm -f "$PRODUCT_JSON.bak"
        echo -e "${GREEN}[✓] Restored product.json from backup.${NC}"
    fi

    # Clean up markdown css & settings
    if [[ -f "$MARKDOWN_CSS" ]]; then
        rm -f "$MARKDOWN_CSS"
        echo -e "${GREEN}[✓] Removed markdown-rtl.css.${NC}"
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
        echo -e "${GREEN}[✓] Cleaned up markdown styles from settings.json.${NC}"
    fi

    echo ""
    echo -e "${BOLD}${GREEN}✔ Antigravity IDE RTL uninstalled cleanly.${NC}"
    echo -e "${CYAN}Please restart Antigravity IDE.${NC}"
}

do_status() {
    echo -e "${BOLD}=== Antigravity IDE RTL Status ===${NC}"
    echo -e "  App Directory:    ${CYAN}$APP_DIR${NC}"
    echo -e "  Target User:      ${CYAN}$REAL_USER${NC}"
    echo -e "  User Config:      ${CYAN}$USER_CONFIG_DIR${NC}"
    echo ""

    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.css" ]]; then
        echo -e "  Workbench CSS:    ${GREEN}Installed${NC}"
    else
        echo -e "  Workbench CSS:    ${RED}Missing${NC}"
    fi

    if [[ -f "$WORKBENCH_DIR/antigravity-chat-rtl.js" ]]; then
        echo -e "  Workbench JS:     ${GREEN}Installed${NC}"
    else
        echo -e "  Workbench JS:     ${RED}Missing${NC}"
    fi

    if grep -q "antigravity-chat-rtl.css" "$HTML_FILE" 2>/dev/null && grep -q "antigravity-chat-rtl.js" "$HTML_FILE" 2>/dev/null; then
        echo -e "  workbench.html:   ${GREEN}Patched (CSS & JS linked)${NC}"
    elif grep -q "antigravity-chat-rtl.css" "$HTML_FILE" 2>/dev/null; then
        echo -e "  workbench.html:   ${YELLOW}Partially Patched (CSS only)${NC}"
    else
        echo -e "  workbench.html:   ${RED}Not Patched${NC}"
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
        echo -e "  Checksum Bypass:  ${GREEN}Active (No corrupt warning)${NC}"
    else
        echo -e "  Checksum Bypass:  ${YELLOW}Pending / Not Bypassed${NC}"
    fi

    if [[ -f "$MARKDOWN_CSS" ]]; then
        echo -e "  Markdown Preview: ${GREEN}Configured${NC}"
    else
        echo -e "  Markdown Preview: ${YELLOW}Not Configured${NC}"
    fi
}

case "${1:-install}" in
    install|setup)
        do_install "$@"
        ;;
    uninstall|remove|restore)
        do_uninstall "$@"
        ;;
    status)
        do_status
        ;;
    help|--help|-h)
        echo "Usage: $(basename "$0") [install|uninstall|status|help]"
        echo ""
        echo "Commands:"
        echo "  install    Install RTL CSS, JS, workbench patches and Vazirmatn font styling (default)"
        echo "  uninstall  Revert all patches and restore original workbench files"
        echo "  status     Check current installation and patch status"
        echo "  help       Show this help message"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Usage: $(basename "$0") [install|uninstall|status|help]"
        exit 1
        ;;
esac
