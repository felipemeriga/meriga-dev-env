return {
  -- Mason for managing LSP servers, DAP adapters, linters, and formatters
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- DAP
        "codelldb", -- Rust debugger

        -- Go tools
        "gopls", -- Go language server
        "delve", -- Go debugger
        "goimports", -- Go imports organizer
        "gofumpt", -- Strict Go formatter
        "golangci-lint", -- Go linter

        -- Formatters and linters
        "stylua", -- Lua formatter
        "shfmt", -- Shell script formatter
      },
    },
  },
}
