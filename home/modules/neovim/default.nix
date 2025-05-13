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
        mini-icons
        catppuccin-nvim
        nvim-highlight-colors
        blink-cmp
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
        tiny-inline-diagnostic-nvim
        CopilotChat-nvim
        easy-dotnet-nvim
        conform-nvim
        vim-fugitive
        render-markdown-nvim
        snacks-nvim
        actions-preview-nvim
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-frecency-nvim
      ];
    };
  };
}
