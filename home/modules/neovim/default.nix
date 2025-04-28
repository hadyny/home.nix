{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    extraLuaConfig = builtins.readFile ./init.lua;
    plugins = with pkgs.vimPlugins; [
      mini-bufremove
      mini-icons
      rose-pine
      nvim-highlight-colors
      blink-cmp
      colorful-menu-nvim
      which-key-nvim
      nvim-treesitter.withAllGrammars
      gitsigns-nvim
      nvim-lspconfig
      typescript-tools-nvim
      tsc-nvim
      neotest-vitest
      neotest-dotnet
      roslyn-nvim
      nvim-dap
      tailwind-tools-nvim
      yazi-nvim
      tiny-inline-diagnostic-nvim
      CopilotChat-nvim
      easy-dotnet-nvim
      fzf-lua
      conform-nvim
      trouble-nvim
      vim-fugitive
      render-markdown-nvim
    ];
  };
}
