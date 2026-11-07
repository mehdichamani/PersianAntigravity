#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - Desktop App Patcher (app.asar)
# ==============================================================================

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
