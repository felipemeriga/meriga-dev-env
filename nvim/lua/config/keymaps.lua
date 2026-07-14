-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Fast 10-line jumps on Shift+arrows. Without these, S-Up/S-Down fall back to
-- Vim's default full-page scroll, which feels slow and imprecise. A single
-- keypress moving exactly 10 lines beats holding an arrow key (each repeat is
-- a full render round-trip, painful over SSH).
vim.keymap.set({ "n", "v" }, "<S-Down>", "10j", { desc = "Jump 10 lines down" })
vim.keymap.set({ "n", "v" }, "<S-Up>", "10k", { desc = "Jump 10 lines up" })
vim.keymap.set("i", "<S-Down>", "<C-o>10j", { desc = "Jump 10 lines down" })
vim.keymap.set("i", "<S-Up>", "<C-o>10k", { desc = "Jump 10 lines up" })
