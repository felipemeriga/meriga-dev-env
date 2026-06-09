-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Sync Neovim's yank/delete with the system clipboard.
vim.opt.clipboard = "unnamedplus"

-- LazyVim's Python extra supports basedpyright (community fork: faster, no
-- telemetry) or pyright. Must be set before the extra loads — options.lua
-- runs pre-lazy, so this is the right place.
vim.g.lazyvim_python_lsp = "basedpyright"

-- Over SSH (or any session without a local display) there is no X/Wayland
-- clipboard to talk to, so fall back to OSC 52: the terminal forwards the
-- copied text to the clipboard of the machine running the terminal.
local has_display = vim.env.DISPLAY ~= nil or vim.env.WAYLAND_DISPLAY ~= nil
local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

if in_ssh or not has_display then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    -- Paste from a terminal over OSC 52 is unreliable (many terminals refuse
    -- to answer the read for security reasons and the request hangs), so paste
    -- from Neovim's own unnamed register instead.
    paste = {
      ["+"] = function()
        return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
      end,
      ["*"] = function()
        return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
      end,
    },
  }
end
