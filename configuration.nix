# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      /home/nathan/vim_config/basic-shared.nix
      /home/nathan/vim_config/trackpad-shared.nix
    ];

  # set DPI
  #services.xserver.monitorSection = ''
      #DisplaySize 195 345
  #'';
  # Use the systemd-boot EFI boot loader.
  boot = {
  	  initrd.luks.devices = [{
	  	name = "cryptVG";
		device = "/dev/disk/by-uuid/1d8f8207-8340-45b9-9046-ce9aa9f88062";
		preLVM = true;
	  }];
	  loader = {
		  efi.canTouchEfiVariables = true;
		  systemd-boot.enable = true;
	  };
  };

  networking.hostName = "nixos-nathan"; # Define your hostname.
}
