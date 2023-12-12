return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        csharp_ls = {},
        tsserver = {},
        tailwindcss = {},
      },
    },
  },
}
