{ config, lib, pkgs, ... }:

with lib;

let
  enabled = cfg.enable && pkgs.hostPlatform.isDarwin;
  cfg = config.darwin.apps.firefox;

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  mozillaConfigPath =
    if isDarwin then "Library/Application Support/Mozilla" else ".mozilla";

  firefoxConfigPath = if isDarwin then
    "Library/Application Support/Firefox"
  else
    "${mozillaConfigPath}/firefox";

  profilesPath =
    if isDarwin then "${firefoxConfigPath}/Profiles" else firefoxConfigPath;

  profiles = flip mapAttrs' cfg.profiles (_: profile:
    nameValuePair "Profile${toString profile.id}" {
      Name = profile.name;
      Path = if isDarwin then "Profiles/${profile.path}" else profile.path;
      IsRelative = 1;
      Default = if profile.isDefault then 1 else 0;
    }) // {
      General = { StartWithLastProfile = 1; };
    };

    profilesIni = generators.toINI { } profiles;

  userPrefValue = pref:
    builtins.toJSON (if isBool pref || isInt pref || isString pref then
      pref
    else
      builtins.toJSON pref);

  mkUserJs = prefs: extraPrefs: bookmarks:
    let
      prefs' = lib.optionalAttrs ([ ] != bookmarks) {
        "browser.bookmarks.file" = toString (firefoxBookmarksFile bookmarks);
        "browser.places.importBookmarksHTML" = true;
      } // prefs;
    in ''
      // Generated by Home Manager.

      ${concatStrings (mapAttrsToList (name: value: ''
        user_pref("${name}", ${userPrefValue value});
      '') prefs')}

      ${extraPrefs}
    '';

  firefoxBookmarksFile = bookmarks:
    let
      indent = level:
        lib.concatStringsSep "" (map (lib.const "  ") (lib.range 1 level));

      bookmarkToHTML = indentLevel: bookmark:
        ''
          ${indent indentLevel}<DT><A HREF="${
            escapeXML bookmark.url
          }" ADD_DATE="1" LAST_MODIFIED="1"${
            lib.optionalString (bookmark.keyword != null)
            " SHORTCUTURL=\"${escapeXML bookmark.keyword}\""
          }${
            lib.optionalString (bookmark.tags != [ ])
            " TAGS=\"${escapeXML (concatStringsSep "," bookmark.tags)}\""
          }>${escapeXML bookmark.name}</A>'';

      directoryToHTML = indentLevel: directory: ''
        ${indent indentLevel}<DT>${
          if directory.toolbar then
            ''<H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar''
          else
            "<H3>${escapeXML directory.name}"
        }</H3>
        ${indent indentLevel}<DL><p>
        ${allItemsToHTML (indentLevel + 1) directory.bookmarks}
        ${indent indentLevel}</p></DL>'';

      itemToHTMLOrRecurse = indentLevel: item:
        if item ? "url" then
          bookmarkToHTML indentLevel item
        else
          directoryToHTML indentLevel item;

      allItemsToHTML = indentLevel: bookmarks:
        lib.concatStringsSep "\n"
        (map (itemToHTMLOrRecurse indentLevel) bookmarks);

      bookmarkEntries = allItemsToHTML 1 bookmarks;
    in pkgs.writeText "firefox-bookmarks.html" ''
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
        It will be read and overwritten.
        DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks Menu</H1>
      <DL><p>
      ${bookmarkEntries}
      </p></DL>
    '';
in
{
  options.darwin.apps.firefox = { 
    enable = mkEnableOption "Enable Firefox"; 
    profiles = mkOption {
        type = types.attrsOf (types.submodule ({ config, name, ... }: {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
              description = "Profile name.";
            };

            id = mkOption {
              type = types.ints.unsigned;
              default = 0;
              description = ''
                Profile ID. This should be set to a unique number per profile.
              '';
            };

            settings = mkOption {
              type = types.attrsOf (jsonFormat.type // {
                description =
                  "Firefox preference (int, bool, string, and also attrs, list, float as a JSON string)";
              });
              default = { };
              example = literalExpression ''
                {
                  "browser.startup.homepage" = "https://nixos.org";
                  "browser.search.region" = "GB";
                  "browser.search.isUS" = false;
                  "distribution.searchplugins.defaultLocale" = "en-GB";
                  "general.useragent.locale" = "en-GB";
                  "browser.bookmarks.showMobileBookmarks" = true;
                  "browser.newtabpage.pinned" = [{
                    title = "NixOS";
                    url = "https://nixos.org";
                  }];
                }
              '';
              description = ''
                Attribute set of Firefox preferences.

                Firefox only supports int, bool, and string types for
                preferences, but home-manager will automatically
                convert all other JSON-compatible values into strings.
              '';
            };

            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = ''
                Extra preferences to add to {file}`user.js`.
              '';
            };

            userChrome = mkOption {
              type = types.lines;
              default = "";
              description = "Custom Firefox user chrome CSS.";
              example = ''
                /* Hide tab bar in FF Quantum */
                @-moz-document url("chrome://browser/content/browser.xul") {
                  #TabsToolbar {
                    visibility: collapse !important;
                    margin-bottom: 21px !important;
                  }

                  #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
                    visibility: collapse !important;
                  }
                }
              '';
            };

            userContent = mkOption {
              type = types.lines;
              default = "";
              description = "Custom Firefox user content CSS.";
              example = ''
                /* Hide scrollbar in FF Quantum */
                *{scrollbar-width:none !important}
              '';
            };

            bookmarks = mkOption {
              type = let
                bookmarkSubmodule = types.submodule ({ config, name, ... }: {
                  options = {
                    name = mkOption {
                      type = types.str;
                      default = name;
                      description = "Bookmark name.";
                    };

                    tags = mkOption {
                      type = types.listOf types.str;
                      default = [ ];
                      description = "Bookmark tags.";
                    };

                    keyword = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                      description = "Bookmark search keyword.";
                    };

                    url = mkOption {
                      type = types.str;
                      description = "Bookmark url, use %s for search terms.";
                    };
                  };
                }) // {
                  description = "bookmark submodule";
                };

                bookmarkType = types.addCheck bookmarkSubmodule (x: x ? "url");

                directoryType = types.submodule ({ config, name, ... }: {
                  options = {
                    name = mkOption {
                      type = types.str;
                      default = name;
                      description = "Directory name.";
                    };

                    bookmarks = mkOption {
                      type = types.listOf nodeType;
                      default = [ ];
                      description = "Bookmarks within directory.";
                    };

                    toolbar = mkOption {
                      type = types.bool;
                      default = false;
                      description = "If directory should be shown in toolbar.";
                    };
                  };
                }) // {
                  description = "directory submodule";
                };

                nodeType = types.either bookmarkType directoryType;
              in with types;
              coercedTo (attrsOf nodeType) attrValues (listOf nodeType);
              default = [ ];
              example = literalExpression ''
                [
                  {
                    name = "wikipedia";
                    tags = [ "wiki" ];
                    keyword = "wiki";
                    url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
                  }
                  {
                    name = "kernel.org";
                    url = "https://www.kernel.org";
                  }
                  {
                    name = "Nix sites";
                    toolbar = true;
                    bookmarks = [
                      {
                        name = "homepage";
                        url = "https://nixos.org/";
                      }
                      {
                        name = "wiki";
                        tags = [ "wiki" "nix" ];
                        url = "https://nixos.wiki/";
                      }
                    ];
                  }
                ]
              '';
              description = ''
                Preloaded bookmarks. Note, this may silently overwrite any
                previously existing bookmarks!
              '';
            };

            path = mkOption {
              type = types.str;
              default = name;
              description = "Profile path.";
            };

            isDefault = mkOption {
              type = types.bool;
              default = config.id == 0;
              defaultText = "true if profile ID is 0";
              description = "Whether this is a default profile.";
            };

            search = {
              force = mkOption {
                type = with types; bool;
                default = false;
                description = ''
                  Whether to force replace the existing search
                  configuration. This is recommended since Firefox will
                  replace the symlink for the search configuration on every
                  launch, but note that you'll lose any existing
                  configuration by enabling this.
                '';
              };

              default = mkOption {
                type = with types; nullOr str;
                default = null;
                example = "DuckDuckGo";
                description = ''
                  The default search engine used in the address bar and search bar.
                '';
              };

              order = mkOption {
                type = with types; uniq (listOf str);
                default = [ ];
                example = [ "DuckDuckGo" "Google" ];
                description = ''
                  The order the search engines are listed in. Any engines
                  that aren't included in this list will be listed after
                  these in an unspecified order.
                '';
              };

              engines = mkOption {
                type = with types; attrsOf (attrsOf jsonFormat.type);
                default = { };
                example = literalExpression ''
                  {
                    "Nix Packages" = {
                      urls = [{
                        template = "https://search.nixos.org/packages";
                        params = [
                          { name = "type"; value = "packages"; }
                          { name = "query"; value = "{searchTerms}"; }
                        ];
                      }];

                      icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                      definedAliases = [ "@np" ];
                    };

                    "NixOS Wiki" = {
                      urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
                      iconUpdateURL = "https://nixos.wiki/favicon.png";
                      updateInterval = 24 * 60 * 60 * 1000; # every day
                      definedAliases = [ "@nw" ];
                    };

                    "Bing".metaData.hidden = true;
                    "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
                  }
                '';
                description = ''
                  Attribute set of search engine configurations. Engines
                  that only have {var}`metaData` specified will
                  be treated as builtin to Firefox.

                  See [SearchEngine.jsm](https://searchfox.org/mozilla-central/rev/669329e284f8e8e2bb28090617192ca9b4ef3380/toolkit/components/search/SearchEngine.jsm#1138-1177)
                  in Firefox's source for available options. We maintain a
                  mapping to let you specify all options in the referenced
                  link without underscores, but it may fall out of date with
                  future options.

                  Note, {var}`icon` is also a special option
                  added by Home Manager to make it convenient to specify
                  absolute icon paths.
                '';
              };
            };

            extensions = mkOption {
              type = types.listOf types.package;
              default = [ ];
              example = literalExpression ''
                with pkgs.nur.repos.rycee.firefox-addons; [
                  privacy-badger
                ]
              '';
              description = ''
                List of Firefox add-on packages to install for this profile.
                Some pre-packaged add-ons are accessible from the
                [Nix User Repository](https://github.com/nix-community/NUR).
                Once you have NUR installed run

                ```console
                $ nix-env -f '<nixpkgs>' -qaP -A nur.repos.rycee.firefox-addons
                ```

                to list the available Firefox add-ons.

                Note that it is necessary to manually enable these extensions
                inside Firefox after the first installation.
              '';
            };

          };
        }));
        default = { };
        description = "Attribute set of Firefox profiles.";
      };
  };

  config = mkIf enabled {
    homebrew = {
      casks = [ "firefox" ];
    };

    assertions = [
      (let
        defaults =
          catAttrs "name" (filter (a: a.isDefault) (attrValues cfg.profiles));
      in {
        assertion = cfg.profiles == { } || length defaults == 1;
        message = "Must have exactly one default Firefox profile but found "
          + toString (length defaults) + optionalString (length defaults > 1)
          (", namely " + concatStringsSep ", " defaults);
      })

      (let
        duplicates = filterAttrs (_: v: length v != 1) (zipAttrs
          (mapAttrsToList (n: v: { "${toString v.id}" = n; }) (cfg.profiles)));

        mkMsg = n: v: "  - ID ${n} is used by ${concatStringsSep ", " v}";
      in {
        assertion = duplicates == { };
        message = ''
          Must not have Firefox profiles with duplicate IDs but
        '' + concatStringsSep "\n" (mapAttrsToList mkMsg duplicates);
      })
    ];
  };
}
