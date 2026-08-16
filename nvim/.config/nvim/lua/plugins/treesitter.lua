return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "bash",
        "c",
        "cpp",
        "css",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }

      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "c",
          "cpp",
          "css",
          "dockerfile",
          "gitcommit",
          "gitconfig",
          "gitrebase",
          "go",
          "gomod",
          "gosum",
          "html",
          "javascript",
          "javascriptreact",
          "json",
          "lua",
          "markdown",
          "python",
          "query",
          "rust",
          "sh",
          "toml",
          "typescript",
          "typescriptreact",
          "vim",
          "yaml",
        },
        desc = "Enable Tree-sitter highlighting and indentation",
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
