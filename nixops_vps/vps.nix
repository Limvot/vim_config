{
    network.description = "Simple VPS deployment";
    network.enableRollback = true;

    vps = {config, pkgs, ... }: {
        deployment.targetHost = "room409.xyz";

        nix.gc.automatic = true;
        imports = [
            ./hardware-configuration.nix
            #./dendrite.nix
            ./mautrix-facebook-service.nix
        ];

        nixpkgs.config = {
            packageOverrides = super:
            { 
                mautrix-facebook = pkgs.callPackage ./mautrix-facebook.nix { };
            };
        };

        # Use the GRUB 2 boot loader.
        boot.loader.grub.enable = true;
        boot.loader.grub.version = 2;
        boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

        swapDevices = [{
          device = "/var/swapfile";
          size = 4096;
        }];

        networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
        # WireGuard
        networking.nat.enable = true;
        networking.nat.externalInterface = "ens3";
        networking.nat.internalInterfaces = ["wg0"];
        networking.firewall = {
            #allowedTCPPorts = [ 22 80 443 3478 3479 ];
            #allowedUDPPorts = [ 22 80 443 5349 5350 51820 ];
            allowedTCPPorts = [ 22 80 443 ];
            allowedUDPPorts = [ 22 80 443 51820 ];
            extraCommands = ''
                iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
            '';
        };
        networking.wireguard.interfaces = {
            wg0 = {
              ips = [ "10.100.0.1/24" ];
              listenPort = 51820;
              privateKeyFile = "/home/nathan/wireguard-keys/private";
              peers = [
                {
                  publicKey = "FqJShA/dz8Jj73tSyjzcsyASOEv6uAFs6e/vRol8ygc=";
                  allowedIPs = [ "10.100.0.2/32" ];
                }
                {
                  publicKey = "aAgay9pn/3Vj1nHC4GFY2vysW12n5VFyuUcB5+0pux8=";
                  allowedIPs = [ "10.100.0.3/32" ];
                }
                {
                  publicKey = "u55Jkd4dRdBqnhliIP9lwsxIYow2Tr8BhPPhKFtaVAc=";
                  allowedIPs = [ "10.100.0.4/32" ];
                }
                {
                  publicKey = "J/BWU33DYMkoWOKSZWrtAqWciep03YuicaDMD5MCqWg=";
                  allowedIPs = [ "10.100.0.5/32" ];
                }
                {
                  publicKey = "y2gAEhg1vwK1+nka2Knu7NyOk8HaaY4w18nD6EMyLSk=";
                  allowedIPs = [ "10.100.0.6/32" ];
                }
                {
                  publicKey = "SoaYh1mb6DYd6TuOEFl4lRCZUBTPQfOnWHIOmtkgxxM=";
                  allowedIPs = [ "10.100.0.7/32" ];
                }
              ];
            };
        };

        services.openssh.enable = true;
        services.openssh.permitRootLogin = "prohibit-password";


        # TODO: Move to PostgreSQL eventually
        #services.dendrite = {
        #    enable = true;
        #    configOptions = {
        #        global.server_name = "dendrite.room409.xyz";
        #    };
        #};

        services.mautrix-telegram = {
            enable = true;
            settings = {
                homeserver = {
                    address = "https://synapse.room409.xyz";
                    domain = "synapse.room409.xyz";
                };
                bridge.permissions = {
                    "synapse.room409.xyz" = "full";
                    "@miloignis:synapse.room409.xyz" = "admin";
                };
            };
            environmentFile = /var/lib/mautrix-telegram/secrets;
        };

        services.mautrix-facebook = {
            enable = true;
            settings = {
                homeserver = {
                    address = "https://synapse.room409.xyz";
                    domain = "synapse.room409.xyz";
                };
                bridge.permissions = {
                    "synapse.room409.xyz" = "full";
                    "@miloignis:synapse.room409.xyz" = "admin";
                };
            };
        };

        services.matrix-synapse = {
            enable = true;

            server_name = "synapse.room409.xyz";
            public_baseurl = "https://synapse.room409.xyz/";

            enable_registration = true;
            #registration_shared_secret = null;
            verbose = "0";
            database_type = "psycopg2";
            url_preview_enabled = true;
            report_stats = true;
            max_upload_size = "100M";

            listeners = [
                {
                    port = 8008;
                    tls = false;
                    resources = [
                        {
                            compress = true;
                            names = ["client" "federation"];
                        }
                    ];
                }
            ];
            app_service_config_files = [
                "/var/lib/matrix-synapse/telegram-registration.yaml"
                "/var/lib/matrix-synapse/facebook-registration.yaml"
            ];
            extraConfig = ''
                experimental_features: { spaces_enabled: true }
            '';
        };

        services.postgresql = {
            enable = true;
            # postgresql user and db name in the service.matrix-synapse.databse_args setting is default
            initialScript = pkgs.writeText "synapse-init.sql" ''
                CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
                CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
                    TEMPLATE template0
                    LC_COLLATE = "C"
                    LC_CTYPE = "C";
            '';
        };

        security.acme.email = "miloignis@gmail.com";
        security.acme.acceptTerms = true;
        services.nginx = {
            enable = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            #recommendedProxySettings = true;
            recommendedTlsSettings = true;

            virtualHosts."synapse.room409.xyz" = {
                forceSSL = true;
                enableACME = true;
                locations."/.well-known/matrix/server".extraConfig = ''
                    add_header Content-Type application/json;
                    return 200 '{ "m.server": "synapse.room409.xyz:443" }';
                '';
                locations."/.well-known/matrix/client".extraConfig = ''
                    add_header Content-Type application/json;
                    add_header Access-Control-Allow-Origin *;
                    return 200 '{ "m.homeserver": {"base_url": "https://synapse.room409.xyz"}, "m.identity_server":  { "base_url": "https://vector.im"} }';
                '';
                locations."/".proxyPass = "http://localhost:8008";
                locations."/".extraConfig = ''
                    client_max_body_size 100M;
                    proxy_set_header X-Forwarded-For $remote_addr;
                '';
            };

            virtualHosts."element-synapse.room409.xyz" = {
                forceSSL = true;
                enableACME = true;
                root = pkgs.element-web.override {
                    conf = {
                        default_server_name = "synapse.room409.xyz";
                        default_server_config = "";
                    };
                };
            };

            virtualHosts."kraken-lang.org" = {
              forceSSL = true;
              enableACME = true;
              root = "/var/www/kraken-lang.org";
              locations."/k_prime.wasm".extraConfig = ''
                   default_type application/wasm;
              '';
            };
            #virtualHosts."www.kraken-lang.org" = {
            #  forceSSL = true;
            #  enableACME = true;
            #  root = "/var/www/kraken-lang.org";
            #  locations."/k_prime.wasm".extraConfig = ''
            #       default_type application/wasm;
            #  '';
            #};
            virtualHosts."room409.xyz" = {
              forceSSL = true;
              enableACME = true;
              locations."/" = {
                root = pkgs.writeTextDir "index.html" ''<!DOCTYPE html>
                <html lang="en">
                    <head>
                        <meta charset="utf-8">
                        <title>room409.xyz</title>
                        <style>
                            h1, h2 ,h3 { line-height:1.2; }
                            body {
                                max-width: 45em;
                                margin: 1em auto;
                                padding: 0 .62em;
                                font: 1.2em/1.62 sans-serif;
                            }
                        </style>
                    </head>
                    <body>
                        <header><h1>So Mean and Clean</h1></header>
                        <i>It's like a hacker wrote it</i>
                        <br> <br>
                        <b>Keyboard Cowpeople Team:</b> <a href="https://github.com/Limvot/Serif">Serif, a cross platform Matrix client</a>
                        <br> <br>
                        <b>MiloIgnis:</b> <a href="https://kraken-lang.org/">Kraken Programming Language</a>
                    </body>
                </html>
                '';
              };
            };

            #virtualHosts."4800H.room409.xyz" = {
            #  forceSSL = true;
            #  enableACME = true;
            #  locations."/".proxyPass = "http://10.100.0.7:80";
            #};
        };

        services.journald.extraConfig = "SystemMaxUse=50M";

        environment.systemPackages = with pkgs; [
            htop tmux git vim wget unzip file
            iftop ripgrep
            #wireguard
        ];
        
        system.stateVersion = "20.03";
    };
}
