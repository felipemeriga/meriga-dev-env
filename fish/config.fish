if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Homebrew initialization (macOS only)
if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# PATH configuration - Order matters! Prepending to PATH so later entries take precedence

# Python versions (macOS framework paths)
if test -d /Library/Frameworks/Python.framework
    set -gx PATH /Library/Frameworks/Python.framework/Versions/3.13/bin $PATH
    set -gx PATH /Library/Frameworks/Python.framework/Versions/3.12/bin $PATH
    set -gx PATH /Library/Frameworks/Python.framework/Versions/3.11/bin $PATH
end

# Solana
set -gx PATH $HOME/.local/share/solana/install/active_release/bin $PATH

# pyenv
set -gx PATH $HOME/.pyenv/bin $PATH

# LLVM and Clang (macOS Homebrew)
if test -d /opt/homebrew/opt/llvm
    set -gx LLVM_HOME /opt/homebrew/opt/llvm
    set -gx PATH $LLVM_HOME/bin $PATH
    set -gx LIBCLANG_PATH $LLVM_HOME/lib
    if command -q xcrun
        set -gx BINDGEN_EXTRA_CLANG_ARGS "-I$LLVM_HOME/include -I"(xcrun --show-sdk-path)"/usr/include"
    end
end

# Bun
set -gx BUN_INSTALL $HOME/.bun
set -gx PATH $BUN_INSTALL/bin $PATH

# Other paths
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/go/bin $PATH
set -gx PATH $HOME/.foundry/bin $PATH
set -gx PATH /usr/local/go/bin $PATH

# Warp terminal (macOS only)
if test -d /Applications/Warp.app
    set -gx PATH /Applications/Warp.app/Contents/Resources/bin $PATH
end

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim

# PKG_CONFIG_PATH (Homebrew on macOS)
if test -d /opt/homebrew/lib/pkgconfig
    set -gx PKG_CONFIG_PATH /opt/homebrew/lib/pkgconfig $PKG_CONFIG_PATH
end

# CUDA
if test -d /usr/local/cuda
    set -gx CUDA_PATH /usr/local/cuda
    set -gx CUDA_HOME /usr/local/cuda
end

# NPM Token - Load from local file if exists (not committed to git)
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end

# fzf.fish
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse'

# Aliases
alias ll="ls -lah"
alias v="nvim"

# AWS SSO aliases
alias awsnonprod='eval (export-aws-keys -p cosm-nonprod)'
alias awsprod='eval (export-aws-keys -p production)'

# Yazi - allows to keep dir location when exiting with q, otherwise use Q
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Google Cloud SDK
if test -f "$HOME/Downloads/google-cloud-sdk/path.fish.inc"
    source "$HOME/Downloads/google-cloud-sdk/path.fish.inc"
end
