{ lib, ... }:

with lib; {
  options = with types; {
    user = mkOption {
      type = attrs;
      default = { };
    };
  };

  config = {
    user = let
      name = "hadyn";
      home = "/Users/hadyn";
    in {
      inherit name;
      inherit home;
    };
  };
}
