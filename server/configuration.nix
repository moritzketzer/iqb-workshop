{ pkgs, modulesPath, ... }:

let
  workshopNames = [
    "nightingale"
    "athey"
    "hill"
    "stuart"
    "petersen"
    "maathuis"
    "didelez"
    "uhler"
    "perkovic"
    "schnitzer"
    "pearl"
    "rubin"
    "wright"
    "neyman"
    "hernan"
    "robins"
    "imbens"
    "haavelmo"
    "spirtes"
    "dawid"
  ];

  workshopUsers = builtins.listToAttrs (
    builtins.map (name: {
      inherit name;
      value = {
        isNormalUser = true;
        initialPassword = "changeme";
        extraGroups = [ "gallery" ];
      };
    }) workshopNames
  );

  workshopFiles = ../exercises;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # C.UTF-8 is a glibc built-in locale that doesn't need LOCALE_ARCHIVE.
  # en_US.UTF-8 fails in RStudio rsessions due to glibc version mismatch
  # between R binary and locale-archive (known unresolved NixOS issue).
  i18n.defaultLocale = "C.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  networking.hostName = "rstudio-workshop";
  networking.firewall.allowedTCPPorts = [
    22
    80
    8787
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  systemd.services.rstudio-server.after = [ "network-online.target" ];
  systemd.services.rstudio-server.wants = [ "network-online.target" ];

  services.rstudio-server = {
    enable = true;
    listenAddr = "0.0.0.0";
    package = pkgs.rstudioServerWrapper.override {
      packages = with pkgs.rPackages; [
        tidyverse
        broom
        quartets
        lavaan
        dagitty
        jsonlite
        lme4
        brms
      ];
    };
    rserverExtraConfig = ''
      auth-stay-signed-in-days=30
    '';
    rsessionExtraConfig = ''
      session-timeout-minutes=0
    '';
  };

  environment.systemPackages = with pkgs; [
    python3
    gcc
    gnumake
  ];

  system.activationScripts.gallery-dir.text = ''
    mkdir -p /var/lib/gallery
    chgrp gallery /var/lib/gallery
    chmod 1775 /var/lib/gallery
  '';

  system.activationScripts.workshop-files.text = ''
    for user in ${builtins.concatStringsSep " " workshopNames}; do
      home="/home/$user"
      if [ -d "$home" ]; then
        ${pkgs.rsync}/bin/rsync -a --chmod=F644 ${workshopFiles}/ "$home/"
        echo 'LANG=C.UTF-8' > "$home/.Renviron"
        chown -R "$user:users" "$home"
      fi
    done
  '';

  systemd.services.claim-server = {
    description = "Workshop login claim server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 /opt/claim/claim-server.py";
      Restart = "on-failure";
      StateDirectory = "claim";
      SupplementaryGroups = [ "gallery" ];
    };
  };

  users.groups.gallery = { };

  users.mutableUsers = true;

  users.users = workshopUsers // {
    root.openssh.authorizedKeys.keys = [
      "ssh-rsa YOUR_KEY_HERE"
    ];
    moritz = {
      isNormalUser = true;
      initialPassword = "changeme";
      extraGroups = [
        "wheel"
        "gallery"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.11";
}
