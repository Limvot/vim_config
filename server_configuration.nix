# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      /etc/nixos/hardware-configuration.nix
      /home/nathan/vim_config/mautrix-telegram-service.nix
      /home/nathan/vim_config/mautrix-facebook-service.nix
      /home/nathan/vim_config/mautrix-whatsapp-service.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #networking.firewall.enable = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # WireGuard
  networking.nat.enable = true;
  networking.nat.externalInterface = "ens3";
  networking.nat.internalInterfaces = ["wg0"];
  networking.firewall = {
    #enable = false;
    allowedTCPPorts = [ 22 80 443 8448 2222 ];
    allowedUDPPorts = [ 22 80 443 8448 2222 51820 ];
    #extraCommands = ''
    #  iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE
    #'';
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


  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    gcc
    gdb
    gnumake
    htop
    cloc
    tmux
    git
    vim
    wget
    unzip
    iftop
    openssl
    ripgrep
    file
    mautrix-telegram
    mautrix-whatsapp
    wireguard
    jq
    (python3.withPackages (pythonPackages: with pythonPackages; [ bcrypt pyyaml ]))
  ];

  # List services that you want to enable:

  services.journald.extraConfig = "SystemMaxUse=50M";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";
  services.openssh.gatewayPorts = "yes";

  users.extraUsers.nathan = {
    name = "nathan";
    group = "users";
    createHome = true;
    home = "/home/nathan";
    uid = 1000;
    extraGroups = ["wheel"];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEOY0ZaNSmQihzBkAUTh3QvMtmw+ML+YsEkEVfgUXd6VEKz3KXaDzlKGTDmH4TcmiNr6b0FG6jfOaXHF1Qpfk3SjKoyZAQ6fZAdktm1QfniOJL94j2cdXDdrMFmZ2j9/nZDJBvknHIe7TH1nfNjHWRSBmGteur0kZVJRzbPcyHuHGi3v8YUQQU7kIDdekMDjK6VCBnaV5vO4JtyTzojh1VsUAfnQwDtCUGb81UNJ55565oNA5VTx5iM3y7HrNZCfI9k34ujyJ/Mz3txPv/Zw+YByT7zIsaZfr3AROWw2AGjv9k/HGPqD1QstJxTHQXWP8gectUfaF0Pb7xNTSh3DqD nathan@nathan_laptop" ];
  };


  swapDevices = [{
    device = "/var/swapfile";
    size = 4096;
  }];

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
    virtualHosts."kenny.room409.xyz" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/kenny.room409.xyz";
      locations."/k_prime.wasm".extraConfig = ''
           default_type application/wasm;
      '';
    };
    virtualHosts."4800H.room409.xyz" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://10.100.0.7:80";
    };
    #virtualHosts."chat.room409.xyz" = {
      #forceSSL = true;
      #enableACME = true;
      ##root = let my_ocrcc_chatbox = pkgs.fetchFromGitHub {
        ##owner = "Limvot";
        ##repo = "ocrcc-chatbox";
        ##rev = "2d1ca4927c3727cdc2056549870809a8eb8a83c1";
        ##sha256 = "0r8mw9wa6jsz004hb784bwnlhk3s2vw45ngrrwaxar86zz32xxfr";
      ##}; in pkgs.callPackage "${my_ocrcc_chatbox}/default.nix" {};

      #root = "${pkgs.callPackage /home/nathan/ocrcc-chatbox/default.nix { }}/libexec/safesupport-chatbox/node_modules/safesupport-chatbox/dist";
    #};
    virtualHosts."riot.room409.xyz" = {
      forceSSL = true;
      enableACME = true;
      root = (pkgs.riot-web.overrideAttrs ( oldAttrs:{
        #version = "1.6.0";
        src = pkgs.fetchurl {
          #url = "https://github.com/vector-im/riot-web/releases/download/v${version}/riot-v${version}.tar.gz";
          url = "https://github.com/vector-im/riot-web/releases/download/v1.6.0/riot-v1.6.0.tar.gz";
          sha256 = "1mm4xk69ya1k3gz6jjhc4njx7b3rp157jmrqsxr5i382zs035ff7";
        };
      })).override {
        conf = {
          default_server_name = "room409.xyz";
          default_server_config = "";
        };
      };
    };
    virtualHosts."room409.xyz" = {
      addSSL = true;
      enableACME = true;
      listen = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "[::]"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; ssl = false; }
        { addr = "[::]"; port = 80; ssl = false; }
        { addr = "0.0.0.0"; port = 8448; ssl = true; }
        { addr = "[::]"; port = 8448; ssl = true; }
      ];
      locations."/.well-known/matrix/server".extraConfig = ''
           add_header Content-Type application/json;
           return 200 '{ "m.server": "room409.xyz:443" }';
      '';
      locations."/.well-known/matrix/client".extraConfig = ''
           add_header Content-Type application/json;
           add_header Access-Control-Allow-Origin *;
           return 200 '{ "m.homeserver": {"base_url": "https://room409.xyz"}, "m.identity_server":  { "base_url": "https://vector.im"} }';
      '';
      locations."/".proxyPass = "http://localhost:8008";
      locations."/".extraConfig = ''
           proxy_set_header X-Forwarded-For $remote_addr;
      '';
    };
  };

  services.matrix-synapse = {
     enable = true;
     no_tls = true;
     tls_dh_params_path = null;
     server_name = "room409.xyz";
     public_baseurl = "https://room409.xyz/";
     listeners = [
         {
             port = 8008;
             bind_address = "::";
             type = "http";
             tls = false;
             x_forwarded = true;
             resources = [
                { names = ["federation"]; compress = false; }
                { names = ["client"]; compress = true; }
             ];
         }
     ];
     verbose = "0";
     database_type = "sqlite3";
     url_preview_enabled = true;
     enable_registration = false;
     registration_shared_secret = null;
     enable_metrics = true;
     report_stats = true;
     allow_guest_access = true;
     app_service_config_files = [
        "/etc/secrets/mautrix-telegram-registration.json"
        "/etc/secrets/mautrix-facebook-registration.json"
     ];
  };
  nixpkgs.config = {
   packageOverrides = super:
   { 
     mautrix-facebook = pkgs.callPackage /home/nathan/vim_config/mautrix-facebook.nix { };
   };
  };
  services.mautrix-telegram = {
    enable = true;
    environmentFile = /etc/secrets/mautrix-telegram.env; # file containing the appservice and telegram tokens
    settings = {
      homeserver = {
        address = "https://room409.xyz";
        domain = "room409.xyz";
      };
      appservice = {
        provisioning.enabled = false;
        id = "telegram";
        public = {
          enabled = false;
          prefix = "/public";
          external = "http://domain.tld:8080/public";
        };
      };
      bridge = {
        relaybot.authless_portals = false;
        permissions = {
          "room409.xyz" = "full";
          "@miloignis:room409.xyz" = "admin";
        };
      };
    };
  };
  services.mautrix-facebook = {
    enable = true;
    environmentFile = /etc/secrets/mautrix-facebook.env; # file containing the appservice token
    settings = {
      homeserver = {
        address = "https://room409.xyz";
        domain = "room409.xyz";
      };
      appservice = {
        provisioning.enabled = false;
        id = "facebook";
        public = {
          enabled = false;
          prefix = "/public";
          external = "http://domain.tld:8081/public";
        };
      };
      bridge = {
        relaybot.authless_portals = false;
        permissions = {
          "room409.xyz" = "full";
          "@miloignis:room409.xyz" = "admin";
        };
      };
    };
  };
  services.mautrix-whatsapp = {
    enable = true;
    configOptions = {
          homeserver = {
            address = https://room409.xyz;
            domain = "room409.xyz";
          };
          appservice = {
            address = http://localhost:8082;
            hostname = "0.0.0.0";
            port = 8082;
            database = {
              type = "sqlite3";
              uri = "/var/lib/mautrix-whatsapp/mautrix-whatsapp.db";
            };
            state_store_path = "/var/lib/mautrix-whatsapp/mx-state.json";
            id = "whatsapp";
            bot = {
              username = "whatsappbot";
              displayname = "WhatsApp bridge bot";
              avatar = "mxc://maunium.net/NeXNQarUbrlYBiPCpprYsRqr";
            };
            as_token = "";
            hs_token = "";
          };
          bridge = {
            username_template = "whatsapp_{{.}}";
            displayname_template = "{{if .Notify}}{{.Notify}}{{else}}{{.Jid}}{{end}} (WA)";
            command_prefix = "!wa";
            permissions = {
              "room409.xyz" = "full";
              "@miloignis:room409.xyz" = "admin";
            };
          };
          logging = {
            directory = "/var/lib/mautrix-whatsapp/logs";
            file_name_format = "{{.Date}}-{{.Index}}.log";
            file_date_format = "\"2006-01-02\"";
            file_mode = 384;
            timestamp_format = "Jan _2, 2006 15:04:05";
            print_level = "debug";
          };
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.09";

}
