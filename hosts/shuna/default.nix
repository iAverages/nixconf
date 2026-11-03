{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.abembed.nixosModules.hosted-provider
  ];

  dan = true;
  boot.loader.grub.devices = ["/dev/sda"];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/dc3f3fca-9fbd-4c1a-abcb-a91bd9bcad82";
    fsType = "ext4";
  };

  networking = {
    hostName = "shuna";
    useDHCP = true;
    nameservers = ["1.1.1.1" "1.0.0.1"];
    interfaces.ens3.ipv6.addresses = [
      {
        address = "2001:41d0:801:2000::7c19";
        prefixLength = 64;
      }
    ];
    interfaces.lo.ipv6.routes = [
      {
        address = "2001:41d0:e00:7000::";
        prefixLength = 56;
        type = "local";
      }
    ];
    defaultGateway6 = {
      address = "2001:41d0:801:2000::1";
      interface = "ens3";
    };
    firewall = {
      trustedInterfaces = lib.mkForce ["lo"];
      allowedUDPPorts = lib.mkForce [];
      interfaces = {
        ens3.allowedTCPPorts = [50300];
        tailscale0.allowedTCPPorts = [22 5030];
      };
    };
  };

  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUqxOzmjOS0TmJkoV9SQtzo2iOt1JzFJsg84KhPshGb kirsi@danielraybone.com''];
  system.stateVersion = "23.11";

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
    };

    config-git-deploy.enable = true;

    hosted-provider = {
      enable = true;
      environmentFile = config.sops.templates."hosted-provider.env".path;
    };

    cloudflared = {
      enable = true;
      tunnels."14952ecc-1612-4cb7-8df7-bb98d6b1b32b" = {
        credentialsFile = config.sops.secrets.cloudflared-shuna.path;
        ingress."shuna.abembed.com" = "http://${config.services.hosted-provider.listen}";
        default = "http_status:404";
      };
    };
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
    };
    slskd = {
      enable = true;
      openFirewall = false;
      environmentFile = pkgs.writeText "slskd.env" "SLSKD_NO_VERSION_CHECK=true\n";
      settings = {
        directories = {
          downloads = "/var/lib/slskd/downloads";
          incomplete = "/var/lib/slskd/incomplete";
        };
        shares.directories = [];
        web.ip_address = "0.0.0.0";
      };
    };
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.sshKeyPaths = ["/root/.ssh/shuna_ed25519"];
    secrets = {
      tailscaleAuthKey = {};
      danPassword = {};
      "slskd/username" = {};
      "slskd/password" = {};
      "slskd/api_key" = {};
      "slskd/relay_secret" = {};
      "slskd/web_password" = {};
      hosted-provider-token = {};
      cloudflared-shuna = {};
    };
    templates."hosted-provider.env" = {
      content = "HOSTED_PROVIDER_TOKEN=${config.sops.placeholder.hosted-provider-token}\n";
      restartUnits = ["hosted-provider.service"];
    };
    templates."slskd-controller.yml" = {
      owner = "slskd";
      content = ''
        instance_name: shuna
        relay:
          enabled: true
          mode: controller
          agents:
            kurumi:
              instance_name: kurumi
              secret: ${config.sops.placeholder."slskd/relay_secret"}
              cidr: 100.64.0.0/10
        directories:
          downloads: /var/lib/slskd/downloads
          incomplete: /var/lib/slskd/incomplete
        shares:
          directories: []
        transfers:
          download:
            speed_limit: 6103
          upload:
            speed_limit: 2441
        retention:
          files:
            complete: 60
        web:
          ip_address: 0.0.0.0
          https:
            disabled: true
          authentication:
            username: dan
            password: ${config.sops.placeholder."slskd/web_password"}
            api_keys:
              kurumi:
                key: ${config.sops.placeholder."slskd/api_key"}
                role: readwrite
                cidr: 100.64.0.0/10
        soulseek:
          username: ${config.sops.placeholder."slskd/username"}
          password: ${config.sops.placeholder."slskd/password"}
          listen_ip_address: 0.0.0.0
          listen_port: 50300
      '';
    };
  };

  systemd.services.slskd.serviceConfig.ExecStart = lib.mkForce ''
    ${lib.getExe config.services.slskd.package} --app-dir /var/lib/slskd --config ${config.sops.templates."slskd-controller.yml".path}
  '';
  systemd.tmpfiles.rules = [
    "d /var/lib/slskd/downloads 0750 slskd slskd -"
    "d /var/lib/slskd/incomplete 0750 slskd slskd -"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
