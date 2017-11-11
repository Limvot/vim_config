# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # No boot information shared


  # Hostname not shared

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    #xonotic
    nmap
    iw
    rfkill
    haskellPackages.idris
    evince
    i3lock
    psmisc
    htop
    pv
    networkmanagerapplet
    python3
    python
    clisp
    cryptsetup
    wget
    vim
    ninja
    git
    gdb
    valgrind
    cowsay
    tmux
    neovim
    silver-searcher
    gcc
    gnumake
    cmake
    firefox
    chromium
    google-chrome
    i3status
    dmenu
    pavucontrol
    sakura
    gparted
    emscripten
    #sway
    #dmenu-wayland
    #xwayland
    steam
    st
    lsof
    libreoffice
    iftop
    vlc
    cloc
    clang
    lm_sensors
    dmidecode
    xclip
    #(pkgs.st.overrideAttrs (attrs: { configFile = builtins.readFile /home/nathan/vim_config/config.h; }))
    openvpn
    synergy
    file
    kakoune
    xorg.xdpyinfo
    bc
    kcachegrind
  ];


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  #networking.wireless.enable = true;    # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  services.xserver.displayManager.sessionCommands = "${pkgs.networkmanagerapplet}/bin/nm-applet &";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  #services.xserver.displayManager.kdm.enable = true;
  #services.xserver.desktopManager.kde.enable = true;
  #services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.slim.enable = true;
  services.xserver.windowManager.i3.enable = true;


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "unstable";

  users.extraUsers.nathan = {
	  name = "nathan";
	  group = "users";
	  extraGroups = [ "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal" "networkmanager" ];
	  createHome = true;
	  home = "/home/nathan";
	  shell = "/run/current-system/sw/bin/bash";
  };

  hardware = {
	  pulseaudio.enable = true;
	  pulseaudio.support32Bit = true;

      bluetooth.enable = true;

      # Steam stuff
      opengl.driSupport32Bit = true;
  };
  
  nixpkgs.config = {
    allowUnfree = true;
    
    #st.conf = "/*entire config file...*/";
    #chromium.enableWideVine = true;
    #firefox.enableAdobeFlash = true;
  };

}
