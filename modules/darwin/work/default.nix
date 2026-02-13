{
  imports = [
    ./aws.nix
    ../../shared/secureEnv/onePassword.nix
    ../home-manager.nix
  ];

  tools.dotnet = {
    nugetSources = {
      "ep-github" = {
        url = "%EP_NUGET_SOURCE_URL%";
        userName = "%EP_NUGET_SOURCE_USER%";
        password = "%EP_NUGET_SOURCE_PASS%";
      };
    };
  };

  secureEnv.onePassword = {
    enable = true;
    sessionVariables = {
      EP_NUGET_SOURCE_URL = {
        vault = "Employee";
        item = "GitHub";
        field = "nuget url";
      };
      EP_NUGET_SOURCE_PASS = {
        vault = "Employee";
        item = "GitHub";
        field = "nuget token";
      };

      EP_NUGET_SOURCE_USER = {
        vault = "Employee";
        item = "GitHub";
        field = "username";
      };

      FUSIONAUTH_LICENCE = {
        vault = "Dev - Shared DevOps";
        item = "FusionAuth Licences";
        field = "Non-Production";
      };

      EP_NPM_TOKEN = {
        vault = "Dev - Shared";
        item = "NPM readonly token";
        field = "token";
      };
    };
  };
}
