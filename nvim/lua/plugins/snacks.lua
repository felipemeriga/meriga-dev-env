return {
  -- LazyVim enables snacks.nvim's smooth-scroll animation by default. Every
  -- scroll (page jumps, S-Up/S-Down, big cursor moves) gets animated over
  -- ~250ms and repeated presses queue up, which reads as laggy movement —
  -- especially over SSH/tmux where frames render with network latency.
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      picker = {
        sources = {
          -- Show dotfiles in the explorer side panel (<leader>e) by default.
          -- `H` toggles hidden files at runtime, `I` toggles git-ignored ones.
          explorer = { hidden = true },
          -- Also find dotfiles with the file picker (<leader>ff / <leader><space>).
          files = { hidden = true },
        },
      },
    },
  },
}
