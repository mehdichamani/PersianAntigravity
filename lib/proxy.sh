#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - System Proxy Launcher Setup
# ==============================================================================

setup_proxy_launcher() {
    echo -e "${CYAN}${M[PROXY_HEADER]}${NC}"

    local bin_dir="$REAL_HOME/.local/bin"
    local app_dir_desk="$REAL_HOME/.local/share/applications"
    mkdir -p "$bin_dir" "$app_dir_desk"

    local target_script="$bin_dir/antigravity-proxy"
    local source_script="$SCRIPT_DIR/scripts/antigravity-proxy.sh"

    if [[ ! -f "$source_script" ]]; then
        echo -e "${RED}[✗] Missing scripts/antigravity-proxy.sh in repository!${NC}"
        return 1
    fi

    cp -f "$source_script" "$target_script"
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
