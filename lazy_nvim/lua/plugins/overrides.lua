return {
  -- disable leap
  { "ggandor/leap.nvim", enabled = false },
  { "ggandor/flit.nvim", enabled = false },
  {
    "neovim/nvim-lspconfig",
    opts = { autoformat = false },
  },
}
