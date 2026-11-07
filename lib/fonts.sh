#!/usr/bin/env bash
# ==============================================================================
# PersianAntigravity - Font Checker & Installer
# ==============================================================================

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
