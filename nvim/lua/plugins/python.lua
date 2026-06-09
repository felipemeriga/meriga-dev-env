-- Python support.
--
-- The LSP (basedpyright), linter+formatter (ruff), Treesitter parsers and Mason
-- install all come from the LazyVim extra enabled in lazyvim.json:
--   "lazyvim.plugins.extras.lang.python"
--
-- The choice of basedpyright vs pyright is set in config/options.lua via
-- `vim.g.lazyvim_python_lsp` (must be set before the extra loads).
--
-- This file only enriches that setup:
--  * fuller basedpyright inlay hints (variable/call/return types), and
--  * a buffer-local run keymap for Python files.
--
-- Format-on-save is provided by conform.nvim using ruff (LazyVim default).
-- Prereq: `python3` must be on PATH so Mason can install debugpy/ruff.

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    vim.keymap.set("n", "<leader>pr", function()
      vim.cmd("split | terminal python3 " .. vim.fn.shellescape(vim.fn.expand("%")))
    end, { buffer = ev.buf, silent = true, desc = "Python Run File" })
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                inlayHints = {
                  variableTypes = true,
                  callArgumentNames = true,
                  functionReturnTypes = true,
                  genericTypes = false,
                },
              },
            },
          },
        },
      },
    },
  },

  -- The lang.python extra registers nvim-dap-python and neotest-python as
  -- optional plugins. They auto-activate because rust.lua already loads
  -- nvim-dap and neotest. Scope is LSP + format only, so turn them off here.
  -- venv-selector.nvim is kept — basedpyright uses the active venv for
  -- accurate type checking, so the selector is worth its weight even without DAP.
  { "mfussenegger/nvim-dap-python", enabled = false },
  { "nvim-neotest/neotest-python", enabled = false },
}
