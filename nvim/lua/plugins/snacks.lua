return {
  -- LazyVim enables snacks.nvim's smooth-scroll animation by default. Every
  -- scroll (page jumps, S-Up/S-Down, big cursor moves) gets animated over
  -- ~250ms and repeated presses queue up, which reads as laggy movement —
  -- especially over SSH/tmux where frames render with network latency.
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },
}
