return {
  -- Treesitter para Rust e TOML
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "rust", "toml" })
      end
    end,
  },

  -- crates.nvim para Cargo.toml
  {
    "Saecki/crates.nvim",
    ft = { "toml" },
    config = function()
      require("crates").setup({
        completion = { crates = { enabled = true } },
        lsp = { enabled = true, hover = true, actions = true },
      })
    end,
  },

  -- DAP (Debug Adapter Protocol)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text", -- Show variable values inline
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP Virtual Text (show variable values inline)
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = "<module",
        virt_text_pos = "eol", -- position: 'eol' | 'overlay' | 'right_align'
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      })

      -- Setup DAP UI
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- DAP keymaps (adapter configuration is handled by RustaceanVim)
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
      vim.keymap.set("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Hover Variables" })
      vim.keymap.set("v", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Hover Variables" })
      vim.keymap.set("n", "<leader>dp", function() require("dap.ui.widgets").preview() end, { desc = "Preview Variables" })
      vim.keymap.set("n", "<leader>de", function()
        vim.ui.input({ prompt = "Expression: " }, function(expr)
          if expr then
            dapui.eval(expr)
          end
        end)
      end, { desc = "Evaluate Expression" })
      vim.keymap.set("v", "<leader>de", function()
        dapui.eval()
      end, { desc = "Evaluate Selection" })
    end,
  },

  -- RustaceanVim + blink.cmp
  {
    "mrcjkb/rustaceanvim",
    ft = "rust",
    version = "^4",

    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.g.rustaceanvim = {
        tools = {
          test_executor = "neotest", -- Use neotest for running tests
        },
        server = {
          on_attach = function(client, bufnr)
            client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, capabilities)

            -- keymaps básicos de LSP
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

            -- Rust-specific keymaps
            vim.keymap.set("n", "<leader>rr", function()
              vim.cmd("split | terminal cargo run")
            end, { buffer = bufnr, desc = "Cargo Run" })

            vim.keymap.set("n", "<leader>rt", function()
              vim.cmd("split | terminal cargo test")
            end, { buffer = bufnr, desc = "Cargo Test" })

            vim.keymap.set("n", "<leader>rb", function()
              vim.cmd("split | terminal cargo build")
            end, { buffer = bufnr, desc = "Cargo Build" })

            vim.keymap.set("n", "<leader>rc", function()
              vim.cmd("split | terminal cargo check")
            end, { buffer = bufnr, desc = "Cargo Check" })

            -- RustaceanVim commands
            vim.keymap.set("n", "<leader>rd", "<cmd>RustLsp debuggables<cr>", { buffer = bufnr, desc = "Rust Debuggables" })
            vim.keymap.set("n", "<leader>re", "<cmd>RustLsp runnables<cr>", { buffer = bufnr, desc = "Rust Runnables" })
          end,

          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              procMacro = { enable = true },
              completion = { postfix = { enable = true } },
            },
          },
        },
        dap = {
          -- RustaceanVim will auto-detect codelldb from Mason or PATH
          adapter = require("rustaceanvim.config").get_codelldb_adapter(
            vim.fn.stdpath("data") .. "/mason/bin/codelldb",
            vim.fn.exepath("lldb-dap") or vim.fn.exepath("lldb-vscode")
          ),
        },
      }
    end,
  },

  -- Neotest for modern test running UI
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          -- RustaceanVim provides its own neotest adapter
          require("rustaceanvim.neotest"),
        },
        -- Neotest configuration
        floating = {
          border = "rounded",
          max_height = 0.8,
          max_width = 0.9,
        },
        summary = {
          open = "botright vsplit | vertical resize 50",
        },
      })

      -- Keymaps for neotest
      vim.keymap.set("n", "<leader>tr", function()
        require("neotest").run.run()
      end, { desc = "Run nearest test" })

      vim.keymap.set("n", "<leader>tf", function()
        require("neotest").run.run(vim.fn.expand("%"))
      end, { desc = "Run current file tests" })

      vim.keymap.set("n", "<leader>td", function()
        require("neotest").run.run({ strategy = "dap" })
      end, { desc = "Debug nearest test" })

      vim.keymap.set("n", "<leader>ts", function()
        require("neotest").summary.toggle()
      end, { desc = "Toggle test summary" })

      vim.keymap.set("n", "<leader>to", function()
        require("neotest").output.open({ enter = true })
      end, { desc = "Show test output" })

      vim.keymap.set("n", "<leader>tO", function()
        require("neotest").output_panel.toggle()
      end, { desc = "Toggle test output panel" })

      vim.keymap.set("n", "<leader>tS", function()
        require("neotest").run.stop()
      end, { desc = "Stop test" })
    end,
  },
}
