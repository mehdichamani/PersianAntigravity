#!/usr/bin/env bash
# ==============================================================================
# Antigravity IDE Proxy Injector & Launcher (Linux / macOS)
# Automatically detects system proxy from GNOME, KDE, macOS, or shell envs
# and launches Antigravity IDE with proper proxy environment variables.
# ==============================================================================

set -e

# Target binary resolution
TARGET_CMD="antigravity-ide"
if ! command -v "$TARGET_CMD" &>/dev/null; then
    # Fallback to standard installation paths
    if [[ -f "/usr/share/antigravity-ide/antigravity-ide" ]]; then
        TARGET_CMD="/usr/share/antigravity-ide/antigravity-ide"
    elif [[ -f "/opt/Antigravity IDE/antigravity-ide" ]]; then
        TARGET_CMD="/opt/Antigravity IDE/antigravity-ide"
    elif [[ -f "$HOME/.local/bin/antigravity-ide" ]]; then
        TARGET_CMD="$HOME/.local/bin/antigravity-ide"
    elif [[ -d "/Applications/Antigravity IDE.app" ]]; then
        TARGET_CMD="/Applications/Antigravity IDE.app/Contents/MacOS/Electron"
    fi
fi

DETECTED_PROXY=""

# 1. Check existing shell/system environment variables
if [[ -n "${http_proxy:-}" ]]; then
    DETECTED_PROXY="$http_proxy"
elif [[ -n "${HTTP_PROXY:-}" ]]; then
    DETECTED_PROXY="$HTTP_PROXY"
elif [[ -n "${all_proxy:-}" ]]; then
    DETECTED_PROXY="$all_proxy"
elif [[ -n "${ALL_PROXY:-}" ]]; then
    DETECTED_PROXY="$ALL_PROXY"
fi

# 2. GNOME / Cinnamon / XFCE (gsettings)
if [[ -z "$DETECTED_PROXY" ]] && command -v gsettings &>/dev/null; then
    PROXY_MODE=$(gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'")
    if [[ "$PROXY_MODE" == "manual" ]]; then
        HOST=$(gsettings get org.gnome.system.proxy.http host 2>/dev/null | tr -d "'")
        PORT=$(gsettings get org.gnome.system.proxy.http port 2>/dev/null)
        if [[ -n "$HOST" && "$PORT" -gt 0 ]]; then
            DETECTED_PROXY="http://${HOST}:${PORT}"
        fi
    fi
fi

# 3. KDE Plasma 5 & 6 (kreadconfig)
if [[ -z "$DETECTED_PROXY" ]] && command -v kreadconfig5 &>/dev/null; then
    PROXY_TYPE=$(kreadconfig5 --file kioslaverc --group "Proxy Settings" --key "ProxyType" 2>/dev/null || true)
    if [[ "$PROXY_TYPE" == "1" ]]; then
        HTTP_URL=$(kreadconfig5 --file kioslaverc --group "Proxy Settings" --key "httpProxy" 2>/dev/null || true)
        [[ -n "$HTTP_URL" ]] && DETECTED_PROXY="$HTTP_URL"
    fi
fi
if [[ -z "$DETECTED_PROXY" ]] && command -v kreadconfig6 &>/dev/null; then
    PROXY_TYPE=$(kreadconfig6 --file kioslaverc --group "Proxy Settings" --key "ProxyType" 2>/dev/null || true)
    if [[ "$PROXY_TYPE" == "1" ]]; then
        HTTP_URL=$(kreadconfig6 --file kioslaverc --group "Proxy Settings" --key "httpProxy" 2>/dev/null || true)
        [[ -n "$HTTP_URL" ]] && DETECTED_PROXY="$HTTP_URL"
    fi
fi

# 4. macOS (scutil)
if [[ -z "$DETECTED_PROXY" ]] && command -v scutil &>/dev/null; then
    PROXY_INFO=$(scutil --proxy 2>/dev/null || true)
    HTTP_ENABLE=$(echo "$PROXY_INFO" | awk '/HTTPEnable/ {print $3}')
    if [[ "$HTTP_ENABLE" == "1" ]]; then
        HTTP_HOST=$(echo "$PROXY_INFO" | awk '/HTTPProxy/ {print $3}')
        HTTP_PORT=$(echo "$PROXY_INFO" | awk '/HTTPPort/ {print $3}')
        if [[ -n "$HTTP_HOST" && -n "$HTTP_PORT" ]]; then
            DETECTED_PROXY="http://${HTTP_HOST}:${HTTP_PORT}"
        fi
    fi
fi

# 5. Fallback interactive prompt if running in interactive terminal
if [[ -z "$DETECTED_PROXY" ]] && [ -t 0 ]; then
    DEFAULT_FALLBACK="http://127.0.0.1:10809"
    echo "⚠️  هیچ پروکسی سیستمی فعالی شناسایی نشد."
    read -r -p "لطفاً آدرس پروکسی را وارد کنید [پیش‌فرض: $DEFAULT_FALLBACK]: " USER_INPUT || USER_INPUT=""
    DETECTED_PROXY="${USER_INPUT:-$DEFAULT_FALLBACK}"
fi

# Sanitize proxy url scheme
if [[ -n "$DETECTED_PROXY" && ! "$DETECTED_PROXY" =~ ^[a-zA-Z0-9]+:// ]]; then
    DETECTED_PROXY="http://$DETECTED_PROXY"
fi

# 6. Inject proxy variables if resolved
if [[ -n "$DETECTED_PROXY" ]]; then
    echo "✅ پروکسی فعال شناسایی شد: $DETECTED_PROXY"
    export http_proxy="$DETECTED_PROXY"
    export https_proxy="$DETECTED_PROXY"
    export HTTP_PROXY="$DETECTED_PROXY"
    export HTTPS_PROXY="$DETECTED_PROXY"
    export all_proxy="$DETECTED_PROXY"
    export ALL_PROXY="$DETECTED_PROXY"
    export no_proxy="localhost,127.0.0.1,::1,localaddress,.local,192.168.0.0/16,10.0.0.0/8"
    export NO_PROXY="$no_proxy"
fi

echo "🚀 در حال اجرای: $TARGET_CMD"
exec "$TARGET_CMD" "$@"
