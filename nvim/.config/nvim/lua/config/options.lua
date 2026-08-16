local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"

opt.termguicolors = true
opt.laststatus = 3
opt.showmode = false
opt.pumheight = 10
opt.winborder = "rounded"

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.wrap = false

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.scrolloff = 6
opt.sidescrolloff = 8

opt.mouse = "a"
opt.undofile = true
opt.swapfile = false
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.completeopt = { "menu", "menuone", "noselect" }

opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldclose = "",
}

-- Use the system clipboard when a provider is available, without making it a
-- hard dependency on headless machines.
vim.schedule(function()
  if
    vim.fn.executable("wl-copy") == 1
    or vim.fn.executable("xclip") == 1
    or vim.fn.has("mac") == 1
  then
    opt.clipboard:append("unnamedplus")
  end
end)
