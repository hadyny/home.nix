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
        mini-pick
        mini-extra
        mini-clue
        mini-completion
        mini-files
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
  };
}
