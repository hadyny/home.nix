{ inputs, ... }:
let
  utils = inputs.nixCats.utils;
in
{
  imports = [ inputs.nixCats.homeModule ];
  config = {
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      enable = true;
      # nixpkgs_version = inputs.nixpkgs;
      # this will add the overlays from ./overlays and also,
      # add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # It will not apply to overall system, just nixCats.
      addOverlays = # (import ./overlays inputs) ++
        [ (utils.standardPluginOverlay inputs) ];
      # see the packageDefinitions below.
      # This says which of those to install.
      packageNames = [
        "neovimIde"
        "neovimVanilla"
        "miniNeovim"
        "dotnetNeovim"
      ];

      luaPath = ./.;

      # the .replace vs .merge options are for modules based on existing configurations,
      # they refer to how multiple categoryDefinitions get merged together by the module.
      # for useage of this section, refer to :h nixCats.flake.outputs.categories
      categoryDefinitions.replace = (
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          # to define and use a new category, simply add a new list to a set here,
          # and later, you will include categoryname = true; in the set you
          # provide when you build the package using this builder function.
          # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = {
            general = with pkgs; [ ];
            lua = with pkgs; [
              lua-language-server
              stylua
            ];
            nix = with pkgs; [
              nixd
              alejandra
            ];
            reactjs = with pkgs; [
              tailwindcss-language-server
              rustywind
              graphql-language-service-cli
              vscode-langservers-extracted
              vtsls
            ];
            csharp = with pkgs; [
              roslyn-ls
              netcoredbg
              csharpier
              csharprepl
            ];
            fsharp = with pkgs; [ fsautocomplete ];
            go = with pkgs; [
              gopls
              delve
              golint
              golangci-lint
              gotools
              go-tools
              go
            ];
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = {
            general = with pkgs.vimPlugins; [
              lze
              lzextras
              catppuccin-nvim
              onenord-nvim
              tokyonight-nvim
              vim-sleuth
            ];
            miniNvim = with pkgs.vimPlugins; [
              lze
              lzextras
              catppuccin-nvim
              onenord-nvim
              tokyonight-nvim
            ];
          };

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          optionalPlugins = {
            miniNvim = with pkgs.vimPlugins; [
              mini-nvim
              nvim-lspconfig
              nvim-treesitter.withAllGrammars
            ];
            go = with pkgs.vimPlugins; [ nvim-dap-go ];
            lua = with pkgs.vimPlugins; [ lazydev-nvim ];
            reactjs = with pkgs.vimPlugins; [
              nvim-highlight-colors
              neotest-vitest
            ];
            ai = with pkgs.vimPlugins; [
              avante-nvim
              blink-cmp-avante
            ];
            csharp = with pkgs.vimPlugins; [
              neotest-dotnet
              easy-dotnet-nvim
            ];
            general = with pkgs.vimPlugins; [
              mini-nvim
              nvim-lspconfig
              vim-startuptime
              blink-cmp
              nvim-treesitter.withAllGrammars
              gitsigns-nvim
              nvim-lint
              conform-nvim
              neotest
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
              CopilotChat-nvim
              lualine-nvim
              snacks-nvim
              fidget-nvim
              quicker-nvim
              hlchunk-nvim
              which-key-nvim
              (pkgs.vimUtils.buildVimPlugin {
                pname = "tiny-code-action.nvim";
                version = "0.0.0";
                doCheck = false;
                src = pkgs.fetchFromGitHub {
                  owner = "rachartier";
                  repo = "tiny-code-action.nvim";
                  rev = "main"; # or a specific commit hash
                  sha256 = "sha256-XBVE8FJVUljRdF5G5iug+V+fVp/uaB4B4kfo4yvI+9w=";
                };
              })
              tiny-inline-diagnostic-nvim
            ];
            docs = with pkgs.vimPlugins; [
              render-markdown-nvim
              obsidian-nvim
            ];
          };

          # shared libraries to be added to LD_LIBRARY_PATH
          # variable available to nvim runtime
          sharedLibraries = {
            general = [ ];
          };

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = {
            # test = {
            #   CATTESTVAR = "It worked!";
            # };
          };

          # categories of the function you would have passed to withPackages
          python3.libraries = {
            # test = [ (_:[]) ];
          };

          # If you know what these are, you can provide custom ones by category here.
          # If you dont, check this link out:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = {
            # test = [
            #   '' --set CATTESTVAR2 "It worked again!"''
            # ];
          };
        }
      );

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions.replace = {
        # These are the names of your packages
        # you can include as many as you wish.
        neovimIde =
          { pkgs, name, ... }:
          {
            # they contain a settings set defined above
            # see :help nixCats.flake.outputs.settings
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
              neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
            };
            # and a set of categories that you want
            # (and other information to pass to lua)
            # and a set of categories that you want
            categories = {
              general = true;
              ai = false;
              lua = true;
              nix = true;
              go = false;
              csharp = true;
              fsharp = true;
              reactjs = true;
              docs = true;
              miniNvim = false;
            };
            # anything else to pass and grab in lua with `nixCats.extra`
            extra = {
              nixdExtras.nixpkgs = "import ${pkgs.path} {}";
            };
          };
        neovimVanilla =
          { pkgs, name, ... }:
          {
            # they contain a settings set defined above
            # see :help nixCats.flake.outputs.settings
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
            };
            categories = {
              general = false;
              ai = false;
              lua = false;
              nix = false;
              go = false;
              csharp = false;
              fsharp = false;
              reactjs = false;
              docs = false;
              miniNvim = false;
            };
            # anything else to pass and grab in lua with `nixCats.extra`
            extra = {
              nixdExtras.nixpkgs = "import ${pkgs.path} {}";
            };
          };
        miniNeovim =
          { pkgs, name, ... }:
          {
            # they contain a settings set defined above
            # see :help nixCats.flake.outputs.settings
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
              aliases = [ "nvim" ];
            };
            categories = {
              general = false;
              ai = false;
              lua = true;
              nix = true;
              go = false;
              csharp = true;
              fsharp = false;
              reactjs = true;
              docs = false;
              miniNvim = true;
            };
            # anything else to pass and grab in lua with `nixCats.extra`
            extra = {
              nixdExtras.nixpkgs = "import ${pkgs.path} {}";
            };
          };

        dotnetNeovim =
          { pkgs, name, ... }:
          {
            # they contain a settings set defined above
            # see :help nixCats.flake.outputs.settings
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
            };
            categories = {
              general = true;
              ai = false;
              lua = false;
              nix = false;
              go = false;
              csharp = true;
              fsharp = false;
              reactjs = false;
              docs = false;
              miniNvim = false;
            };
            # anything else to pass and grab in lua with `nixCats.extra`
            extra = {
              nixdExtras.nixpkgs = "import ${pkgs.path} {}";
            };
          };

      };
    };
  };
}
