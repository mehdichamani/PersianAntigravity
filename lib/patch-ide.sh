#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - IDE Patcher (Workbench & Markdown)
# ==============================================================================

patch_ide() {
    local wb_dir="$APP_DIR/out/vs/workbench"
    local html_file="$APP_DIR/out/vs/code/electron-browser/workbench/workbench.html"
    local prod_file="$APP_DIR/product.json"

    # 1. Copy CSS
    local target_css="$wb_dir/antigravity-chat-rtl.css"
    echo -e "${CYAN}${M[WRITE_CSS]}$target_css${NC}"
    if [[ ! -f "$SCRIPT_DIR/styles/antigravity-chat-rtl.css" ]]; then
        echo -e "${RED}[✗] Missing styles/antigravity-chat-rtl.css in repository!${NC}"
        return 1
    fi
    cp -f "$SCRIPT_DIR/styles/antigravity-chat-rtl.css" "$target_css"

    # 2. Copy JS
    local target_js="$wb_dir/antigravity-chat-rtl.js"
    echo -e "${CYAN}${M[WRITE_JS]}$target_js${NC}"
    if [[ ! -f "$SCRIPT_DIR/scripts/antigravity-chat-rtl.js" ]]; then
        echo -e "${RED}[✗] Missing scripts/antigravity-chat-rtl.js in repository!${NC}"
        return 1
    fi
    cp -f "$SCRIPT_DIR/scripts/antigravity-chat-rtl.js" "$target_js"

    # 3. Patch workbench.html
    echo -e "${CYAN}${M[PATCH_HTML]}$html_file${NC}"
    if [[ ! -f "$html_file.bak" ]]; then
        cp "$html_file" "$html_file.bak"
        echo -e "${BLUE}${M[BACKUP_CREATED]}$html_file.bak${NC}"
    fi

    if ! grep -q "antigravity-chat-rtl.css" "$html_file"; then
        sed -i '/<\/head>/i \	<link rel="stylesheet" href="../../../workbench/antigravity-chat-rtl.css">' "$html_file"
        echo -e "${GREEN}${M[INJECT_CSS]}${NC}"
    else
        echo -e "${YELLOW}${M[CSS_EXISTS]}${NC}"
    fi

    if ! grep -q "antigravity-chat-rtl.js" "$html_file"; then
        sed -i '/<\/html>/i \	<script src="../../../workbench/antigravity-chat-rtl.js"></script>' "$html_file"
        echo -e "${GREEN}${M[INJECT_JS]}${NC}"
    else
        echo -e "${YELLOW}${M[JS_EXISTS]}${NC}"
    fi

    # 4. Patch product.json (Checksum bypass)
    echo -e "${CYAN}${M[REMOVE_CHK]}$prod_file${NC}"
    if [[ ! -f "$prod_file.bak" ]]; then
        cp "$prod_file" "$prod_file.bak"
        echo -e "${BLUE}${M[BACKUP_CREATED]}$prod_file.bak${NC}"
    fi

    python3 -c "
import json
prod_path = '$prod_file'
with open(prod_path, 'r', encoding='utf-8') as f:
    data = json.load(f)
checksums = data.get('checksums', {})
target_key = 'vs/code/electron-browser/workbench/workbench.html'
if target_key in checksums:
    del checksums[target_key]
    with open(prod_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
" 2>/dev/null || true
    echo -e "${GREEN}${M[CHK_BYPASSED]}${NC}"

    # 5. Markdown Preview Setup
    setup_markdown_preview
}

unpatch_ide() {
    local wb_dir="$APP_DIR/out/vs/workbench"
    local html_file="$APP_DIR/out/vs/code/electron-browser/workbench/workbench.html"
    local prod_file="$APP_DIR/product.json"

    # Restore workbench.html
    if [[ -f "$html_file" ]]; then
        if [[ -f "$html_file.bak" ]]; then
            cp -f "$html_file.bak" "$html_file"
            rm -f "$html_file.bak"
            echo -e "${GREEN}${M[RESTORE_HTML]}${NC}"
        else
            sed -i '/antigravity-chat-rtl\.css/d' "$html_file"
            sed -i '/antigravity-chat-rtl\.js/d' "$html_file"
            echo -e "${GREEN}${M[REMOVE_TAGS]}${NC}"
        fi
    fi

    # Remove CSS and JS
    if [[ -f "$wb_dir/antigravity-chat-rtl.css" ]]; then
        rm -f "$wb_dir/antigravity-chat-rtl.css"
        echo -e "${GREEN}${M[REMOVE_CSS]}${NC}"
    fi

    if [[ -f "$wb_dir/antigravity-chat-rtl.js" ]]; then
        rm -f "$wb_dir/antigravity-chat-rtl.js"
        echo -e "${GREEN}${M[REMOVE_JS]}${NC}"
    fi

    # Restore product.json
    if [[ -f "$prod_file.bak" ]]; then
        cp -f "$prod_file.bak" "$prod_file"
        rm -f "$prod_file.bak"
        echo -e "${GREEN}${M[RESTORE_PROD]}${NC}"
    fi

    # Clean up markdown preview
    if [[ -f "$MARKDOWN_CSS" ]]; then
        rm -f "$MARKDOWN_CSS"
        echo -e "${GREEN}${M[REMOVE_MD_CSS]}${NC}"
    fi

    if [[ -f "$SETTINGS_JSON" ]]; then
        python3 -c "
import json, os
s_path = '$SETTINGS_JSON'
m_path = '$MARKDOWN_CSS'
if os.path.exists(s_path):
    try:
        with open(s_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        styles = data.get('markdown.styles', [])
        if isinstance(styles, list) and m_path in styles:
            styles.remove(m_path)
            data['markdown.styles'] = styles
        with open(s_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
    except Exception:
        pass
" 2>/dev/null || true
        echo -e "${GREEN}${M[CLEAN_MD_SETTING]}${NC}"
    fi
}

setup_markdown_preview() {
    echo -e "${CYAN}${M[CFG_MD]}${NC}"
    mkdir -p "$USER_CONFIG_DIR"

    if [[ -f "$SCRIPT_DIR/styles/markdown-rtl.css" ]]; then
        cp -f "$SCRIPT_DIR/styles/markdown-rtl.css" "$MARKDOWN_CSS"
    fi

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

    if id "$REAL_USER" &>/dev/null; then
        chown -R "$REAL_USER:$(id -gn "$REAL_USER")" "$USER_CONFIG_DIR" 2>/dev/null || true
    fi

    echo -e "${GREEN}${M[MD_CONFIGURED]}${NC}"
}
