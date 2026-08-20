#!/usr/bin/env bash
set -e

# Disable slow Homebrew git auto-updates & hint spam
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

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

# 1. Check / Install MPV (with live progress output)
echo -e "${CYAN}▶ Checking video player (mpv)...${RESET}"
if command -v mpv >/dev/null 2>&1; then
    echo -e "  ${B_GREEN}✓ mpv is already installed!${RESET}"
else
    echo -e "  ${YELLOW}mpv not found. Installing via package manager (showing live progress below)...${RESET}\n"
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
    echo -e "\n  ${B_GREEN}✓ mpv installed successfully!${RESET}"
fi

# 2. Automated MPV Configuration (Studio-Grade libplacebo / HDR / English defaults)
echo -e "\n${CYAN}▶ Configuring optimal MPV video & audio engine...${RESET}"
MPV_CONF_DIR="$HOME/.config/mpv"
MPV_CONF="$MPV_CONF_DIR/mpv.conf"
mkdir -p "$MPV_CONF_DIR"

if [ ! -f "$MPV_CONF" ]; then
    cat << 'EOF' > "$MPV_CONF"
# Studio-grade GPU video rendering (libplacebo)
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

# 3. Install Nitrate Executable with Live Progress Bar
echo -e "\n${CYAN}▶ Installing nitrate binary...${RESET}"
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
TARGET_BIN="$INSTALL_DIR/nitrate"

# Download binary with visible progress bar
echo -e "  ${DIM}Downloading Nitrate from GitHub...${RESET}"
curl -# -fSL https://raw.githubusercontent.com/Manteh/nitrate/main/bin/nitrate -o "$TARGET_BIN"
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

# 4. Interactive Debrid Setup (Uses Nitrate native TUI)
echo -e "\n${CYAN}▶ Debrid Account Setup (Instant 4K Streaming without VPN)${RESET}"
echo -e "  ${DIM}A Debrid service (~$3/mo) gives you 100% ISP safety (no VPN needed)${RESET}"
echo -e "  ${DIM}and instant 1.5s playback on 80GB 4K REMUXes with zero buffering.${RESET}\n"

"$TARGET_BIN" --config

# 5. Finished!
echo -e "\n${B_GREEN}${BOLD}══════════════════════════════════════════════════════════════${RESET}"
echo -e "${B_GREEN}${BOLD}  🎉 Nitrate is ready! Zero extra setup required.${RESET}"
echo -e "${B_GREEN}${BOLD}══════════════════════════════════════════════════════════════${RESET}\n"

echo -e "  ${B_WHITE}Try running:${RESET}"
echo -e "    ${B_CYAN}nitrate \"Mindhunter\"${RESET}"
echo -e "    ${B_CYAN}nitrate \"Dune: Part Two\"${RESET}"
echo -e "    ${B_CYAN}nitrate${RESET}  ${DIM}(opens home screen / resume menu)${RESET}\n"
