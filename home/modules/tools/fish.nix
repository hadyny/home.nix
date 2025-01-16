{ lib, osConfig, pkgs, ... }:
{
  programs.fish = {
    plugins = with pkgs.fishPlugins;[
      {
        name = "z";
        src = z.src;
      }
      {
        name = "sponge";
        src = sponge.src;
      }
      {
        name = "pure";
        src = pure.src;
      }
      {
        name = "nvm";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "nvm.fish";
          rev = "a0892d0bb2304162d5faff561f030bb418cac34d";
          sha256 = "sha256-GTEkCm+OtxMS3zJI5gnFvvObkrpepq1349/LcEPQRDo=";
        };
      }
      {
        name = "fzf";
        src = fzf-fish.src;
      }
      {
        name = "forgit";
        src = forgit.src;
      }
    ];
    # Fix for path issues on Darwin
    loginShellInit =
      let
        dquote = str: "\"" + str + "\"";

        makeBinPathList = map (path: path + "/bin");
      in
      ''
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
        set fish_user_paths $fish_user_paths
      '';
  };
}
