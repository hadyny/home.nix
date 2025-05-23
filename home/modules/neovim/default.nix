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
        tailwind-tools-nvim
        CopilotChat-nvim
        easy-dotnet-nvim
        conform-nvim
        vim-fugitive
        render-markdown-nvim
        snacks-nvim
        (pkgs.vimUtils.buildVimPlugin {
          pname = "tiny-code-action.nvim";
          version = "0.0.0";
          doCheck = false;
          src = pkgs.fetchFromGitHub {
            owner = "rachartier";
            repo = "tiny-code-action.nvim";
            rev = "main"; # or a specific commit hash
            sha256 = "sha256-I/UMOckl3raSw3wQFeklGRm3KTmds6cAUZjjhioBrDw=";
          };
        })
      ];
    };
  };
}
