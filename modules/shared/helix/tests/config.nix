# Tests for the Helix language-server configuration.
#
# The test reads the evaluated `programs.helix` option set and compares it with
# the expected server wiring. The test fails the build if a case does not match.
#
# Run the test with: nix flake check --impure
{ pkgs, helix }:

let
  inherit (pkgs) lib;

  # ── Arrange ────────────────────────────────────────────────────────────────
  languages = helix.languages;
  servers = languages.language-server;

  # Find the language block with the given name.
  langOf = name: lib.findFirst (l: l.name == name) null languages.language;

  # Read the server names from a language block. A block can hold plain strings
  # or attribute sets that contain a `name` field.
  serversOf =
    name:
    let
      lang = langOf name;
    in
    if lang == null then
      [ ]
    else
      map (s: if lib.isString s then s else s.name) (lang.language-servers or [ ]);

  # Read the command of the given server. Return null if the server is absent.
  commandOf = name: servers.${name}.command or null;

  # Read the package names that Helix adds to its PATH.
  packageNames = map (p: lib.getName p) helix.extraPackages;

  # A theme is a plain string or a table. The empty set keeps the string form
  # usable in the checks below.
  theme = helix.settings.theme or null;
  themeAttrs = if builtins.isAttrs theme then theme else { };

  # ── Act and Assert ─────────────────────────────────────────────────────────
  cases = [
    # Helix changes the theme with the terminal only for the table form. A plain
    # string sets `is_adaptive()` to false, and the handler in
    # helix-term/src/application.rs then ignores every mode change.
    {
      name = "theme uses the adaptive table form";
      actual = themeAttrs ? light && themeAttrs ? dark;
      expected = true;
    }
    {
      # The enum denies unknown fields, thus a wrong key stops Helix at start.
      name = "theme sets no key other than light, dark and fallback";
      actual = lib.subtractLists [
        "light"
        "dark"
        "fallback"
      ] (lib.attrNames themeAttrs);
      expected = [ ];
    }
    {
      name = "the light theme and the dark theme differ";
      actual = (themeAttrs.light or null) != (themeAttrs.dark or "");
      expected = true;
    }

    # Nix files use nixd. The nil server is fully removed.
    {
      name = "nix language uses nixd";
      actual = serversOf "nix";
      expected = [ "nixd" ];
    }
    {
      name = "nixd server calls the local-first wrapper";
      actual = commandOf "nixd";
      expected = "nixd-local";
    }
    {
      name = "nil server entry is removed";
      actual = servers ? nil;
      expected = false;
    }
    {
      name = "nil package is removed from the Helix PATH";
      actual = lib.elem "nil" packageNames;
      expected = false;
    }

    # C# files use the Roslyn server that Nix supplies.
    {
      name = "c-sharp language uses the roslyn server";
      actual = serversOf "c-sharp";
      expected = [ "roslyn-language-server" ];
    }
    {
      name = "roslyn server calls the local-first wrapper";
      actual = commandOf "roslyn-language-server";
      expected = "roslyn-language-server-local";
    }
    {
      # Roslyn returns `diagnosticProvider` only when it receives these flags.
      name = "roslyn server receives the stdio and project flags";
      actual = servers.roslyn-language-server.args or null;
      expected = [
        "--stdio"
        "--autoLoadProjects"
      ];
    }
    {
      name = "roslyn-ls is on the Helix PATH";
      actual = lib.elem "roslyn-ls" packageNames;
      expected = true;
    }
    {
      name = "the csharp-language-server wrapper is removed";
      actual = lib.elem "csharp-language-server" packageNames;
      expected = false;
    }

    # TypeScript and TSX files use three servers.
    {
      name = "typescript language uses the three servers";
      actual = serversOf "typescript";
      expected = [
        "typescript-language-server"
        "tailwindcss"
        "eslint"
      ];
    }
    {
      name = "tsx language uses the three servers";
      actual = serversOf "tsx";
      expected = [
        "typescript-language-server"
        "tailwindcss"
        "eslint"
      ];
    }

    # Each node server calls a local-first wrapper.
    {
      name = "typescript server calls the local-first wrapper";
      actual = commandOf "typescript-language-server";
      expected = "typescript-language-server-local";
    }
    {
      name = "eslint server calls the local-first wrapper";
      actual = commandOf "eslint";
      expected = "vscode-eslint-language-server-local";
    }
    {
      name = "tailwindcss server calls the local-first wrapper";
      actual = commandOf "tailwindcss";
      expected = "tailwindcss-language-server-local";
    }

    # The empty nodePath stops ESLint from finding the project library.
    {
      name = "eslint config does not set nodePath";
      actual = servers.eslint.config ? nodePath;
      expected = false;
    }
    {
      # ESLint 9 reads a flat configuration without this key. The key also makes
      # the server load `eslint/use-at-your-own-risk` in place of `eslint`.
      name = "eslint config does not set the experimental flat config key";
      actual = servers.eslint.config ? experimental;
      expected = false;
    }

    # prettierd must receive the true path of the file. A relative dummy name
    # makes prettierd read the configuration from the wrong directory.
    {
      name = "prettierd receives the absolute file path";
      actual = (langOf "typescript").formatter.args;
      expected = [
        "--stdin-filepath"
        "%{file_path_absolute}"
      ];
    }
  ];

  failures = lib.filter (c: c.actual != c.expected) cases;

  report = lib.concatMapStringsSep "\n" (
    c:
    "  FAIL ${c.name}\n    expected: ${lib.generators.toPretty { } c.expected}\n    actual:   ${
        lib.generators.toPretty { } c.actual
      }"
  ) failures;
in
pkgs.runCommand "helix-config-test" { } (
  if failures == [ ] then
    ''
      echo "helix-config-test: ${toString (lib.length cases)} cases passed"
      touch $out
    ''
  else
    ''
      echo "helix-config-test: ${toString (lib.length failures)} of ${toString (lib.length cases)} cases failed" >&2
      cat >&2 <<'EOF'
      ${report}
      EOF
      exit 1
    ''
)
