-- TypeScript / JavaScript support.
--
-- The LSP (vtsls), Mason install, Treesitter parsers and base inlay hints come from
-- the LazyVim extra enabled in lazyvim.json:
--   "lazyvim.plugins.extras.lang.typescript"
--
-- This file only enriches that setup:
--  * fuller inlay hints (variable/parameter types and names), and
--  * mirrors the settings under `javascript.*` so .js/.jsx files get the same hints
--    (the extra only configures `typescript.*`).
-- Inlay-hint *display* is enabled by default in LazyVim; toggle per buffer with <leader>uh.

local inlay_hints = {
  enumMemberValues = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
  parameterTypes = { enabled = true },
  propertyDeclarationTypes = { enabled = true },
  variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              inlayHints = inlay_hints,
            },
            javascript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = { completeFunctionCalls = true },
              inlayHints = inlay_hints,
            },
          },
        },
      },
    },
  },
}
