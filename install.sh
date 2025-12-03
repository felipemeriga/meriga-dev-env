#!/usr/bin/env bash

set -e

echo "================================"
echo "Dotfiles Installation Script"
echo "================================"
echo ""

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
        else
            OS="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    echo "$OS"
}

# Install dependencies based on OS
install_dependencies() {
    local os=$(detect_os)

    print_info "Detected OS: $os"
    print_info "Installing dependencies..."

    case $os in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y \
                git \
                curl \
                wget \
                build-essential \
                unzip \
                ripgrep \
                fd-find

            # Install Fish 4.2.1 from pre-built binary
            FISH_VERSION="4.2.1"
            if ! command -v fish &> /dev/null || [ "$(fish --version | grep -oP '[\d.]+' | head -1)" != "$FISH_VERSION" ]; then
                print_info "Installing Fish $FISH_VERSION..."
                cd /tmp
                wget https://github.com/fish-shell/fish-shell/releases/download/$FISH_VERSION/fish-$FISH_VERSION-linux-x86_64.tar.xz
                tar -xf fish-$FISH_VERSION-linux-x86_64.tar.xz
                sudo install -m755 fish /usr/local/bin/fish
                rm -f fish fish-$FISH_VERSION-linux-x86_64.tar.xz

                # Add fish to /etc/shells if not present
                if ! grep -q "/usr/local/bin/fish" /etc/shells; then
                    echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
                fi

                print_success "Fish $FISH_VERSION installed"
            else
                print_success "Fish $FISH_VERSION already installed"
            fi

            # Install neovim (latest stable)
            if ! command -v nvim &> /dev/null; then
                print_info "Installing Neovim..."
                wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
                sudo tar -xzf nvim-linux64.tar.gz -C /opt
                sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                rm nvim-linux64.tar.gz
            fi

            # Install yazi
            if ! command -v yazi &> /dev/null; then
                print_info "Installing Yazi..."
                cargo install --locked yazi-fm yazi-cli || {
                    print_info "Installing Rust first..."
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                    source "$HOME/.cargo/env"
                    cargo install --locked yazi-fm yazi-cli
                }
            fi
            ;;

        fedora|rhel|centos)
            sudo dnf install -y \
                git \
                curl \
                wget \
                gcc \
                make \
                unzip \
                ripgrep \
                fd-find \
                neovim

            # Install Fish 4.2.1 from pre-built binary
            FISH_VERSION="4.2.1"
            if ! command -v fish &> /dev/null || [ "$(fish --version | grep -oP '[\d.]+' | head -1)" != "$FISH_VERSION" ]; then
                print_info "Installing Fish $FISH_VERSION..."
                cd /tmp
                wget https://github.com/fish-shell/fish-shell/releases/download/$FISH_VERSION/fish-$FISH_VERSION-linux-x86_64.tar.xz
                tar -xf fish-$FISH_VERSION-linux-x86_64.tar.xz
                sudo install -m755 fish /usr/local/bin/fish
                rm -f fish fish-$FISH_VERSION-linux-x86_64.tar.xz

                # Add fish to /etc/shells if not present
                if ! grep -q "/usr/local/bin/fish" /etc/shells; then
                    echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
                fi

                print_success "Fish $FISH_VERSION installed"
            else
                print_success "Fish $FISH_VERSION already installed"
            fi

            # Install yazi
            if ! command -v yazi &> /dev/null; then
                print_info "Installing Yazi..."
                cargo install --locked yazi-fm yazi-cli || {
                    print_info "Installing Rust first..."
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                    source "$HOME/.cargo/env"
                    cargo install --locked yazi-fm yazi-cli
                }
            fi
            ;;

        arch|manjaro)
            sudo pacman -Syu --noconfirm \
                git \
                curl \
                wget \
                base-devel \
                unzip \
                ripgrep \
                fd \
                fish \
                neovim \
                yazi
            ;;

        macos)
            if ! command -v brew &> /dev/null; then
                print_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi

            brew install \
                git \
                curl \
                wget \
                ripgrep \
                fd \
                fish \
                neovim \
                yazi
            ;;

        *)
            print_error "Unsupported OS: $os"
            print_info "Please install the following manually:"
            print_info "  - git, curl, wget"
            print_info "  - neovim (>= 0.9.0)"
            print_info "  - fish shell (>= 4.2.1)"
            print_info "  - yazi file manager"
            print_info "  - ripgrep, fd"
            exit 1
            ;;
    esac

    print_success "Dependencies installed"
}

# Backup existing configs
backup_configs() {
    print_info "Backing up existing configurations..."

    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    [ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$backup_dir/"
    [ -d "$HOME/.config/fish" ] && cp -r "$HOME/.config/fish" "$backup_dir/"
    [ -d "$HOME/.config/yazi" ] && cp -r "$HOME/.config/yazi" "$backup_dir/"

    print_success "Backup created at $backup_dir"
}

# Setup Neovim
setup_neovim() {
    print_info "Setting up Neovim..."

    # Create symlink or copy config
    if [ -d "$HOME/.config/nvim" ]; then
        rm -rf "$HOME/.config/nvim"
    fi

    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

    print_success "Neovim configuration linked"
    print_info "Lazy.nvim will install plugins on first launch"
}

# Setup Fish shell
setup_fish() {
    print_info "Setting up Fish shell..."

    # Create symlink or copy config
    if [ -d "$HOME/.config/fish" ]; then
        rm -rf "$HOME/.config/fish"
    fi

    ln -sf "$DOTFILES_DIR/fish" "$HOME/.config/fish"

    # Install Fisher
    print_info "Installing Fisher plugin manager..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

    # Install Fish plugins from fish_plugins file
    if [ -f "$DOTFILES_DIR/fish/fish_plugins" ]; then
        print_info "Installing Fish plugins..."
        fish -c "fisher update"
    fi

    print_success "Fish shell configured"

    # Offer to change default shell
    if [ "$SHELL" != "$(which fish)" ]; then
        read -p "Do you want to set Fish as your default shell? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chsh -s "$(which fish)"
            print_success "Default shell changed to Fish"
        fi
    fi
}

# Setup Yazi
setup_yazi() {
    print_info "Setting up Yazi..."

    # Create symlink or copy config
    if [ -d "$HOME/.config/yazi" ]; then
        rm -rf "$HOME/.config/yazi"
    fi

    ln -sf "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"

    print_success "Yazi configuration linked"
}

# Initialize git repository if not already
init_git_repo() {
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        print_info "Initializing git repository..."
        cd "$DOTFILES_DIR"
        git init
        git add .
        git commit -m "Initial commit: dotfiles setup"
        print_success "Git repository initialized"
        print_info "To push to remote, run:"
        print_info "  cd $DOTFILES_DIR"
        print_info "  git remote add origin <your-repo-url>"
        print_info "  git push -u origin main"
    fi
}

# Main installation flow
main() {
    echo ""
    print_info "Starting installation..."
    echo ""

    # Ask for confirmation
    read -p "This will install dependencies and link dotfiles. Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi

    # Backup existing configs
    backup_configs

    # Install dependencies
    install_dependencies

    # Setup configurations
    setup_neovim
    setup_fish
    setup_yazi

    # Initialize git if needed
    init_git_repo

    echo ""
    echo "================================"
    print_success "Installation complete!"
    echo "================================"
    echo ""
    print_info "Next steps:"
    print_info "  1. Open Neovim - plugins will auto-install on first launch"
    print_info "  2. Restart your terminal or run: exec fish"
    print_info "  3. Fish plugins will be automatically installed"
    echo ""
}

# Run main function
main
