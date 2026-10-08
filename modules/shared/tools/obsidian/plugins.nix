# Obsidian community plugins and themes, pinned to GitHub release assets.
# Update: change `version`, set each hash to lib.fakeHash, build, copy the real hash.
{ pkgs, lib }:

let
  mkRelease =
    {
      id,
      owner,
      repo,
      version,
      files,
    }:
    pkgs.runCommand "obsidian-${lib.removePrefix "obsidian-" (lib.toLower id)}-${version}"
      {
        # programs.obsidian reads manifestId before it falls back to reading
        # manifest.json, which would force a build during evaluation.
        passthru.manifestId = id;
      }
      (
        ''
          mkdir -p $out
        ''
        + lib.concatStrings (
          lib.mapAttrsToList (name: hash: ''
            cp ${
              pkgs.fetchurl {
                url = "https://github.com/${owner}/${repo}/releases/download/${version}/${name}";
                inherit hash;
              }
            } $out/${name}
          '') files
        )
      );
in
{
  # Themes have no manifest id; Obsidian uses the theme name as the folder name.
  minimal = mkRelease {
    id = "Minimal";
    owner = "kepano";
    repo = "obsidian-minimal";
    version = "9.1.4";
    files = {
      "manifest.json" = "sha256-Z6T/joSGB2RKMJK7WwFsk026BnKjQRFD4xQ0isbU9+c=";
      "theme.css" = "sha256-tj74oWJSmgapRbUaTaz3MzOx0nNmC+Jsht70VVhJlqg=";
    };
  };

  minimal-settings = mkRelease {
    id = "obsidian-minimal-settings";
    owner = "kepano";
    repo = "obsidian-minimal-settings";
    version = "9.0.0";
    files = {
      "main.js" = "sha256-91TgzmUj5DO/+OeZWoSPfX+sIFOZ+as7ElhDAmH9kMQ=";
      "manifest.json" = "sha256-IDj5wfXKAm68Hz4Va62XxnHSxAGiBxg4RQjvcgcejF8=";
      "styles.css" = "sha256-UAhHYNqSelv1rBudO5YNxS4dCjv2kOVN+PTXb4ISYow=";
    };
  };

  git = mkRelease {
    id = "obsidian-git";
    owner = "Vinzent03";
    repo = "obsidian-git";
    version = "2.41.1";
    files = {
      "main.js" = "sha256-KKGK/KsdLxUqDTyJr/OOKpetC+GuqvmWMGEyM7vsbBs=";
      "manifest.json" = "sha256-XU0PQRUYY2wdKkgxQlqONIe5JbW9QTvgyiLm3jilk/c=";
      "styles.css" = "sha256-v6j71F/kn/NA/bGWuEut1jGu3l1vlnQPM26nec1EEAU=";
    };
  };

  notebook-navigator = mkRelease {
    id = "notebook-navigator";
    owner = "johansan";
    repo = "notebook-navigator";
    version = "3.4.3";
    files = {
      "main.js" = "sha256-5NQ6bn48XiwxLCvwUHBG56byXN359/4rFrGx9zodSCk=";
      "manifest.json" = "sha256-RRvpgp82IBPEcTrOQjQyZ1XKtynkXR4zTyBbktf6h+U=";
      "styles.css" = "sha256-v6zQBMPFop9jVzqle5jKYKtYa+ZP3CQsw01tqNx3ROw=";
    };
  };

  tasknotes = mkRelease {
    id = "tasknotes";
    owner = "callumalpass";
    repo = "tasknotes";
    version = "4.13.8";
    files = {
      "main.js" = "sha256-ukKcVHYEjUvF/6UwaNgD8Rx5s/avJMxAegnpjIW+oJI=";
      "manifest.json" = "sha256-xAsOMjZef815M0X12gQ9nF3DJdZiwFpMiGkOCM30UuE=";
      "styles.css" = "sha256-eLVSWT9evdPf/e3+Pu6I4FpD54XoLbB2YAKaeI92NUY=";
    };
  };

}
