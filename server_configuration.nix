# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      /etc/nixos/hardware-configuration.nix
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
    cmake
    gcc
    gdb
    gnumake
    htop
    cloc
    tmux
    git
    vim
#    neovim    
    wget
    unzip
    iftop
    openssl
    jdk
    maven
    nodejs
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

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
        #location / {
        #  return 301 https://$host$request_uri;
        #}
      }
      server {
        server_name kraken-lang.org;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.directory}/kraken-lang.org/fullchain.pem;
        ssl_certificate_key ${config.security.acme.directory}/kraken-lang.org/key.pem;
        root /var/www/kraken-by-example/stage/_book;
      }
      server {
        server_name www.kraken-lang.org;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.directory}/www.kraken-lang.org/fullchain.pem;
        ssl_certificate_key ${config.security.acme.directory}/www.kraken-lang.org/key.pem;
        root /var/www/kraken-by-example/stage/_book;
      }
      server {
        server_name play.kraken-lang.org;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location / { proxy_pass http://127.0.0.1:8001; }
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.directory}/play.kraken-lang.org/fullchain.pem;
        ssl_certificate_key ${config.security.acme.directory}/play.kraken-lang.org/key.pem;
      }
      server {
        server_name room409.xyz;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        location /_matrix {
            proxy_pass http://localhost:8008;
            proxy_set_header X-Forwarded-For $remote_addr;
        }
        ssl_certificate ${config.security.acme.directory}/room409.xyz/fullchain.pem;
        ssl_certificate_key ${config.security.acme.directory}/room409.xyz/key.pem;
        root /var/www/room409.xyz;
      }
      server {
        server_name mangagaga.room409.xyz;
        listen 443 ssl;
        listen *:80;
        listen [::]:80;
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.directory}/mangagaga.room409.xyz/fullchain.pem;
        ssl_certificate_key ${config.security.acme.directory}/mangagaga.room409.xyz/key.pem;
        root /var/www/mangagaga.room409.xyz;
        autoindex on;
        types  { application/octet-stream  apk; }
      }
      server {
        server_name alexa.room409.xyz;
        listen 443 ssl;
        location / { proxy_pass https://127.0.0.1:8888; }
        location /.well-known/acme-challenge { root /var/www/challenges; }
        ssl_certificate ${config.security.acme.directory}/alexa.room409.xyz/fullchain.pem;
        ssl_certificate_key ${config.security.acme.directory}/alexa.room409.xyz/key.pem;
      }
    '';
  };

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
   postRun = "systemctl restart nginx.service && cp ${config.security.acme.directory}/room409.xyz/fullchain.pem /var/lib/matrix-synapse/ && cp ${config.security.acme.directory}/room409.xyz/key.pem /var/lib/matrix-synapse && chown -R :matrix-synapse /var/lib/matrix-synapse && chmod -R g+rX /var/lib/matrix-synapse";
 };
 security.acme.certs."mangagaga.room409.xyz" = {
   webroot = "/var/www/challenges";
   email = "miloignis@gmail.com";
   postRun = "systemctl restart nginx.service";
 };
 security.acme.certs."alexa.room409.xyz" = {
   webroot = "/var/www/challenges";
   email = "miloignis@gmail.com";
   postRun = "systemctl restart nginx.service";
 };

 services.matrix-synapse = {
    enable = true;
    no_tls = false;
    tls_certificate_path = "/var/lib/matrix-synapse/fullchain.pem";
    tls_private_key_path = "/var/lib/matrix-synapse/key.pem";
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
    url_preview_enabled = false;
    enable_registration = true;
    registration_shared_secret = null;
    enable_metrics = true;
    report_stats = true;
    allow_guest_access = true;
    trusted_third_party_id_servers = [ "vector.im" ];
    app_service_config_files = [
        "/home/nathan/matrix-puppet-facebook/facebook-registration.yaml"
        "/home/nathan/mautrix-telegram/registration.yaml"
        ];
 };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";

}
