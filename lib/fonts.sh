#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - Font Checker & Installer
# ==============================================================================

check_fonts() {
    local is_installed="false"

    if command -v fc-match &>/dev/null; then
        local match_fam
        match_fam=$(fc-match -f "%{family}\n" "Vazirmatn" 2>/dev/null || true)
        if [[ "$match_fam" =~ ^[Vv]azirmatn ]]; then
            is_installed="true"
        fi
    elif command -v fc-list &>/dev/null; then
        if fc-list : family | grep -i "vazirmatn" >/dev/null 2>&1; then
            is_installed="true"
        fi
    fi

    if [[ "$is_installed" == "true" ]]; then
        echo -e "${GREEN}${M[FONT_DETECTED]}${NC}"
        return 0
    fi

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
}
