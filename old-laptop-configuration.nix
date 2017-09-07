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

  # Use the systemd-boot EFI boot loader.
  boot = {
	  loader = {
		  grub.enable = true;
          grub.device = "/dev/sda";
          grub.extraEntries = ''
            menuentry "Windows" {
              chainloader (hd0,1)+1
            }
          '';
	  };
  };

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  networking.hostName = "nixos-old-laptop"; # Define your hostname.
}
