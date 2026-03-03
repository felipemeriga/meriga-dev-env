#!/usr/bin/env bash

set -e

echo "================================"
echo "Dotfiles Installation Script"
echo "================================"
echo ""

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Tool versions (update these to upgrade) ──────────────────────────
FISH_VERSION="4.2.1"
NEOVIM_VERSION="0.11.6"
YAZI_VERSION="0.4.2"

# ── Colors ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_info()    { echo -e "${YELLOW}→${NC} $1"; }

# ── OS / Arch detection ───────────────────────────────────────────────
detect_platform() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)  OS="ubuntu" ;;
        *)      OS="unknown" ;;
    esac

    case "$(uname -m)" in
        x86_64)       ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *)            ARCH="unknown" ;;
    esac

    export OS ARCH
    print_info "Platform: $OS ($ARCH)"
}

# ── macOS install (Homebrew) ──────────────────────────────────────────
install_macos() {
    if ! command -v brew &> /dev/null; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_info "Installing tools via Homebrew..."
    brew install git curl ripgrep fd fish neovim yazi

    print_success "All tools installed via Homebrew"
}

# ── Ubuntu install (apt + pre-built binaries) ─────────────────────────
install_ubuntu() {
    print_info "Installing system packages..."
    sudo apt-get update
    sudo apt-get install -y \
        git curl wget build-essential unzip ripgrep fd-find

    install_fish_binary
    install_neovim_binary
    install_yazi_binary
}

install_fish_binary() {
    if command -v fish &> /dev/null; then
        local current
        current="$(fish --version 2>/dev/null | grep -oP '[\d.]+' | head -1)"
        if [ "$current" = "$FISH_VERSION" ]; then
            print_success "Fish $FISH_VERSION already installed"
            return
        fi
    fi

    print_info "Installing Fish $FISH_VERSION..."
    local url="https://github.com/fish-shell/fish-shell/releases/download/$FISH_VERSION/fish-$FISH_VERSION-linux-x86_64.tar.xz"
    local tmp
    tmp="$(mktemp -d)"

    wget -qO "$tmp/fish.tar.xz" "$url"
    tar -xf "$tmp/fish.tar.xz" -C "$tmp"
    sudo install -m755 "$tmp/fish" /usr/local/bin/fish
    rm -rf "$tmp"

    # Register as valid login shell
    if ! grep -q "/usr/local/bin/fish" /etc/shells; then
        echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
    fi

    print_success "Fish $FISH_VERSION installed"
}

install_neovim_binary() {
    if command -v nvim &> /dev/null; then
        print_success "Neovim already installed"
        return
    fi

    print_info "Installing Neovim $NEOVIM_VERSION..."
    local url="https://github.com/neovim/neovim/releases/download/v$NEOVIM_VERSION/nvim-linux-x86_64.tar.gz"
    local tmp
    tmp="$(mktemp -d)"

    wget -qO "$tmp/nvim.tar.gz" "$url"
    sudo tar -xzf "$tmp/nvim.tar.gz" -C /opt
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm -rf "$tmp"

    print_success "Neovim $NEOVIM_VERSION installed"
}

install_yazi_binary() {
    if command -v yazi &> /dev/null; then
        print_success "Yazi already installed"
        return
    fi

    print_info "Installing Yazi $YAZI_VERSION..."
    local url="https://github.com/sxyazi/yazi/releases/download/v$YAZI_VERSION/yazi-x86_64-unknown-linux-gnu.zip"
    local tmp
    tmp="$(mktemp -d)"

    wget -qO "$tmp/yazi.zip" "$url"
    unzip -qo "$tmp/yazi.zip" -d "$tmp"
    sudo install -m755 "$tmp/yazi-x86_64-unknown-linux-gnu/yazi" /usr/local/bin/yazi
    rm -rf "$tmp"

    print_success "Yazi $YAZI_VERSION installed"
}

# ── Shared config setup ───────────────────────────────────────────────
backup_configs() {
    print_info "Backing up existing configurations..."
    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    [ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$backup_dir/"
    [ -d "$HOME/.config/fish" ] && cp -r "$HOME/.config/fish" "$backup_dir/"
    [ -d "$HOME/.config/yazi" ] && cp -r "$HOME/.config/yazi" "$backup_dir/"

    print_success "Backup created at $backup_dir"
}

setup_neovim() {
    print_info "Setting up Neovim..."
    rm -rf "$HOME/.config/nvim"
    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    print_success "Neovim configuration linked"
}

setup_fish() {
    print_info "Setting up Fish shell..."
    rm -rf "$HOME/.config/fish"
    ln -sf "$DOTFILES_DIR/fish" "$HOME/.config/fish"

    # Install Fisher + plugins
    print_info "Installing Fisher plugin manager..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

    if [ -f "$DOTFILES_DIR/fish/fish_plugins" ]; then
        print_info "Installing Fish plugins..."
        fish -c "fisher update"
    fi

    # Set Fish as default shell
    local fish_path
    fish_path="$(command -v fish)"
    if ! grep -q "$fish_path" /etc/shells; then
        echo "$fish_path" | sudo tee -a /etc/shells
    fi
    if [ "$SHELL" != "$fish_path" ]; then
        print_info "Changing default shell to Fish..."
        chsh -s "$fish_path" "${USER:-root}" && \
            print_success "Default shell changed to Fish" || \
            print_info "Run manually: chsh -s $fish_path"
    fi

    print_success "Fish shell configured"
}

setup_yazi() {
    print_info "Setting up Yazi..."
    rm -rf "$HOME/.config/yazi"
    ln -sf "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"
    print_success "Yazi configuration linked"
}

# ── Main ──────────────────────────────────────────────────────────────
main() {
    read -p "Install dependencies and link dotfiles? (y/n) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && { print_error "Cancelled"; exit 1; }

    detect_platform

    case "$OS" in
        macos)  install_macos ;;
        ubuntu) install_ubuntu ;;
        *)      print_error "Unsupported OS: $OS"; exit 1 ;;
    esac

    backup_configs
    setup_neovim
    setup_fish
    setup_yazi

    echo ""
    echo "================================"
    print_success "Installation complete!"
    echo "================================"
    echo ""
    print_info "Next steps:"
    print_info "  1. Open Neovim — plugins auto-install on first launch"
    print_info "  2. Restart terminal or run: exec fish"
    echo ""
}

main
