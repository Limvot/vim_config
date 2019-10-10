{ config, pkgs, lib, ... }:

with lib;

let
  dataDir = "/var/lib/mautrix-facebook";
  cfg = config.services.mautrix-facebook;
  # TODO: switch to configGen.json once RFC42 is implemented
  serviceSettings = pkgs.writeText "mautrix-facebook-settings.json" (builtins.toJSON cfg.settings);

in {
  options = {
    services.mautrix-facebook = {
      enable = mkEnableOption "Mautrix-Facebook, a Matrix-Facebook Messenger puppeting bridge";

      # TODO: switch to types.config.json as prescribed by RFC42 once it's implemented
      settings = mkOption rec {
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

          # log to console/systemd instead of file
          logging = {
            version = 1;

            formatters.precise.format = "[%(levelname)s@%(name)s] %(message)s";

            handlers.console = {
              class = "logging.StreamHandler";
              formatter = "precise";
            };

            loggers = {
              mau.level = "INFO";
              telethon.level = "INFO";
              aiohttp.level = "WARNING"; # https://github.com/tulir/mautrix-telegram/issues/351
            };

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
          <link xlink:href="https://github.com/tulir/mautrix-telegram/blob/master/example-config.yaml">
          example-config.yaml</link>.
          </para>

          <para>
          Secret tokens should be specified using <option>environmentFile</option>
          instead of this world-readable attribute set.
        '';
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          File containing environment variables to be passed to the mautrix-telegram service,
          in which secret tokens can be specified securely by defining values for
          <literal>MAUTRIX_TELEGRAM_APPSERVICE_AS_TOKEN</literal>,
          <literal>MAUTRIX_TELEGRAM_APPSERVICE_HS_TOKEN</literal>,
          <literal>MAUTRIX_TELEGRAM_TELEGRAM_API_ID</literal>,
          <literal>MAUTRIX_TELEGRAM_TELEGRAM_API_HASH</literal> and optionally
          <literal>MAUTRIX_TELEGRAM_TELEGRAM_BOT_TOKEN</literal>.
        '';
      };

      serviceDependencies = mkOption {
        type = with types; listOf str;
        default = [ ];
        example = literalExample ''
          [ "matrix-synapse.service" ]
        '';
        description = ''
          List of Systemd services to require and wait for when starting the application service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
#    # default minimal configuration
#    services.mautrix-telegram.settings = {
#      appservice = rec {
#        database = mkDefault "sqlite:///${dataDir}/mautrix-telegram.db";
#        hostname = mkDefault "0.0.0.0";
#        port = mkDefault 8080;
#        address = mkDefault "http://localhost:${toString port}";
#      };
#
#      bridge = {
#        permissions."*" = mkDefault "relaybot";
#        relaybot.whitelist = mkDefault [ ];
#      };
#
#      # log to console/systemd instead of file
#      logging = {
#        version = 1;
#
#        formatters.precise.format = "[%(levelname)s@%(name)s] %(message)s";
#
#        handlers.console = {
#          class = "logging.StreamHandler";
#          formatter = "precise";
#        };
#
#        loggers = {
#          mau.level = mkDefault "INFO";
#          telethon.level = mkDefault "INFO";
#          aiohttp.level = mkDefault "WARNING"; # https://github.com/tulir/mautrix-telegram/issues/351
#        };
#
#        root = {
#          level = mkDefault "INFO";
#          handlers = [ "console" ];
#        };
#      };
#    };

    systemd.services.mautrix-facebook = {
      description = "Mautrix-Facebook, a Matrix-Facebook Messenger puppeting bridge.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      preStart = ''
        # run automatic database init and migration scripts
        ${pkgs.mautrix-facebook.alembic}/bin/alembic -x config='${serviceSettings}' upgrade head
        cp ${serviceSettings} ${dataDir}/mautrix-facebook.conf
        chmod 777 ${dataDir}/mautrix-facebook.conf
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        DynamicUser = true;

        #ProtectSystem = "strict";
        #ProtectHome = true;
        #ProtectKernelTunables = true;
        #ProtectKernelModules = true;
        #ProtectControlGroups = true;

        ProtectHome = false;
        ProtectKernelTunables = false;
        ProtectKernelModules = false;
        ProtectControlGroups = false;

        #PrivateTmp = true;
        PrivateTmp = false;
        StateDirectory = baseNameOf dataDir;
        
        EnvironmentFile = cfg.environmentFile;
        WorkingDirectory = pkgs.mautrix-facebook; # necessary for the database migration scripts to be found

        #ExecStart = ''
          #${pkgs.mautrix-facebook}/bin/mautrix-facebook --config='${dataDir}/mautrix-facebook.conf'
        #'';
        ExecStart = ''
          ${pkgs.mautrix-facebook}/bin/mautrix-facebook --config='/etc/secrets/mautrix-facebook.conf'
        '';
      };
    };
  };

  meta.maintainers = with maintainers; [ pacien vskilet ];
}
