return {
  -- Full error text on the line you're on: when the cursor sits on a line
  -- with a diagnostic, the complete message expands as wrapped virtual lines
  -- right below it (great for rust-analyzer's long type errors) and
  -- collapses when the cursor leaves. Other lines keep LazyVim's compact
  -- trailing virtual text, but it's hidden on the current line so the two
  -- don't show the same error twice.
  -- <leader>cd still opens the diagnostic in a float if ever needed.
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = { current_line = false },
        virtual_lines = { current_line = true },
      },
    },
  },
}
