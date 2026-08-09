{
  lib,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "btrfs";
    options = ["subvol=root" "noatime" "compress=zstd"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "btrfs";
    options = ["subvol=home" "noatime" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "btrfs";
    options = ["subvol=nix" "noatime" "compress=zstd"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "btrfs";
    options = ["subvol=swap" "noatime" "compress=none"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 16 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    steam-hardware.enable = true;
  };
}
