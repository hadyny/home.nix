_self: super:

let
  pinnedAt =
    name: ref: hash:
    import (builtins.fetchGit {
      # Descriptive name to make the store path easier to identify
      name = "pinned-${name}";
      url = "https://github.com/NixOS/nixpkgs/";
      inherit ref;
      rev = hash;
    }) { localSystem = super.stdenv.hostPlatform.system; };

  pinnedMaster = name: hash: pinnedAt name "refs/heads/master" hash;

in
{
  # kcat: avro-cpp boost 1.89 fix (PR #494422) landed 2026-02-26
  inherit ((pinnedMaster "kcat" "b0c4cbb9aa0a52f3518fbdc77af71c0b607458d1")) kcat;
  # mitmproxy: aioquic 1.3.0 API fix (PR #494138) landed 2026-02-26
  inherit ((pinnedMaster "mitmproxy" "b0c4cbb9aa0a52f3518fbdc77af71c0b607458d1")) mitmproxy;
}
