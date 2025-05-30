{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.neovim = { enable = mkEnableOption "Neovim"; };
  config = mkIf config.modules.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraLuaConfig = builtins.readFile ./init.lua;
      plugins = with pkgs.vimPlugins; [
        mini-nvim
        catppuccin-nvim
        nvim-highlight-colors
        nvim-treesitter.withAllGrammars
        gitsigns-nvim
        nvim-lspconfig
        typescript-tools-nvim
        neotest-vitest
        neotest-dotnet
        roslyn-nvim
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
        tailwind-tools-nvim
        CopilotChat-nvim
        conform-nvim
        render-markdown-nvim
        snacks-nvim
        vim-sleuth
      ];
    };

    home.packages = with pkgs; [
      lua-language-server
      stylua

      nixfmt-classic
      nil

      roslyn-ls
      netcoredbg
      csharpier
      csharprepl

      tailwindcss-language-server
      rustywind
      graphql-language-service-cli
      vscode-langservers-extracted
    ];
  };
}
