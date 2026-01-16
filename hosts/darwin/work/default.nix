{
  imports = [
    ../default.nix
    ./certificates.nix
  ];

  nix.registry = {
    ep = {
      from = {
        type = "indirect";
        id = "ep";
      };
      to = {
        type = "git";
        url = "ssh://git@github.com/educationperfect/ep-nix";
      };
    };
  };
}
