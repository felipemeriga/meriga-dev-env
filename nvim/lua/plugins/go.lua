-- Go support.
--
-- The LSP (gopls), formatters (gofumpt, goimports), linter (golangci-lint),
-- Treesitter parsers and Mason install all come from the LazyVim extra enabled
-- in lazyvim.json:
--   "lazyvim.plugins.extras.lang.go"
--
-- This file only enriches that setup:
--  * fuller gopls inlay hints (parameter names, types, constants, etc.), and
--  * buffer-local compile/run/test keymaps in Go files (mirrors rust.lua).
--
-- Format-on-save is provided by conform.nvim (LazyVim default).
-- Prereq: `go` must be on PATH so Mason can `go install` gopls and friends.

-- Buffer-local keymaps for Go files. Scoped to the buffer so global <leader>g*
-- (LazyVim's git group) only gets shadowed inside Go files — same pattern the
-- Rust setup uses with <leader>r*.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    vim.keymap.set("n", "<leader>gb", function()
      vim.cmd("split | terminal go build ./...")
    end, vim.tbl_extend("force", opts, { desc = "Go Build" }))

    vim.keymap.set("n", "<leader>gr", function()
      vim.cmd("split | terminal go run " .. vim.fn.shellescape(vim.fn.expand("%")))
    end, vim.tbl_extend("force", opts, { desc = "Go Run File" }))

    vim.keymap.set("n", "<leader>gt", function()
      vim.cmd("split | terminal go test ./...")
    end, vim.tbl_extend("force", opts, { desc = "Go Test" }))
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
      },
    },
  },

  -- The lang.go extra registers nvim-dap-go and neotest-golang as optional
  -- plugins. They auto-activate because rust.lua already loads nvim-dap and
  -- neotest. Scope is LSP + format only, so turn them off here.
  { "leoluz/nvim-dap-go", enabled = false },
  { "nvim-neotest/neotest-go", enabled = false },
  { "fredrikaverpil/neotest-golang", enabled = false },
}
