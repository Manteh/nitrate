#!/usr/bin/env bash
set -e

# ==========================================
# 🎬 NITRATE — Zero-Friction 1-Line Installer
# ==========================================

ESC="\033["
RESET="${ESC}0m"
BOLD="${ESC}1m"
DIM="${ESC}2m"
GREEN="${ESC}32m"
CYAN="${ESC}36m"
YELLOW="${ESC}33m"
MAGENTA="${ESC}35m"
RED="${ESC}31m"
B_CYAN="${ESC}96m"
B_GREEN="${ESC}92m"
B_WHITE="${ESC}97m"

clear 2>/dev/null || true

echo -e "${B_CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║                                                              ║"
echo "  ║     🎬  N I T R A T E  —  C I N E M A  S T R E A M E R       ║"
echo "  ║        Direct-to-GPU 4K HDR & Lossless Master Audio          ║"
echo "  ║                                                              ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${B_WHITE}Starting zero-friction setup...${RESET}\n"

# 1. Check / Install MPV
echo -e "${CYAN}▶ Checking video player (mpv)...${RESET}"
if command -v mpv >/dev/null 2>&1; then
    echo -e "  ${B_GREEN}✓ mpv is already installed!${RESET}"
else
    echo -e "  ${YELLOW}mpv not found. Installing automatically...${RESET}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            brew install mpv
        else
            echo -e "  ${RED}Homebrew not found. Please install Homebrew first: https://brew.sh${RESET}"
            exit 1
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y mpv
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm mpv
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y mpv
    else
        echo -e "  ${RED}Please install mpv from https://mpv.io${RESET}"
        exit 1
    fi
fi

# 2. Automated MPV Configuration (Studio-Grade libplacebo / HDR / English defaults)
echo -e "\n${CYAN}▶ Configuring optimal MPV video & audio engine...${RESET}"
MPV_CONF_DIR="$HOME/.config/mpv"
MPV_CONF="$MPV_CONF_DIR/mpv.conf"
mkdir -p "$MPV_CONF_DIR"

if [ ! -f "$MPV_CONF" ]; then
    cat << 'EOF' > "$MPV_CONF"
# Studio-grade GPU video rendering
vo=gpu-next
hwdec=auto-safe

# High-speed Debrid network buffering
cache=yes
demuxer-max-bytes=512MiB
network-timeout=60

# Audio & Subtitle Defaults (English first)
alang=en,eng,lit,lt
slang=en,eng,lit,lt
subs-with-matching-audio=no

# UI
force-window=immediate
script-opts=osc-layout=bottombar
EOF
    echo -e "  ${B_GREEN}✓ Created studio-grade mpv.conf (libplacebo + 10-bit Dolby Vision enabled)${RESET}"
else
    echo -e "  ${DIM}✓ Existing mpv.conf preserved${RESET}"
fi

# 3. Install Nitrate Executable
echo -e "\n${CYAN}▶ Installing nitrate binary...${RESET}"
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
TARGET_BIN="$INSTALL_DIR/nitrate"

# Download binary
curl -fsSL https://raw.githubusercontent.com/Manteh/nitrate/main/bin/nitrate -o "$TARGET_BIN"
chmod +x "$TARGET_BIN"
echo -e "  ${B_GREEN}✓ Installed executable to $TARGET_BIN${RESET}"

# Also symlink torrentio-mpv to nitrate
ln -sf "$TARGET_BIN" "$INSTALL_DIR/torrentio-mpv" 2>/dev/null || true

# Ensure ~/.local/bin is in PATH
CURRENT_SHELL=$(basename "$SHELL")
RC_FILE="$HOME/.zshrc"
if [ "$CURRENT_SHELL" = "bash" ]; then
    RC_FILE="$HOME/.bashrc"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$RC_FILE"
    export PATH="$HOME/.local/bin:$PATH"
    echo -e "  ${B_GREEN}✓ Added ~/.local/bin to your PATH in $RC_FILE${RESET}"
fi

# 4. Interactive Debrid Setup
echo -e "\n${CYAN}▶ Debrid Account Setup (Instant 4K Streaming without VPN)${RESET}"
CONFIG_DIR="$HOME/.config/nitrate"
CONFIG_FILE="$CONFIG_DIR/config.json"
mkdir -p "$CONFIG_DIR"

EXISTING_TB_KEY=""
EXISTING_RD_KEY=""
if [ -f "$CONFIG_FILE" ]; then
    EXISTING_TB_KEY=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('torbox_key', ''))" 2>/dev/null || true)
    EXISTING_RD_KEY=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('rd_api_key', ''))" 2>/dev/null || true)
fi

echo -e "  ${DIM}A Debrid service (~$3/mo) gives you 100% ISP safety (no VPN needed)${RESET}"
echo -e "  ${DIM}and instant 1.5s playback on 80GB 4K REMUXes with zero buffering.${RESET}\n"

echo -e "  ${B_WHITE}Select your Debrid provider:${RESET}"
echo -e "    ${B_CYAN}[1]${RESET} TorBox (Recommended) ──► ${DIM}https://torbox.app/settings${RESET}"
echo -e "    ${B_CYAN}[2]${RESET} Real-Debrid           ──► ${DIM}https://real-debrid.com/apitoken${RESET}"
echo -e "    ${B_CYAN}[3]${RESET} Free P2P mode (No Debrid / Direct torrenting)"

echo ""
read -p "  Choose option [1-3] (Default: 1): " PROVIDER_CHOICE
PROVIDER_CHOICE=${PROVIDER_CHOICE:-1}

if [ "$PROVIDER_CHOICE" = "1" ]; then
    echo ""
    echo -e "  ${YELLOW}➔ Get your TorBox API key at: ${BOLD}https://torbox.app/settings${RESET}"
    read -p "  Paste your TorBox API Key: " USER_KEY
    USER_KEY=$(echo "$USER_KEY" | xargs)
    if [ -n "$USER_KEY" ]; then
        python3 -c "import json; cfg = {'torbox_key': '$USER_KEY'}; json.dump(cfg, open('$CONFIG_FILE', 'w'), indent=2)"
        echo -e "  ${B_GREEN}✓ TorBox key saved!${RESET}"
    fi
elif [ "$PROVIDER_CHOICE" = "2" ]; then
    echo ""
    echo -e "  ${YELLOW}➔ Get your Real-Debrid API key at: ${BOLD}https://real-debrid.com/apitoken${RESET}"
    read -p "  Paste your Real-Debrid API Key: " USER_KEY
    USER_KEY=$(echo "$USER_KEY" | xargs)
    if [ -n "$USER_KEY" ]; then
        python3 -c "import json; cfg = {'rd_api_key': '$USER_KEY'}; json.dump(cfg, open('$CONFIG_FILE', 'w'), indent=2)"
        echo -e "  ${B_GREEN}✓ Real-Debrid key saved!${RESET}"
    fi
else
    echo -e "  ${DIM}✓ Free P2P mode enabled. You can add a Debrid key anytime via: nitrate --config${RESET}"
fi

# 5. Finished!
echo -e "\n${B_GREEN}${BOLD}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${B_GREEN}${BOLD}  🎉 Nitrate is ready! Zero extra setup required.${RESET}"
echo -e "${B_GREEN}${BOLD}══════════════════════════════════════════════════════════════${RESET}\n"

echo -e "  ${B_WHITE}Try running:${RESET}"
echo -e "    ${B_CYAN}nitrate \"Mindhunter\"${RESET}"
echo -e "    ${B_CYAN}nitrate \"Dune: Part Two\"${RESET}"
echo -e "    ${B_CYAN}nitrate${RESET}  ${DIM}(opens home screen / resume menu)${RESET}\n"
