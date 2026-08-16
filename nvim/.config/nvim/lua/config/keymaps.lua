local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", "<Cmd>write<CR>", { desc = "Save file" })
map("n", "<Esc>", "<Cmd>nohlsearch<CR>")
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })
map("n", "<leader>Q", "<Cmd>qa<CR>", { desc = "Quit all" })

map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Grow window" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Shrink window" })
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Shrink window horizontally" })
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Grow window horizontally" })

map("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })
