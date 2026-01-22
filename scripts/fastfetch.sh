#!/bin/bash

# Fastfetch Installation and Auto-Run Setup Script for Arch Linux (Hyprland)
# This script installs fastfetch, copies custom config, and configures auto-run

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory (where PigOS configs are located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$(dirname "$SCRIPT_DIR")/configs/fastfetch"

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║           🐷 PigOS Fastfetch Installation Script          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}✗ Error: This script is designed for Arch Linux${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Arch Linux detected${NC}"

# Check if Hyprland is installed
if command -v hyprctl &> /dev/null; then
    echo -e "${GREEN}✓ Hyprland detected${NC}"
else
    echo -e "${YELLOW}⚠ Hyprland not detected (some features in config may not work)${NC}"
fi

# Check if PigOS configs exist
if [ ! -d "$CONFIGS_DIR" ]; then
    echo -e "${RED}✗ Error: PigOS fastfetch configs not found at $CONFIGS_DIR${NC}"
    echo -e "${YELLOW}Make sure you're running this script from the PigOS repository${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PigOS fastfetch configs found${NC}"

echo ""

# Install fastfetch
echo -e "${YELLOW}► Installing fastfetch...${NC}"
if command -v fastfetch &> /dev/null; then
    echo -e "${GREEN}  ✓ Fastfetch is already installed!${NC}"
    echo -e "${YELLOW}  Upgrading to latest version...${NC}"
    sudo pacman -S --needed --noconfirm fastfetch
else
    sudo pacman -S --noconfirm fastfetch
    echo -e "${GREEN}  ✓ Fastfetch installed successfully!${NC}"
fi

echo ""

# Setup fastfetch config directory
FASTFETCH_CONFIG_DIR="$HOME/.config/fastfetch"
echo -e "${YELLOW}► Setting up fastfetch configuration...${NC}"

# Create config directory if it doesn't exist
mkdir -p "$FASTFETCH_CONFIG_DIR"

# Backup existing config if present
if [ -f "$FASTFETCH_CONFIG_DIR/config.jsonc" ]; then
    BACKUP_FILE="$FASTFETCH_CONFIG_DIR/config.jsonc.backup.$(date +%Y%m%d%H%M%S)"
    cp "$FASTFETCH_CONFIG_DIR/config.jsonc" "$BACKUP_FILE"
    echo -e "${BLUE}  ℹ Existing config backed up to: ${BACKUP_FILE}${NC}"
fi

# Copy PigOS fastfetch config
cp "$CONFIGS_DIR/config.jsonc" "$FASTFETCH_CONFIG_DIR/config.jsonc"
echo -e "${GREEN}  ✓ PigOS config.jsonc copied${NC}"

# Copy logo files if they exist
if [ -d "$CONFIGS_DIR/logo" ]; then
    mkdir -p "$FASTFETCH_CONFIG_DIR/logo"
    cp -r "$CONFIGS_DIR/logo/"* "$FASTFETCH_CONFIG_DIR/logo/" 2>/dev/null || true
    echo -e "${GREEN}  ✓ Custom logo files copied${NC}"
    
    # List available logos
    echo -e "${BLUE}  Available logos:${NC}"
    for logo in "$FASTFETCH_CONFIG_DIR/logo"/*; do
        if [ -f "$logo" ]; then
            echo -e "${BLUE}    • $(basename "$logo")${NC}"
        fi
    done
fi

echo ""

# Create fastfetch.sh helper script in local bin
echo -e "${YELLOW}► Creating fastfetch helper script...${NC}"
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Create the logo helper script that the config references
cat > "$LOCAL_BIN/fastfetch.sh" << 'HELPEREOF'
#!/bin/bash

# Fastfetch helper script for PigOS
# Usage: fastfetch.sh logo - Returns path to current logo

FASTFETCH_LOGO_DIR="$HOME/.config/fastfetch/logo"
DEFAULT_LOGO="$FASTFETCH_LOGO_DIR/pochita.icon"

case "$1" in
    logo)
        # Check for custom logo selection file
        if [ -f "$HOME/.config/fastfetch/.current_logo" ]; then
            SELECTED_LOGO=$(cat "$HOME/.config/fastfetch/.current_logo")
            if [ -f "$FASTFETCH_LOGO_DIR/$SELECTED_LOGO" ]; then
                echo "$FASTFETCH_LOGO_DIR/$SELECTED_LOGO"
                exit 0
            fi
        fi
        
        # Use default logo
        if [ -f "$DEFAULT_LOGO" ]; then
            echo "$DEFAULT_LOGO"
        else
            # Find first available logo
            FIRST_LOGO=$(find "$FASTFETCH_LOGO_DIR" -type f -name "*.icon" 2>/dev/null | head -1)
            if [ -n "$FIRST_LOGO" ]; then
                echo "$FIRST_LOGO"
            fi
        fi
        ;;
    set-logo)
        # Set a specific logo
        if [ -n "$2" ]; then
            echo "$2" > "$HOME/.config/fastfetch/.current_logo"
            echo "Logo set to: $2"
        else
            echo "Usage: fastfetch.sh set-logo <logo-name>"
            echo "Available logos:"
            ls "$FASTFETCH_LOGO_DIR"
        fi
        ;;
    list-logos)
        echo "Available logos:"
        ls "$FASTFETCH_LOGO_DIR" 2>/dev/null || echo "No logos found"
        ;;
    *)
        echo "PigOS Fastfetch Helper"
        echo "Commands:"
        echo "  logo       - Get current logo path"
        echo "  set-logo   - Set a logo (e.g., fastfetch.sh set-logo pochita.icon)"
        echo "  list-logos - List available logos"
        ;;
esac
HELPEREOF

chmod +x "$LOCAL_BIN/fastfetch.sh"
echo -e "${GREEN}  ✓ Helper script created at $LOCAL_BIN/fastfetch.sh${NC}"

# Add ~/.local/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}  Adding ~/.local/bin to PATH...${NC}"
fi

echo ""

# Detect shell
SHELL_NAME=$(basename "$SHELL")
echo -e "${YELLOW}► Configuring shell ($SHELL_NAME)...${NC}"

# Configure auto-run for all detected shells
RECOGNIZED_SHELLS=("bash" "zsh" "fish")
CONFIG_APPLIED=false

for SH in "${RECOGNIZED_SHELLS[@]}"; do
    case "$SH" in
        bash) RC_FILE="$HOME/.bashrc" ;;
        zsh) RC_FILE="$HOME/.zshrc" ;;
        fish) 
            RC_FILE="$HOME/.config/fish/config.fish"
            mkdir -p "$HOME/.config/fish"
            ;;
    esac

    if [ -f "$RC_FILE" ] || [ "$SH" == "$SHELL_NAME" ]; then
        echo -e "${YELLOW}  Configuring $SH ($RC_FILE)...${NC}"
        
        # Add PATH for local bin if needed
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$RC_FILE" 2>/dev/null && [ "$SH" != "fish" ]; then
            echo "" >> "$RC_FILE"
            echo '# Add local bin to PATH (for PigOS scripts)' >> "$RC_FILE"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
            echo -e "${GREEN}    ✓ Added PATH to $RC_FILE${NC}"
        elif [ "$SH" == "fish" ] && ! grep -q 'fish_add_path "$HOME/.local/bin"' "$RC_FILE" 2>/dev/null; then
            echo "" >> "$RC_FILE"
            echo '# Add local bin to PATH' >> "$RC_FILE"
            echo 'fish_add_path "$HOME/.local/bin"' >> "$RC_FILE"
            echo -e "${GREEN}    ✓ Added PATH to $RC_FILE${NC}"
        fi
        
        # Check if fastfetch is already in the RC file
        if grep -q "fastfetch" "$RC_FILE" 2>/dev/null; then
            echo -e "${BLUE}    ℹ Fastfetch already in $RC_FILE${NC}"
        else
            echo "" >> "$RC_FILE"
            echo "# Run fastfetch on terminal startup (PigOS)" >> "$RC_FILE"
            if [ "$SH" == "fish" ]; then
                echo "alias fastfetch='fastfetch --config \$HOME/.config/fastfetch/config.jsonc'" >> "$RC_FILE"
                echo "fastfetch" >> "$RC_FILE"
            else
                echo "alias fastfetch='fastfetch --config \$HOME/.config/fastfetch/config.jsonc'" >> "$RC_FILE"
                echo "fastfetch" >> "$RC_FILE"
            fi
            echo -e "${GREEN}    ✓ Fastfetch added to $RC_FILE${NC}"
        fi
        CONFIG_APPLIED=true
    fi
done

if [ "$CONFIG_APPLIED" = false ]; then
    echo -e "${RED}  ✗ No common shell RC files found. Adding to $HOME/.bashrc by default.${NC}"
    echo "fastfetch --config $HOME/.config/fastfetch/config.jsonc" >> "$HOME/.bashrc"
fi

echo ""

# Set default logo
if [ -f "$FASTFETCH_CONFIG_DIR/logo/pochita.icon" ]; then
    echo "pochita.icon" > "$FASTFETCH_CONFIG_DIR/.current_logo"
    echo -e "${GREEN}✓ Default logo set to pochita.icon${NC}"
elif [ -d "$FASTFETCH_CONFIG_DIR/logo" ]; then
    FIRST_LOGO=$(ls "$FASTFETCH_CONFIG_DIR/logo" 2>/dev/null | head -1)
    if [ -n "$FIRST_LOGO" ]; then
        echo "$FIRST_LOGO" > "$FASTFETCH_CONFIG_DIR/.current_logo"
        echo -e "${GREEN}✓ Default logo set to $FIRST_LOGO${NC}"
    fi
fi

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}               ${GREEN}✓ Setup Complete!${NC}                         ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}What's installed:${NC}"
echo -e "  • fastfetch - system info tool"
echo -e "  • PigOS custom config at ~/.config/fastfetch/"
echo -e "  • Custom logos for the display"
echo -e "  • Auto-run on terminal startup"
echo ""
echo -e "${YELLOW}Commands:${NC}"
echo -e "  ${GREEN}fastfetch${NC}                    - Run fastfetch"
echo -e "  ${GREEN}fastfetch.sh list-logos${NC}      - List available logos"
echo -e "  ${GREEN}fastfetch.sh set-logo NAME${NC}   - Change logo"
echo ""
echo -e "${YELLOW}To see it in action:${NC}"
echo -e "  1. Open a new terminal, or"
echo -e "  2. Run: ${GREEN}source $RC_FILE && fastfetch${NC}"
echo ""