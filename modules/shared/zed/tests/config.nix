# Tests for the Zed settings file.
#
# The Zed module writes a JSON file, not a structured option set. The test
# therefore reads the evaluated file text and parses it. A parse failure or a
# case mismatch fails the build.
#
# Run the test with: nix flake check --impure
{
  pkgs,
  home,
  sharedPackages,
}:

let
  inherit (pkgs) lib;

  # ── Arrange ────────────────────────────────────────────────────────────────
  settings = builtins.fromJSON home.home.file.".config/zed/settings.json".text;

  # Zed resolves a language server through the shell environment of the
  # project. The server must therefore be on PATH. These are the packages that
  # home-manager installs into the user profile.
  packageNames = map (p: lib.getName p) home.home.packages;

  # The packages that this repository installs on purpose. The merged profile
  # also holds the packages of the external dotemacs module, thus the two lists
  # answer different questions.
  sharedNames = map (p: lib.getName p) sharedPackages;

  nixServers = settings.languages.Nix.language_servers or [ ];
  lspEntries = settings.lsp or { };

  # The theme block names one theme for light mode and one for dark mode. Each
  # of those themes needs its own override entry.
  theme = settings.theme or { };
  selectedThemes = lib.filter (t: t != null) [
    (theme.light or null)
    (theme.dark or null)
  ];

  overrides = settings.theme_overrides or { };

  # Read the comment style of one theme. Return null when the key is absent.
  commentStyleOf = name: overrides.${name}.syntax.comment.font_style or null;
  docCommentStyleOf = name: overrides.${name}.syntax."comment.doc".font_style or null;

  # The names of the servers that still carry a `path_lookup` key. Zed 1.15.0
  # holds no such string, thus the key does nothing. The cases below record the
  # present state and fail when the set changes, which keeps the later cleanup
  # visible.
  serversWithPathLookup = lib.sort lib.lessThan (
    lib.filter (name: (lspEntries.${name}.binary or { }) ? path_lookup) (lib.attrNames lspEntries)
  );

  # The binary that each Zed server name needs on PATH. The name of the server
  # and the name of the package are not always the same.
  binaryOwners = {
    csharp-language-server = "csharp-language-server";
    eslint = "vscode-langservers-extracted";
    tailwindcss-language-server = "tailwindcss-language-server";
    typescript-language-server = "typescript-language-server";
  };

  # ── Act and Assert ─────────────────────────────────────────────────────────
  cases = [
    # Nix files use nixd, the same server that Helix uses. The Zed nix
    # extension supplies both nil and nixd, so nil needs the explicit `!`
    # prefix. Without it Zed starts both servers and reports each problem
    # twice.
    {
      name = "nix language uses nixd and disables nil";
      actual = nixServers;
      expected = [
        "nixd"
        "!nil"
      ];
    }
    {
      name = "the nil server entry is removed";
      actual = lspEntries ? nil;
      expected = false;
    }
    {
      # The extension calls `Worktree::which("nixd")` and fails with "The Nix
      # language server (nixd) is not available in your environment (PATH)"
      # when the search finds nothing. The extension downloads no binary. The
      # user profile therefore has to supply one. A devenv or direnv shell
      # still takes precedence, because Zed reads the project shell
      # environment first.
      name = "nixd is on PATH through the user profile";
      actual = lib.elem "nixd" packageNames;
      expected = true;
    }
    {
      # The external dotemacs module also installs nixd, as one tool of its
      # Emacs set. Zed must not depend on that module. This repository has to
      # ask for nixd itself, so that a change to the Emacs configuration cannot
      # remove the Nix server of Zed.
      name = "this repository installs nixd on purpose";
      actual = lib.elem "nixd" sharedNames;
      expected = true;
    }
    {
      # `path_lookup` is not a key of BinarySettings. Zed 1.15.0 holds no such
      # string, and the documented keys are path, arguments, env and
      # ignore_system_version. A binary block for nixd is unnecessary, because
      # the PATH search already finds the server.
      name = "the nixd server needs no binary block";
      actual = (lspEntries.nixd or { }) ? binary;
      expected = false;
    }

    # Comments use the italic face. Zed has no setting for this. The style
    # comes from the theme, and the Tokyo Night extension sets font_style to
    # null for every variant. A theme override supplies the style.
    {
      name = "every selected theme has an override entry";
      actual = lib.subtractLists (lib.attrNames overrides) selectedThemes;
      expected = [ ];
    }
    {
      name = "comments are italic in every selected theme";
      actual = map commentStyleOf selectedThemes;
      expected = map (_: "italic") selectedThemes;
    }
    {
      name = "doc comments are italic in every selected theme";
      actual = map docCommentStyleOf selectedThemes;
      expected = map (_: "italic") selectedThemes;
    }
    {
      # Maple Mono NF supplies a true italic face, so the editor draws real
      # italics and does not slant the roman face. The test guards the font
      # choice, because a font without an italic face makes the override
      # useless.
      name = "the buffer font is Maple Mono NF";
      actual = settings.buffer_font_family or null;
      expected = "Maple Mono NF";
    }

    # ── The remaining servers ───────────────────────────────────────────────
    # These cases record the present state. They do not ask for a change. A
    # mismatch means that somebody changed the server set, and the comments
    # then say what to look at.
    {
      # Zed 1.15.0 contains no `path_lookup` string. The documented keys of
      # BinarySettings are path, arguments, env and ignore_system_version, so
      # each of these keys does nothing. Removal is safe but is not part of the
      # nixd change. A new name in this list means a new dead key.
      name = "the dead path_lookup key stays on the four known servers";
      actual = serversWithPathLookup;
      expected = [
        "csharp-language-server"
        "eslint"
        "tailwindcss-language-server"
        "typescript-language-server"
      ];
    }
    {
      # The nix extension errors when `which` finds no binary. The same holds
      # for these servers. Three of the four resolve today.
      name = "PATH supplies every server except the C# one";
      actual = lib.filter (n: lib.elem binaryOwners.${n} packageNames) (lib.attrNames binaryOwners);
      expected = [
        "eslint"
        "tailwindcss-language-server"
        "typescript-language-server"
      ];
    }
    {
      # Known gap. Nothing installs csharp-language-server, and the Zed config
      # disables roslyn and omnisharp, so Zed reports no C# problems at all.
      # Helix uses roslyn-ls instead, which the Helix module installs.
      name = "the C# server is absent from PATH";
      actual = lib.elem "csharp-language-server" packageNames;
      expected = false;
    }
    {
      # The three working servers come from the external dotemacs module, not
      # from this repository. Zed therefore depends on the Emacs configuration
      # for them. nixd no longer has that problem.
      name = "this repository installs none of the four servers";
      actual = lib.filter (n: lib.elem binaryOwners.${n} sharedNames) (lib.attrNames binaryOwners);
      expected = [ ];
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
pkgs.runCommand "zed-config-test" { } (
  if failures == [ ] then
    ''
      echo "zed-config-test: ${toString (lib.length cases)} cases passed"
      touch $out
    ''
  else
    ''
      echo "zed-config-test: ${toString (lib.length failures)} of ${toString (lib.length cases)} cases failed" >&2
      cat >&2 <<'EOF'
      ${report}
      EOF
      exit 1
    ''
)
