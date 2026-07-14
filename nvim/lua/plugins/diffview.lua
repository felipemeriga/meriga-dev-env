-- Side-by-side diffs with a changed-files panel.
--
--   <leader>gv  review the current branch against origin's default branch
--               (what a PR for this branch would contain)
--   <leader>gV  close the diff view
--   <leader>gF  history of the current file (each commit's diff side by side)
--               (capital F: <leader>gf is LazyVim's lazygit file history)
--
-- Inside the view: the left panel lists changed files (j/k + <cr> to open,
-- <tab> for next file); each file opens as old-vs-new side by side.
-- Also available: :DiffviewOpen (uncommitted changes), :DiffviewOpen main
-- (against a specific rev). Octo's review mode (<localleader>v in a PR
-- buffer) provides its own side-by-side diff for commenting on PRs.
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    opts = {},
    keys = {
      {
        "<leader>gv",
        function()
          -- Diff against the remote default branch (origin/HEAD), i.e. the
          -- PR view of the current branch. Falls back to working-tree diff
          -- when origin/HEAD isn't set (e.g. repos without a remote).
          local ok = vim.fn.system("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
          if vim.v.shell_error == 0 and ok ~= "" then
            vim.cmd("DiffviewOpen origin/HEAD...HEAD --imply-local")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Diff branch vs origin (Diffview)",
      },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (Diffview)" },
    },
  },
}
