#!/usr/bin/env bash

set -e

echo "================================"
echo "Testing Dotfiles Installation"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test 1: Check if all required files exist
print_test "Checking if all required files exist..."
errors=0

[ -f "$DOTFILES_DIR/install.sh" ] && print_success "install.sh exists" || { print_error "install.sh missing"; ((errors++)); }
[ -d "$DOTFILES_DIR/nvim" ] && print_success "nvim directory exists" || { print_error "nvim directory missing"; ((errors++)); }
[ -d "$DOTFILES_DIR/fish" ] && print_success "fish directory exists" || { print_error "fish directory missing"; ((errors++)); }
[ -d "$DOTFILES_DIR/yazi" ] && print_success "yazi directory exists" || { print_error "yazi directory missing"; ((errors++)); }
[ -f "$DOTFILES_DIR/fish/fish_plugins" ] && print_success "fish_plugins file exists" || { print_error "fish_plugins missing"; ((errors++)); }
[ -f "$DOTFILES_DIR/nvim/init.lua" ] && print_success "nvim init.lua exists" || { print_error "nvim init.lua missing"; ((errors++)); }

echo ""

# Test 2: Check current system state
print_test "Checking current system state..."

if command -v nvim &> /dev/null; then
    nvim_version=$(nvim --version | head -1)
    print_success "Neovim installed: $nvim_version"
else
    print_error "Neovim not installed"
    ((errors++))
fi

if command -v fish &> /dev/null; then
    fish_version=$(fish --version)
    print_success "Fish installed: $fish_version"
    if [[ "$fish_version" == *"4.2.1"* ]]; then
        print_success "Fish version is 4.2.1 ✓"
    else
        print_error "Fish version is not 4.2.1"
    fi
else
    print_error "Fish not installed"
    ((errors++))
fi

if command -v yazi &> /dev/null; then
    yazi_version=$(yazi --version | head -1)
    print_success "Yazi installed: $yazi_version"
else
    print_error "Yazi not installed"
    ((errors++))
fi

echo ""

# Test 3: Check if configs are symlinked
print_test "Checking configuration symlinks..."

check_symlink() {
    local target=$1
    local source=$2

    if [ -L "$target" ]; then
        local link_target=$(readlink -f "$target")
        local expected_target=$(readlink -f "$source")
        if [ "$link_target" = "$expected_target" ]; then
            print_success "$target is correctly symlinked to $source"
            return 0
        else
            print_error "$target is symlinked but to wrong location: $link_target"
            return 1
        fi
    elif [ -e "$target" ]; then
        print_info "$target exists but is not a symlink (regular directory/file)"
        return 2
    else
        print_info "$target does not exist"
        return 3
    fi
}

check_symlink "$HOME/.config/nvim" "$DOTFILES_DIR/nvim"
nvim_status=$?

check_symlink "$HOME/.config/fish" "$DOTFILES_DIR/fish"
fish_status=$?

check_symlink "$HOME/.config/yazi" "$DOTFILES_DIR/yazi"
yazi_status=$?

echo ""

# Test 4: Check Fish plugins
print_test "Checking Fish plugins..."

if command -v fish &> /dev/null; then
    if fish -c "type -q fisher" 2>/dev/null; then
        print_success "Fisher is installed"

        print_info "Installed Fisher plugins:"
        fish -c "fisher list" 2>/dev/null | while read plugin; do
            echo "  - $plugin"
        done
    else
        print_error "Fisher is not installed"
        ((errors++))
    fi
else
    print_error "Cannot check Fish plugins - Fish not installed"
fi

echo ""

# Test 5: Git repository status
print_test "Checking git repository..."

if [ -d "$DOTFILES_DIR/.git" ]; then
    print_success "Git repository initialized"

    cd "$DOTFILES_DIR"
    echo ""
    print_info "Recent commits:"
    git log --oneline -3
    echo ""

    if git remote | grep -q "origin"; then
        remote_url=$(git remote get-url origin)
        print_success "Remote 'origin' configured: $remote_url"
    else
        print_info "No remote 'origin' configured yet"
    fi
else
    print_error "Not a git repository"
    ((errors++))
fi

echo ""
echo "================================"

if [ $errors -eq 0 ]; then
    print_success "All tests passed!"
    echo ""

    if [ $nvim_status -eq 2 ] || [ $fish_status -eq 2 ] || [ $yazi_status -eq 2 ]; then
        print_info "Your configs are not symlinked yet. Run ./install.sh to set up symlinks."
    else
        print_success "Your dotfiles are properly configured!"
    fi
else
    print_error "Tests completed with $errors error(s)"
    exit 1
fi

echo "================================"
