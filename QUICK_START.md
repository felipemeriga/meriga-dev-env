# Quick Start Guide

## Installation on a New Machine

```bash
# 1. Clone the repository
git clone <your-repo-url> ~/dotfiles

# 2. Run the installation script
cd ~/dotfiles
./install.sh

# 3. Restart your terminal or run
exec fish
```

That's it! Everything will be set up automatically.

## What Gets Installed

### System Dependencies
- Neovim (latest stable)
- Fish shell
- Yazi file manager
- ripgrep, fd
- Git, curl, wget

### Fish Plugins (via Fisher)
- fzf.fish - Fuzzy finder
- z - Directory jumping
- done - Process notifications
- sponge - Clean history
- nvm.fish - Node version manager
- docker-fish-completion
- zoxide - Smart cd
- tide - Modern prompt

### Neovim Plugins (via LazyVim)
Auto-installed on first launch

## Post-Installation

The installation script automatically:
- Changes your default shell to Fish (`/usr/local/bin/fish`)
- You'll need to **log out and log back in** for the shell change to take effect

### Optional Configuration

1. **Configure Tide prompt** (first time only):
   ```fish
   tide configure
   ```

2. **Open Neovim** to install plugins:
   ```bash
   nvim
   # Wait for plugins to install
   ```

### Manual Shell Change (if needed)

If the automatic shell change didn't work:
```bash
chsh -s /usr/local/bin/fish $USER
```
Then log out and log back in.

## Updating Your Dotfiles

### After Making Local Changes

```bash
cd ~/dotfiles
git add .
git commit -m "Update configurations"
git push
```

### Pulling Updates on Another Machine

```bash
cd ~/dotfiles
git pull
# Restart terminal or: exec fish
```

## Pushing to GitHub

```bash
# Create a new repository on GitHub first, then:
cd ~/dotfiles
git remote add origin https://github.com/yourusername/dotfiles.git
git branch -M main
git push -u origin main
```

## Customizing

### Add a Fish Plugin

```bash
fisher install owner/plugin-name
# The fish_plugins file is automatically updated
```

### Add a Neovim Plugin

Edit `~/dotfiles/nvim/lua/plugins/your-plugin.lua`:

```lua
return {
  "owner/plugin-name",
  config = function()
    -- configuration here
  end,
}
```

## Troubleshooting

### Neovim issues
```vim
:Lazy sync
:checkhealth
```

### Fish issues
```fish
fisher update
fisher list
```

### Reset everything
```bash
cd ~/dotfiles
./install.sh
# This will backup existing configs and re-link everything
```
