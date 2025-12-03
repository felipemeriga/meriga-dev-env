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
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

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

      -- Rust debugger configuration (using codelldb)
      local codelldb_path = vim.fn.exepath("codelldb")
      if codelldb_path == "" then
        -- Fallback to Mason installation path
        codelldb_path = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
      end

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
        },
        {
          name = "Launch (no stop on entry)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- Keymaps for debugging
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

      -- Get codelldb path with fallback to Mason installation
      local codelldb_path = vim.fn.exepath("codelldb")
      if codelldb_path == "" then
        codelldb_path = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
      end

      -- Get liblldb path
      local liblldb_path = vim.fn.exepath("lldb-dap") or vim.fn.exepath("lldb-vscode")

      vim.g.rustaceanvim = {
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
          adapter = require("rustaceanvim.config").get_codelldb_adapter(
            codelldb_path,
            liblldb_path
          ),
        },
      }
    end,
  },
}
