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
    maven
    nodejs
    ripgrep
    file
    mautrix-telegram
    mautrix-facebook
  ];

  # List services that you want to enable:

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

  networking.firewall.enable = false;

  swapDevices = [{
    device = "/var/swapfile";
    size = 4096;
  }];

 security.acme.certs."kraken-lang.org" = {
   webroot = "/var/www/challenges";
   email = "miloignis@gmail.com";
   postRun = "systemctl restart nginx.service";
 };
 security.acme.certs."www.kraken-lang.org" = {
   webroot = "/var/www/challenges";
   email = "miloignis@gmail.com";
   postRun = "systemctl restart nginx.service";
 };
 security.acme.certs."play.kraken-lang.org" = {
   webroot = "/var/www/challenges";
   email = "miloignis@gmail.com";
   postRun = "systemctl restart nginx.service";
 };
 security.acme.certs."room409.xyz" = {
   webroot = "/var/www/challenges";
   email = "miloignis@gmail.com";
   postRun = ''systemctl restart nginx.service && cp ${config.security.acme.certs."room409.xyz".directory}/fullchain.pem /var/lib/matrix-synapse/ && cp ${config.security.acme.certs."room409.xyz".directory}/key.pem /var/lib/matrix-synapse && chown -R :matrix-synapse /var/lib/matrix-synapse && chmod -R g+rX /var/lib/matrix-synapse'';
   #postRun = "systemctl restart nginx.service";
 };
 security.acme.certs."riot.room409.xyz" = {
   webroot = "/var/www/challenges";
   email = "miloignis@gmail.com";
   postRun = "systemctl restart nginx.service";
 };

  services.nginx = {
    enable = true;
    httpConfig = ''

      gzip on;
      gzip_min_length 1024;
      gzip_proxied any;
      gzip_vary on;
      gzip_types text/plain text/xml text/css application/x-javascript application/javascript application/json;

      server {
        listen *:80;
        listen [::]:80;
        server_name _;
        location /.well-known/acme-challenge { root /var/www/challenges; }
      }
      server {
        server_name kraken-lang.org;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.certs."kraken-lang.org".directory}/fullchain.pem;
        ssl_certificate_key ${config.security.acme.certs."kraken-lang.org".directory}/key.pem;
        root /var/www/kraken-by-example/stage/_book;
      }
      server {
        server_name www.kraken-lang.org;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.certs."www.kraken-lang.org".directory}/fullchain.pem;
        ssl_certificate_key ${config.security.acme.certs."www.kraken-lang.org".directory}/key.pem;
        root /var/www/kraken-by-example/stage/_book;
      }
      server {
        server_name play.kraken-lang.org;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location / { proxy_pass http://127.0.0.1:8001; }
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.certs."play.kraken-lang.org".directory}/fullchain.pem;
        ssl_certificate_key ${config.security.acme.certs."play.kraken-lang.org".directory}/key.pem;
      }
      server {
        client_max_body_size 10m;
        server_name room409.xyz;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        location /.well-known/matrix/server {
            add_header Content-Type application/json;
            return 200 '{ "m.server": "room409.xyz:8448" }';
        }
        location /.well-known/matrix/client {
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '{ "m.homeserver": {"base_url": "https://room409.xyz"}, "m.identity_server":  { "base_url": "https://vector.im"} }';
        }
        location /_matrix {
            proxy_pass http://localhost:8008;
            proxy_set_header X-Forwarded-For $remote_addr;
        }
        ssl_certificate ${config.security.acme.certs."room409.xyz".directory}/fullchain.pem;
        ssl_certificate_key ${config.security.acme.certs."room409.xyz".directory}/key.pem;
        root /var/www/room409.xyz;
      }
      server {
        client_max_body_size 10m;
        server_name riot.room409.xyz;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.certs."riot.room409.xyz".directory}/fullchain.pem;
        ssl_certificate_key ${config.security.acme.certs."riot.room409.xyz".directory}/key.pem;
        root ${pkgs.riot-web.override { conf = ''{"default_server_name":"room409.xyz"}''; }};
      }
    '';
  };

  services.matrix-synapse = {
     enable = true;
     no_tls = false;
     tls_certificate_path = "/var/lib/matrix-synapse/fullchain.pem";
     tls_private_key_path = "/var/lib/matrix-synapse/key.pem";
     #tls_certificate_path = ''${config.security.acme.certs."room409.xyz".directory}/fullchain.pem'';
     #tls_private_key_path = ''${config.security.acme.certs."room409.xyz".directory}/key.pem'';
     tls_dh_params_path = null;
     server_name = "room409.xyz";
     web_client = true;
     public_baseurl = "https://room409.xyz/";
     listeners = [
         {
             port = 8448;
             bind_address = "::";
             type = "http";
             tls = true;
             x_forwarded = false;
             resources = [
                 { names = ["federation"]; compress = false; }
             ];
         }
         {
             port = 8008;
             bind_address = "::";
             type = "http";
             tls = false;
             x_forwarded = true;
             resources = [
                 { names = ["client" "webclient"]; compress = true; }
             ];
         }
     ];
     verbose = "0";
     database_type = "sqlite3";
     url_preview_enabled = true;
     enable_registration = true;
     registration_shared_secret = null;
     enable_metrics = true;
     report_stats = true;
     allow_guest_access = true;
     trusted_third_party_id_servers = [ "vector.im" ];
     app_service_config_files = [
        "/etc/secrets/mautrix-telegram-registration.json"
        "/etc/secrets/mautrix-facebook-registration.json"
     ];
  };
  nixpkgs.config = {
    #mautrix = pkgs.callPackage /home/nathan/vim_config/mautrix.nix { };
    #fbchat-asyncio = pkgs.callPackage /home/nathan/vim_config/fbchat-asyncio.nix { };
    #mautrix-facebook = pkgs.callPackage /home/nathan/vim_config/mautrix-facebook.nix { inherit mautrix fbchat-asyncio; };
   packageOverrides = super:
    let self = super.pkgs;
    mautrix = pkgs.callPackage /home/nathan/vim_config/mautrix.nix { };
    fbchat-asyncio = pkgs.callPackage /home/nathan/vim_config/fbchat-asyncio.nix { };
    #mautrix = super.python3.pkgs.buildPythonPackage rec {
      #pname = "mautrix";
      #version = "git-master";
     #src = super.fetchgit {
      #url = "https://github.com/tulir/mautrix-python";
      #rev = "3845a707fa17006c894a093387a912e00187a335";
      #sha256 = "0d2nw9vk4xx3gcpjcc6qkm5ynlq7d602lqzsx3fn8405msfx2hv0";
     #};
     #propagatedBuildInputs = [ super.python3.pkgs.aiohttp super.python3.pkgs.attrs ];
    #};
   in {
    mautrix-facebook = pkgs.callPackage /home/nathan/vim_config/mautrix-facebook.nix { inherit mautrix fbchat-asyncio; };
    #mautrix-telegram = super.mautrix-telegram.overrideAttrs (oldAttrs: rec {
     #version = "git-master";
     #src = super.fetchgit {
      #url = "https://github.com/tulir/mautrix-telegram";
      #rev = "6c312efc9ad3340691c360c7ff3445cdeb025edc";
      #sha256 = "1nr0rzw7cakvm9xr84jp73qpyd4shk9bf4lc38vr87wpvadqyhrn";
     #};
     #propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ mautrix ]; });
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
          "@miloignis:room409.xyz" = "admin";
        };
      };
    };
  };
  services.mautrix-facebook = {
    enable = true;
    environmentFile = /etc/secrets/mautrix-facebook.env; # file containing the appservice and telegram tokens
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
          "@miloignis:room409.xyz" = "admin";
        };
      };
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.09";

}
