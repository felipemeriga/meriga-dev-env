return {
  -- Call hierarchy: the reverse of gd. gD lists every caller of the function
  -- under the cursor (replacing LazyVim's default gD = "go to declaration",
  -- which rust-analyzer/gopls/basedpyright treat the same as definition).
  -- gY lists everything the function calls (Y since gO is taken by nvim's
  -- built-in document outline). Shown in the snacks picker dialog (same UI
  -- as <leader>sB): type to filter, <cr> jumps to the call site.
  --
  -- Defined through LazyVim's LSP server keys instead of vim.keymap.set:
  -- LazyVim applies buffer-local maps on LspAttach (including its own gD),
  -- and buffer-local always shadows global maps. The `has` field skips the
  -- map for servers without call-hierarchy support.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            {
              "gD",
              function()
                Snacks.picker.lsp_incoming_calls()
              end,
              desc = "Callers of function (incoming calls)",
              has = "callHierarchy/incomingCalls",
            },
            {
              "gY",
              function()
                Snacks.picker.lsp_outgoing_calls()
              end,
              desc = "Calls made by function (outgoing calls)",
              has = "callHierarchy/outgoingCalls",
            },
          },
        },
      },
    },
  },
}
