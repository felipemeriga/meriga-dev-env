# Dotfiles

My personal development environment configuration for Neovim, Fish shell, and Yazi file manager.

## What's Included

- **Neovim**: LazyVim configuration with custom plugins and settings
- **Fish Shell**: Shell configuration with Fisher plugin manager
- **Yazi**: Fast terminal file manager configuration

## Prerequisites

The installation script will handle most dependencies, but you'll need:

- Git
- Curl/Wget
- A Unix-like operating system (Linux or macOS)

## Quick Start

### Fresh Installation

```bash
# Clone this repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Run the installation script
cd ~/dotfiles
./install.sh
```

The script will:
1. Detect your operating system
2. Install required dependencies (Neovim, Fish 4.2.1, Yazi, etc.)
3. Backup your existing configurations
4. Create symlinks to dotfiles
5. Install Fish plugins via Fisher
6. Change your default shell to Fish (requires password)
7. Set up everything automatically

### Manual Installation

If you prefer to install manually:

```bash
# Link configurations
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/fish ~/.config/fish
ln -sf ~/dotfiles/yazi ~/.config/yazi

# Install Fisher for Fish
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install Fish plugins
fish -c "fisher update"

# Change default shell to Fish
chsh -s /usr/local/bin/fish $USER
```

**Note:** After changing the shell, log out and log back in for the change to take effect.

## Neovim Setup

This configuration uses [LazyVim](https://www.lazyvim.org/) as a base.

### Plugins

Plugins are automatically installed on first launch via Lazy.nvim. The configuration includes:

- Custom colorscheme (Catppuccin)
- **Rust development tools:**
  - RustaceanVim - LSP, DAP integration, runnables
  - codelldb (via Mason) - Rust debugger
  - crates.nvim - Cargo.toml dependency management
  - nvim-dap + nvim-dap-ui - Debug adapter protocol
  - nvim-dap-virtual-text - Inline variable values during debugging
  - neotest - Modern test runner UI
- Snippet support
- And more in `nvim/lua/plugins/`

### Customization

- `nvim/lua/config/` - Core configuration files
  - `options.lua` - Neovim options
  - `keymaps.lua` - Key mappings
  - `autocmds.lua` - Auto commands
- `nvim/lua/plugins/` - Plugin configurations

## Fish Shell Setup

### Plugins Managed by Fisher

The following plugins are automatically installed:

- `jorgebucaran/fisher` - Plugin manager
- `patrickf1/fzf.fish` - Fuzzy finder integration
- `jethrokuan/z` - Directory jumping
- `franciscolourenco/done` - Notification when long processes finish
- `meaningful-ooo/sponge` - Clean failed commands from history
- `jorgebucaran/nvm.fish` - Node version manager
- `barnybug/docker-fish-completion` - Docker completions
- `ajeetdsouza/zoxide` - Smarter cd command
- `ilancosman/tide` - Modern prompt theme

### Adding More Plugins

To add a new Fish plugin:

```bash
fisher install owner/repo
```

The plugin will be automatically added to `fish/fish_plugins`.

## Fish Shell Configuration

### Environment Variables
The Fish shell is configured with:
- `EDITOR=nvim` - Neovim as default text editor
- `VISUAL=nvim` - Neovim as visual editor
- `FZF_DEFAULT_OPTS` - FZF configuration

### Secrets and Tokens
For security, personal tokens and API keys should be stored in `fish/local.fish` (not committed to git):

```bash
# Copy the example file
cp fish/local.fish.example fish/local.fish

# Edit and add your tokens
nvim fish/local.fish
```

This file is automatically sourced by `config.fish` if it exists.

### Aliases
- `ll` - `ls -lah` (detailed list)
- `v` - `nvim` (quick access to Neovim)

## Yazi Configuration

Yazi is configured with:
- Hidden files shown by default
- Neovim as the default text editor

## File Structure

```
dotfiles/
├── install.sh          # Main installation script
├── README.md           # This file
├── nvim/               # Neovim configuration
│   ├── init.lua
│   ├── lua/
│   │   ├── config/     # LazyVim config
│   │   └── plugins/    # Custom plugins
│   └── lazy-lock.json  # Plugin lock file
├── fish/               # Fish shell configuration
│   ├── config.fish     # Main config
│   ├── fish_plugins    # Fisher plugins list
│   ├── functions/      # Custom functions
│   └── conf.d/         # Additional configs
└── yazi/               # Yazi configuration
    └── yazi.toml       # Main config file
```

## Updating

### Update Neovim Plugins

```bash
nvim
# Inside Neovim, run:
:Lazy update
```

### Update Fish Plugins

```bash
fisher update
```

### Update Dotfiles

```bash
cd ~/dotfiles
git pull
```

## Customization

Feel free to customize any configuration files. The main files to edit:

- **Neovim**: `nvim/lua/config/*.lua` and `nvim/lua/plugins/*.lua`
- **Fish**: `fish/config.fish` and add functions in `fish/functions/`
- **Yazi**: `yazi/yazi.toml`

## Backup

The installation script automatically creates a backup of your existing configurations in:
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

## Uninstallation

To remove the dotfiles:

```bash
# Remove symlinks
rm ~/.config/nvim ~/.config/fish ~/.config/yazi

# Restore from backup if needed
cp -r ~/.dotfiles_backup_*/* ~/.config/
```

## Troubleshooting

### Neovim plugins not installing

Run `:Lazy sync` inside Neovim to manually sync plugins.

### Fish plugins not working

Try reinstalling Fisher:
```bash
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher update
```

### Permission issues

Make sure the install script is executable:
```bash
chmod +x ~/dotfiles/install.sh
```

## Contributing

This is a personal configuration, but feel free to fork and adapt it for your own use!

## License

MIT License - Feel free to use and modify as you wish.
