vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.fn.has("nvim-0.12") == 0 then
  error("This configuration requires Neovim 0.12 or newer")
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
