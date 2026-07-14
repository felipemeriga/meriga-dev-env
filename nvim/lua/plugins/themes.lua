-- Extra colorschemes to explore. All lazy-loaded: they cost nothing until
-- selected, so it's fine to keep several installed.
--
-- Try them live with <leader>uC (colorscheme picker with preview as you
-- move through the list). To make one permanent, change `colorscheme` in
-- lua/plugins/catppuccin.lua's LazyVim opts.
return {
  -- Warm, muted, inspired by classic Japanese painting. Great rust contrast.
  { "rebelot/kanagawa.nvim", lazy = true },

  -- Soho vibes; soft low-contrast look. Variants: rose-pine, -moon, -dawn.
  { "rose-pine/neovim", name = "rose-pine", lazy = true },

  -- The retro classic, warm and high-contrast.
  { "ellisonleao/gruvbox.nvim", lazy = true },

  -- One repo, many styles: nightfox, carbonfox, duskfox, nordfox, terafox.
  { "EdenEast/nightfox.nvim", lazy = true },

  -- Green-based, easy on the eyes for long sessions.
  { "sainnhe/everforest", lazy = true },
}
