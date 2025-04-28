{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.vscode = { enable = mkEnableOption "VS Code from nixpkgs"; };

  config = mkIf config.modules.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      mutableExtensionsDir = true;

      # Common extensions
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          asvetliakov.vscode-neovim
          bodil.file-browser
          bradlc.vscode-tailwindcss
          christian-kohler.npm-intellisense
          dbaeumer.vscode-eslint
          ms-azuretools.vscode-docker
          ecmel.vscode-html-css
          editorconfig.editorconfig
          esbenp.prettier-vscode
          github.copilot
          github.copilot-chat
          github.vscode-github-actions
          github.vscode-pull-request-github
          golang.go
          graphql.vscode-graphql
          graphql.vscode-graphql-syntax
          hashicorp.terraform
          jnoortheen.nix-ide
          jock.svg
          kahole.magit
          mechatroner.rainbow-csv
          ms-azuretools.vscode-docker
          ms-dotnettools.csdevkit
          ms-dotnettools.csharp
          ms-dotnettools.vscode-dotnet-runtime
          ms-dotnettools.vscodeintellicode-csharp
          ms-vscode-remote.remote-containers
          ms-vscode.live-server
          mvllow.rose-pine
          redhat.vscode-yaml
          sumneko.lua
          vspacecode.vspacecode
          vspacecode.whichkey
          yoavbls.pretty-ts-errors
          yzhang.markdown-all-in-one
        ];

        # User settings
        userSettings = {
          "workbench.colorTheme" = "Rosé Pine";
          "editor.fontFamily" =
            "CommitMono, 'GeistMono Nerd Font Mono', 'Droid Sans Mono', monospace";
          "editor.fontLigatures" =
            "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'cv01', 'cv06'";
          "workbench.preferredDarkColorTheme" = "Rosé Pine Moon";
          "workbench.preferredLightColorTheme" = "Rosé Pine Dawn";
          "window.autoDetectColorScheme" = true;
          "githubPullRequests.pullBranch" = "never";
          "git.autofetch" = true;
          "workbench.activityBar.location" = "hidden";
          "workbench.startupEditor" = "none";
          "editor.minimap.enabled" = false;
          "editor.lineNumbers" = "off";
          "[jsonc]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
          "explorer.fileNesting.enabled" = true;
          "explorer.fileNesting.patterns" = {
            "*.ts" = "\${capture}.js, \${capture}.typegen.ts";
            "*.js" =
              "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
            "*.jsx" = "\${capture}.js";
            "*.tsx" = "\${capture}.ts, \${capture}.typegen.ts";
            "tsconfig.json" = "tsconfig.*.json";
            "package.json" =
              "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb";
            "*.mts" = "\${capture}.typegen.ts";
            "*.cts" = "\${capture}.typegen.ts";
          };
          "extensions.experimental.affinity" = {
            "asvetliakov.vscode-neovim" = 1;
          };
          "editor.accessibilitySupport" = "off";
          "git.blame.editorDecoration.enabled" = true;
          "workbench.sideBar.location" = "right";
          "csharp.preview.improvedLaunchExperience" = true;
          "editor.inlineSuggest.syntaxHighlightingEnabled" = true;
          "workbench.statusBar.visible" = false;
          "editor.guides.indentation" = false;
          "workbench.editor.showTabs" = "none";
          "editor.stickyScroll.enabled" = false;
          "editor.fontSize" = 14;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
        };

        # Keybindings
        keybindings = [
          {
            "key" = "space";
            "command" = "vspacecode.space";
            "when" = "editorTextFocus && neovim.mode == normal";
          }
          {
            "key" = "space";
            "command" = "vspacecode.space";
            "when" = "sideBarFocus && !inputFocus && !whichkeyActive";
          }
          {
            "key" = "tab";
            "command" = "extension.vim_tab";
            "when" =
              "editorTextFocus && neovim.active && !inDebugRepl && neovim.mode != 'Insert' && editorLangId != 'magit'";
          }
          {
            "key" = "tab";
            "command" = "-extension.vim_tab";
            "when" =
              "editorTextFocus && neovim.active && !inDebugRepl && neovim.mode != 'Insert'";
          }
          {
            "key" = "x";
            "command" = "magit.discard-at-point";
            "when" =
              "editorTextFocus && editorLangId == 'magit' && neovim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
          }
          {
            "key" = "k";
            "command" = "-magit.discard-at-point";
          }
          {
            "key" = "-";
            "command" = "magit.reverse-at-point";
            "when" =
              "editorTextFocus && editorLangId == 'magit' && neovim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
          }
          {
            "key" = "v";
            "command" = "-magit.reverse-at-point";
          }
          {
            "key" = "shift+-";
            "command" = "magit.reverting";
            "when" =
              "editorTextFocus && editorLangId == 'magit' && neovim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
          }
          {
            "key" = "shift+v";
            "command" = "-magit.reverting";
          }
          {
            "key" = "shift+o";
            "command" = "magit.resetting";
            "when" =
              "editorTextFocus && editorLangId == 'magit' && neovim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
          }
          {
            "key" = "shift+x";
            "command" = "-magit.resetting";
          }
          {
            "key" = "x";
            "command" = "-magit.reset-mixed";
          }
          {
            "key" = "ctrl+u x";
            "command" = "-magit.reset-hard";
          }
          {
            "key" = "y";
            "command" = "-magit.show-refs";
          }
          {
            "key" = "y";
            "command" = "vspacecode.showMagitRefMenu";
            "when" =
              "editorTextFocus && editorLangId == 'magit' && neovim.mode == 'Normal'";
          }
          {
            "key" = "g";
            "command" = "-magit.refresh";
            "when" =
              "editorTextFocus && editorLangId == 'magit' && neovim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
          }
          {
            "key" = "g";
            "command" = "vspacecode.showMagitRefreshMenu";
            "when" =
              "editorTextFocus && editorLangId == 'magit' && neovim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
          }
          {
            "key" = "ctrl+j";
            "command" = "workbench.action.quickOpenSelectNext";
            "when" = "inQuickOpen";
          }
          {
            "key" = "ctrl+k";
            "command" = "workbench.action.quickOpenSelectPrevious";
            "when" = "inQuickOpen";
          }
          {
            "key" = "ctrl+j";
            "command" = "selectNextSuggestion";
            "when" =
              "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
          }
          {
            "key" = "ctrl+k";
            "command" = "selectPrevSuggestion";
            "when" =
              "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
          }
          {
            "key" = "ctrl+l";
            "command" = "acceptSelectedSuggestion";
            "when" =
              "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
          }
          {
            "key" = "ctrl+j";
            "command" = "showNextParameterHint";
            "when" =
              "editorFocus && parameterHintsMultipleSignatures && parameterHintsVisible";
          }
          {
            "key" = "ctrl+k";
            "command" = "showPrevParameterHint";
            "when" =
              "editorFocus && parameterHintsMultipleSignatures && parameterHintsVisible";
          }
          {
            "key" = "ctrl+j";
            "command" = "selectNextCodeAction";
            "when" = "codeActionMenuVisible";
          }
          {
            "key" = "ctrl+k";
            "command" = "selectPrevCodeAction";
            "when" = "codeActionMenuVisible";
          }
          {
            "key" = "ctrl+l";
            "command" = "acceptSelectedCodeAction";
            "when" = "codeActionMenuVisible";
          }
          {
            "key" = "ctrl+h";
            "command" = "file-browser.stepOut";
            "when" = "inFileBrowser";
          }
          {
            "key" = "ctrl+l";
            "command" = "file-browser.stepIn";
            "when" = "inFileBrowser";
          }
        ];
      };
    };
  };
}
