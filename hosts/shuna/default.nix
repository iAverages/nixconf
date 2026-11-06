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
    ./disko.nix
    inputs.abembed.nixosModules.hosted-provider
  ];

  dan = true;
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostName = "shuna";
    useDHCP = false;
    useNetworkd = true;
    nameservers = ["2606:4700:4700::1111" "2606:4700:4700::1001" "1.1.1.1"];
    firewall = {
      trustedInterfaces = lib.mkForce ["lo"];
      allowedTCPPorts = [50300];
      allowedUDPPorts = lib.mkForce [];
      interfaces.tailscale0.allowedTCPPorts = [22 5030];
    };
    wg-quick.interfaces.wg0.configFile = config.sops.secrets."wireguard/conf".path;
  };

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Name = "en*";
      address = ["2a01:4f9:c015:e6ec::1/64"];
      routes = [{Gateway = "fe80::1";}];
      # wg.conf puts its routes in this table, so only sockets bound to wg0 use the tunnel.
      # lives here because networkd removes rules it doesn't manage
      routingPolicyRules = [
        {
          OutgoingInterface = "wg0";
          Table = 51820;
          Priority = 20000;
          Family = "both";
        }
      ];
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = false;
      };
      linkConfig.RequiredForOnline = "routable";
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
      interface = "wg0";
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
      danPassword.neededForUsers = true;
      "slskd/username" = {};
      "slskd/password" = {};
      "slskd/api_key" = {};
      "slskd/relay_secret" = {};
      "slskd/web_password" = {};
      hosted-provider-token = {};
      cloudflared-shuna = {};
      "wireguard/conf" = {
        format = "binary";
        sopsFile = ./secrets/wg.conf;
        restartUnits = ["wg-quick-wg0.service"];
      };
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
