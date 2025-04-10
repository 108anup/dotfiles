return {
  "lervag/vimtex",
  lazy = false,     -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    if vim.loop.os_uname().sysname == "Darwin" then
      vim.g.vimtex_view_method = "skim"
    else
      vim.g.vimtex_view_method = "zathura"
    end
    vim.g.vimtex_syntax_conceal_disable = 1
    vim.g.vimtex_compiler_latexmk = {
      out_dir = "./outputs/vimtex/"
    }
  end
}
