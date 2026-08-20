{ pkgs, ... }:
let
  dooit-with-extras = pkgs.dooit.overridePythonAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pkgs.dooit-extras ];
  });
in
{
  home.packages = [ dooit-with-extras ];

  # platformdirs on macOS resolves to ~/Library/Application Support/dooit,
  # not ~/.config/dooit, so we deploy to both paths.
  home.file."Library/Application Support/dooit/config.py" =
    pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      {
        source = ./config.py;
      };
  xdg.configFile."dooit/config.py" = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    source = ./config.py;
  };
}
