{
  imports = [ ./aws.nix ];

  tools.dotnet = {
    nugetSources = {
      "ep-github" = {
        url = "https://nuget.pkg.github.com/EducationPerfect/index.json";
        userName = "%EP_NUGET_SOURCE_USER%";
        password = "%EP_NUGET_SOURCE_PASS%";
      };
    };
  };

  secureEnv.onePassword = {
    enable = true;
    sessionVariables = {
      EP_NUGET_SOURCE_PASS = {
        account = "educationperfect.1password.com";
        vault = "Employee";
        item = "GitHub";
        field = "nuget token";
      };

      EP_NUGET_SOURCE_USER = {
        account = "educationperfect.1password.com";
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
