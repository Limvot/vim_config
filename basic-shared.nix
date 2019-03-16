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
    #gimp
    nmap
    iw
    rfkill
    #evince
    #i3lock
    #psmisc
    htop
    #pv
    networkmanagerapplet
    python3
    python
    #clisp
    cryptsetup
    wget
    vim
    ninja
    git
    gdb
    valgrind
    #cowsay
    tmux
    #neovim
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
    #emscripten
    #sway
    #dmenu-wayland
    #xwayland
    #steam
    st
    lsof
    libreoffice
    iftop
    vlc
    cloc
    clang
    lm_sensors
    #dmidecode
    xclip
    #(pkgs.st.overrideAttrs (attrs: { configFile = builtins.readFile /home/nathan/vim_config/config.h; }))
    #openvpn
    #synergy
    file
    #kakoune
    xorg.xdpyinfo
    bc
    kcachegrind
    unzip
    android-studio
    #jdk
    zip
    #zsh
    #wireshark-gtk
    #mitmproxy
    ripgrep
    #openshot-qt
    termite
    audacity
    evince
    #androidenv.platformTools
    libinput
    feh
    #imagemagick7Big
    killall
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  #networking.wireless.enable = true;    # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  #services.xserver.displayManager.sessionCommands = "${pkgs.networkmanagerapplet}/bin/nm-applet &";

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  #services.xserver.displayManager.kdm.enable = true;
  #services.xserver.desktopManager.kde.enable = true;
  #services.xserver.displayManager.sddm.enable = true;

  #services.xserver.displayManager.slim.enable = true;
  #services.xserver.windowManager.i3.enable = true;

  nixpkgs.config = {
    allowUnfree = true;

    #st.conf = "/*entire config file...*/";
    #chromium.enableWideVine = true;
    #firefox.enableAdobeFlash = true;
    #packageOverrides = super:
      #let self = super.pkgs;
      #my_meson = super.meson.overrideAttrs (oldAttrs: rec {
        #version = "0.48.1";
          #src = pkgs.python3Packages.fetchPypi {
            #pname = "meson";
            #version = "0.48.1";
            #sha256 = "0ivlascy671bpincd76dhz0lpi78vcz6hpgh87z66d08chnkx2gg";
        #};
        #patches = [(builtins.head oldAttrs.patches)] ++ [(builtins.tail (builtins.tail oldAttrs.patches))] ++ [/home/nathan/vim_config/gir-git.patch];
      #});
    #in {
      #wlroots = super.wlroots.overrideAttrs (oldAttrs: rec {
        #name = "wlroots-0.2";
        #version = "0.2";
        #src = pkgs.fetchFromGitHub {
          #owner = "swaywm";
          #repo = "wlroots";
          #rev = "0.2";
          #sha256 = "0gfxawjlb736xl90zfv3n6zzf5n1cacgzflqi1zq1wn7wd3j6ppv";
        #};
        #nativeBuildInputs = [ my_meson ] ++ (builtins.tail oldAttrs.nativeBuildInputs);
        #mesonFlags = [
          #"-Dlibcap=enabled"
          #"-Dlogind=enabled"
          #"-Dxwayland=enabled"
        #];
        #meta.broken = false;
      #});
      #sway = super.sway.overrideAttrs (oldAttrs: rec {
        #name = "sway-1.0-beta.2";
        #version = "1.0-beta.2";
        #src = pkgs.fetchFromGitHub {
          #owner = "swaywm";
          #repo = "sway";
          #rev = "1.0-beta.2";
          #sha256 = "0f9rniwizbc3vzxdy6rc47749p6gczfbgfdy4r458134rbl551hw";
        #};
        ##nativeBuildInputs = [ pkgs.pkgconfig pkgs.meson ];
        #nativeBuildInputs = [ pkgs.pkgconfig my_meson pkgs.git pkgs.ninja ];
        #buildInputs = oldAttrs.buildInputs ++ [pkgs.wlroots pkgs.wayland-protocols];
        #cmakeFlags = "";
      #});
    #};
  };

  programs.sway.enable = true;
  # DONE IN SWAY CONFIG NOW
  #programs.sway.extraSessionCommands = ''
    #export XKB_DEFAULT_OPTIONS=ctrl:nocaps
  #'';


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "unstable";
  #system.nixos.stateVersion = "unstable";
  users.groups.plugdev = {};
  users.groups.adbusers = {};
  users.extraUsers.nathan = {
	  name = "nathan";
	  group = "users";
	  extraGroups = [ "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal" "networkmanager" "sway" "plugdev" "adbusers"];
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

}
