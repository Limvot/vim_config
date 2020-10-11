{
    network.description = "Simple VPS deployment";
    network.enableRollback = true;

    vps = {config, pkgs, ... }: {
        deployment.targetHost = "room409.xyz";

        nix.gc.automatic = true;
        imports = [ ./hardware-configuration.nix ];

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
            allowedTCPPorts = [ 22 80 443 8448 2222 ];
            allowedUDPPorts = [ 22 80 443 8448 2222 51820 ];
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

        security.acme.email = "miloignis@gmail.com";
        security.acme.acceptTerms = true;
        services.nginx = {
            enable = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            #recommendedProxySettings = true;
            recommendedTlsSettings = true;

            virtualHosts."kraken-lang.org" = {
              forceSSL = true;
              enableACME = true;
              root = "/var/www/kraken-lang.org";
              locations."/k_prime.wasm".extraConfig = ''
                   default_type application/wasm;
              '';
            };
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
