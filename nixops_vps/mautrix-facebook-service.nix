{ config, pkgs, lib, ... }:

with lib;

let
  dataDir = "/var/lib/mautrix-facebook";
  registrationFile = "${dataDir}/facebook-registration.yaml";
  cfg = config.services.mautrix-facebook;
  # TODO: switch to configGen.json once RFC42 is implemented
  settingsFile = pkgs.writeText "mautrix-facebook-settings.json" (builtins.toJSON cfg.settings);

in {
  options = {
    services.mautrix-facebook = {
      enable = mkEnableOption "Mautrix-Facebook, a Matrix-Messenger hybrid puppeting/relaybot bridge";

      settings = mkOption rec {
        # TODO: switch to types.config.json as prescribed by RFC42 once it's implemented
        type = types.attrs;
        apply = recursiveUpdate default;
        default = {
          appservice = rec {
            database = "sqlite:///${dataDir}/mautrix-facebook.db";
            hostname = "0.0.0.0";
            port = 8081;
            address = "http://localhost:${toString port}";
          };

          bridge = {
            permissions."*" = "relaybot";
            relaybot.whitelist = [ ];
          };

          logging = {
            version = 1;

            formatters.precise.format = "[%(levelname)s@%(name)s] %(message)s";

            handlers.console = {
              class = "logging.StreamHandler";
              formatter = "precise";
            };

            loggers = {
              mau.level = "INFO";

              # prevent tokens from leaking in the logs:
              aiohttp.level = "WARNING";
            };

            # log to console/systemd instead of file
            root = {
              level = "INFO";
              handlers = [ "console" ];
            };
          };
        };
        example = literalExample ''
          {
            homeserver = {
              address = "http://localhost:8008";
              domain = "public-domain.tld";
            };

            appservice.public = {
              prefix = "/public";
              external = "https://public-appservice-address/public";
            };

            bridge.permissions = {
              "example.com" = "full";
              "@admin:example.com" = "admin";
            };
          }
        '';
        description = ''
          <filename>config.yaml</filename> configuration as a Nix attribute set.
          Configuration options should match those described in
          <link xlink:href="https://github.com/tulir/mautrix-facebook/blob/master/example-config.yaml">
          example-config.yaml</link>.
          </para>

          <para>
          Secret tokens should be specified using <option>environmentFile</option>
          instead of this world-readable attribute set.
        '';
      };

      serviceDependencies = mkOption {
        type = with types; listOf str;
        default = optional config.services.matrix-synapse.enable "matrix-synapse.service";
        description = ''
          List of Systemd services to require and wait for when starting the application service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mautrix-facebook = {
      description = "Mautrix-Facebook, a Matrix-Messenger hybrid puppeting/relaybot bridge.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      preStart = ''
        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
            ${pkgs.mautrix-facebook}/bin/mautrix-facebook \
            --generate-registration \
            --base-config='${pkgs.mautrix-facebook}/${pkgs.mautrix-facebook.pythonModule.sitePackages}/mautrix_facebook/example-config.yaml' \
            --config='${settingsFile}' \
            --registration='${registrationFile}'
        fi
        sed "s/appservice\":{/appservice\":{$(cat ${dataDir}/tokens.json),/" '${settingsFile}'  > '${dataDir}/catted_config.json'

        # run automatic database init and migration scripts
        ${pkgs.mautrix-facebook.alembic}/bin/alembic -x config='${settingsFile}' upgrade head
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        DynamicUser = true;
        PrivateTmp = true;
        WorkingDirectory = pkgs.mautrix-facebook; # necessary for the database migration scripts to be found
        StateDirectory = baseNameOf dataDir;
        UMask = 0027;
        #EnvironmentFile = cfg.environmentFile;

        ExecStart = ''
          ${pkgs.mautrix-facebook}/bin/mautrix-facebook \
            --config='${dataDir}/catted_config.json' \
            --no-update
        '';
      };
    };
  };

}
