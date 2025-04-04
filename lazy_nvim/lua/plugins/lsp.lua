return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        clangd = function(_, opts)
          opts.capabilities.offsetEncoding = { "utf-16" }
        end,
      },
      inlay_hints = { enabled = false },
      -- servers = {
      --   pylsp = {
      --     settings = {
      --       pylsp = {
      --         plugins = {
      --           rope_autoimport = {
      --             enabled = true,
      --           },
      --           pycodestyle = {
      --             maxLineLength = 88
      --           },
      --         },
      --       },
      --     },
      --   },
      -- },
    },
  },
}
