local wk = require("which-key")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

local builtin = require('telescope.builtin')
wk.add({
  { "<leader>f", group = "Find" },
  { "<leader>fb", builtin.buffers, desc = "Buffers" },
  { "<leader>ff", builtin.find_files, desc = "Find files" },
  { "<leader>fg", builtin.git_files, desc = "Find git files" },
  { "<leader>fh", builtin.help_tags, desc = "Help tags" },
  { "<leader>fr", builtin.live_grep, desc = "Live grep" },
})
