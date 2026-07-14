-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Call-hierarchy keymaps (gD = callers, gY = callees) live in
-- lua/plugins/lsp-keymaps.lua: LazyVim applies its own buffer-local LSP maps
-- on attach (gD = declaration), which would shadow globals defined here.

-- Close buffer with Cmd+W, for terminals that forward the Cmd key
-- (kitty/WezTerm/Ghostty natively; iTerm2 via a "Send Escape Sequence"
-- key binding). Snacks.bufdelete closes the buffer without collapsing the
-- window layout.
vim.keymap.set({ "n", "i" }, "<D-w>", function()
  Snacks.bufdelete()
end, { desc = "Close buffer" })

-- Cmd+C copy for forwarding terminals; with clipboard=unnamedplus + OSC 52
-- a plain `y` already copies to the Mac clipboard, this just adds the
-- familiar chord in visual mode.
vim.keymap.set("v", "<D-c>", "y", { desc = "Copy selection to clipboard" })

-- Fast 10-line jumps on Shift+arrows. Without these, S-Up/S-Down fall back to
-- Vim's default full-page scroll, which feels slow and imprecise. A single
-- keypress moving exactly 10 lines beats holding an arrow key (each repeat is
-- a full render round-trip, painful over SSH).
vim.keymap.set({ "n", "v" }, "<S-Down>", "10j", { desc = "Jump 10 lines down" })
vim.keymap.set({ "n", "v" }, "<S-Up>", "10k", { desc = "Jump 10 lines up" })
vim.keymap.set("i", "<S-Down>", "<C-o>10j", { desc = "Jump 10 lines down" })
vim.keymap.set("i", "<S-Up>", "<C-o>10k", { desc = "Jump 10 lines up" })
