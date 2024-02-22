local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitignore",
    "gitcommit",
    "graphql",
    "javascript",
    "json",
    "typescript",
    "terraform",
    "tsx",
    "c",
    "c_sharp",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",
    "json-lsp",
    "eslint-lsp",
    "tailwindcss-language-server",

    -- shell stuff
    "shfmt",

    -- development
    "azure-pipelines-language-server",
    "csharp-language-server",
    "dockerfile-language-server",
    "docker-compose-language-service",
    "terraform-lsp",
    "marksman"
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M