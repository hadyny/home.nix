{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.tools.dotnet;

  vscodeSdkPath = "/usr/local/share/dotnet";

  dotnet-env = with pkgs.dotnetCorePackages;
    combinePackages [ sdk_8_0 sdk_9_0 ];

  buildNugetConfig = nugetSources:
    pkgs.stdenv.mkDerivation {
      name = "nugetConfig";
      phases = [ "installPhase" ];
      buildInputs = with pkgs; [ dotnet-sdk ];
      installPhase = let
        toCommand = name: params:
          "${dotnet-env}/bin/dotnet nuget add source ${params.url} --name ${name} --username ${params.userName} --password ${params.password} --store-password-in-clear-text";
        commands =
          lib.concatStringsSep "\n" (lib.mapAttrsToList toCommand nugetSources);
      in ''
        mkdir -p $out
        export HOME=$TMPDIR
        ${commands}
        cp -r $TMPDIR/.nuget $out/
      '';
    };
in {
  options.tools.dotnet = {
    enable = mkEnableOption "Enable dotnet";

    nugetSources = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          url = mkOption { type = types.str; };
          userName = mkOption { type = types.str; };
          password = mkOption { type = types.str; };
        };
      });
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ dotnet-env ];

    home.sessionPath = [ "$HOME/.dotnet/tools" vscodeSdkPath ];
    home.sessionVariables = { DOTNET_ROOT = vscodeSdkPath; };

    home.file.".nuget/NuGet/NuGet.Config".source =
      let nugetConfig = buildNugetConfig cfg.nugetSources;
      in "${nugetConfig}/.nuget/NuGet/NuGet.Config";
  };
}
