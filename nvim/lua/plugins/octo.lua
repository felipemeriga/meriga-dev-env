return {
  -- The LazyVim octo extra enables Projects v2 queries, which need the
  -- 'read:project' token scope our gh auth doesn't have (and we don't use
  -- GitHub Projects boards). Disable to silence the missing-scope error.
  -- If Projects support is ever wanted instead, run:
  --   gh auth refresh -h github.com -s read:project
  -- and delete this override.
  {
    "pwntester/octo.nvim",
    opts = {
      default_to_projects_v2 = false,
    },
  },
}
