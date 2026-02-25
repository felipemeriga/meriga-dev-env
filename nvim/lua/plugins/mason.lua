return {
  -- Mason for managing LSP servers, DAP adapters, linters, and formatters
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- DAP
        "codelldb", -- Rust debugger

        -- Formatters and linters
        "stylua", -- Lua formatter
        "shfmt", -- Shell script formatter
      },
    },
  },
}
