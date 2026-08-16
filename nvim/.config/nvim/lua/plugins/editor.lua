return {
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<Cmd>Oil<CR>", desc = "Open parent directory" },
      { "<leader>e", "<Cmd>Oil<CR>", desc = "File explorer" },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon", "permissions", "size" },
      view_options = { show_hidden = true },
      float = { border = "rounded", padding = 4 },
      keymaps = { ["<C-p>"] = "actions.preview" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    keys = {
      { "<leader><space>", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Find text" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Find buffers" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Find help" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>gc", "<Cmd>Telescope git_commits<CR>", desc = "Git commits" },
      { "<leader>gs", "<Cmd>Telescope git_status<CR>", desc = "Git status" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        path_display = { "smart" },
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
      pickers = {
        find_files = { hidden = true },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next git hunk")
        map("n", "[h", gs.prev_hunk, "Previous git hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview git hunk")
        map("n", "<leader>gb", gs.blame_line, "Git blame line")
      end,
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo",
      },
      { "<leader>ft", "<Cmd>TodoTelescope<CR>", desc = "Find todos" },
    },
    opts = {},
  },
}
