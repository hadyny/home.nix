{
  pkgs,
  config,
  fetchFromGitHub,
  ...
}:
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  home.packages = with pkgs; [
    rnix-lsp
    haskell-language-server
  ];

  xdg.configFile."nvim".source = pkgs.stdenv.mkDerivation {
    name = "NvChad";
    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "f17e83010f25784b58dea175c6480b3a8225a3e9";
      hash = "sha256-P5TRjg603/7kOVNFC8nXfyciNRLsIeFvKsoRCIwFP3I=";
    };
    installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
    cd $out/
    cp -r ${./nvchad_config} $out/lua/custom
    '';
  };
}
