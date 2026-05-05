return {
  -- Treesitter for Go
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork", "gosum" })
      end
    end,
  },

  -- Go LSP via nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.venv", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
    },
  },

  -- Go-specific keymaps
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function(event)
          local opts = { buffer = event.buf, silent = true }

          vim.keymap.set("n", "<leader>gt", function()
            vim.cmd("split | terminal go test ./...")
          end, vim.tbl_extend("force", opts, { desc = "Go Test" }))

          vim.keymap.set("n", "<leader>gr", function()
            vim.cmd("split | terminal go run .")
          end, vim.tbl_extend("force", opts, { desc = "Go Run" }))

          vim.keymap.set("n", "<leader>gb", function()
            vim.cmd("split | terminal go build ./...")
          end, vim.tbl_extend("force", opts, { desc = "Go Build" }))

          vim.keymap.set("n", "<leader>gl", function()
            vim.cmd("split | terminal golangci-lint run ./...")
          end, vim.tbl_extend("force", opts, { desc = "Go Lint" }))
        end,
      })
    end,
  },

  -- Formatting with conform.nvim
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },

  -- DAP configuration for Go (Delve)
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },

  -- Neotest adapter for Go
  {
    "nvim-neotest/neotest",
    dependencies = {
      "fredrikaverpil/neotest-golang",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-golang"))
    end,
  },
}
