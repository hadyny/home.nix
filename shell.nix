with (import <nixpkgs> { config.allowUnfree = true; });
{
  shell = mkShell {
    buildInputs = [ nodejs nixd alejandra ];

    shellHook = "";
  };
}
