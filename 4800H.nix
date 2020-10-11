# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware = {
	  #pulseaudio.enable = true;
	  #pulseaudio.support32Bit = true;

      #bluetooth.enable = true;

      # Steam stuff
      opengl.driSupport32Bit = true;
  };

  networking.hostName = "nixos_4800H"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;

  networking.wireguard.interfaces = {
    wg0 = {
        ips = [ "10.100.0.7/24" ];
        privateKeyFile = "/home/nathan/wireguard-keys/private";
        peers = [
            {
                publicKey = "WXx7XXJzerPJBPMTvZ454iQhx5Q5bFvBgF6NsPPX9nk=";
                #allowedIPs = [ "0.0.0.0/0" ];
                ## Then sudo ip route add 104.238.179.164 via 10.0.0.1 dev enp30s0
                allowedIPs = [ "10.100.0.0/24" ];
                endpoint = "104.238.179.164:51820";
                persistentKeepalive = 25;
            }
        ];
    };
  };

  services.nginx = {
       enable = true;
       recommendedGzipSettings = true;
       recommendedOptimisation = true;
       #recommendedProxySettings = true;
       recommendedTlsSettings = true;
       virtualHosts."10.100.0.7" = {
            root = "/var/www/share_web";
       };
   };


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "America/New_York";


  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock # lockscreen
      swayidle
      xwayland # for legacy apps
      waybar # status bar
      mako # notification daemon
      kanshi # autorandr
      dmenu # is this right?
      i3status
    ];
  };

 environment = {
   etc = {
     # Put config files in /etc. Note that you also can put these in ~/.config, but then you can't manage them with Nix
     "sway/config".source = /home/nathan/vim_config/sway_config;
     #"xdg/waybar/config".source = ./dotfiles/waybar/config;
     #"xdg/waybar/style.css".source = ./dotfiles/waybar/style.css;
   };
 };

  # Here we but a shell script into path, which lets us start sway.service (after importing the environment of the login
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget vim tmux git htop w3m wireguard

    gcc gnumake python3 python
    #firefox
    firefox-wayland
    chromium
    pavucontrol sakura
    pciutils light iftop
    libreoffice vlc xclip file unzip zip ripgrep evince feh killall
    openshot-qt
    niv

    steam bluejeans-gui discord

    (
      pkgs.writeTextFile {
        name = "startsway";
        destination = "/bin/startsway";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash

          # first import environment variables from the login manager
          systemctl --user import-environment
          # then start the service
          exec systemctl --user start sway.service
        '';
      }
    )
  ];
  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.user.services.sway = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    # We explicitly unset PATH here, as we want it to be set by
    # systemctl --user import-environment in startsway
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
 #services.redshift = {
 #  enable = true;
 #  # Redshift with wayland support isn't present in nixos-19.09 atm. You have to cherry-pick the commit from https://gi
 #  package = pkgs.redshift-wlr;
 #};

  programs.waybar.enable = true;

  systemd.user.services.kanshi = {
    description = "Kanshi output autoconfig ";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      # kanshi doesn't have an option to specifiy config file yet, so it looks
      # at .config/kanshi/config
      ExecStart = ''
        ${pkgs.kanshi}/bin/kanshi
      '';
      RestartSec = 5;
      Restart = "always";
    };
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.syncthing = {
    enable = true;
    user = "nathan";
    dataDir = "/home/nathan/syncthing_stuff";
    configDir = "/home/nathan/syncthing_stuff/.config/syncthing";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  #services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  #services.xserver.windowManager.i3.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nathan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

