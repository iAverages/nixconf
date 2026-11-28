{
  config,
  pkgs,
  ...
}: {
  home = {
    username = "dan";
    homeDirectory = "/home/dan";
    stateVersion = "24.05";
  };

  sops = {
    defaultSopsFile = ../../secrets/personal.yaml;
    age = {
      sshKeyPaths = ["${config.home.homeDirectory}/.ssh/kirsi_ed25519"];
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
    secrets = {
      avrgApiToken = {};
      kirsi-mtls = {
        format = "binary";
        sopsFile = ./secrets/kirsi.p12;
      };
    };
  };

  systemd.user.services.import-mtls-cert = {
    Unit = {
      After = ["sops-nix.service"];
      Requires = ["sops-nix.service"];
    };
    Install.WantedBy = ["default.target"];
    Service = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeShellScript "import-mtls-cert" ''
        dir=$HOME/.pki/nssdb
        mkdir -p "$dir"
        [ -f "$dir/cert9.db" ] || ${pkgs.nss.tools}/bin/certutil -N -d "sql:$dir" --empty-password
        ${pkgs.nss.tools}/bin/pk12util -i ${config.sops.secrets.kirsi-mtls.path} -d "sql:$dir" -W ""
      '');
    };
  };

  systemd.user.services.obs-replay-buffer = {
    Unit = {
      Description = "OBS replay buffer";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${config.programs.obs-studio.finalPackage}/bin/obs --startreplaybuffer --minimize-to-tray";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  desktop.hyprland = {
    enable = true;
    applications = [
      {
        package = "streamcontroller";
        args = ["-b"];
        background = true;
      }
      {
        package = "spotify";
        class = "spotify";
        workspace = 1;
      }
      {
        package = "vesktop";
        class = "vesktop";
        workspace = 1;
        rules.suppress_event = "maximize";
      }
      {
        package = "ghostty";
        class = "com.mitchellh.ghostty";
        workspace = 3;
      }
    ];
    monitors = {
      "HDMI-A-1" = {
        res = "1920x1080";
        hertz = "60";
        pos = "0x0";
        hyprland.workspaces = [1] ++ builtins.genList (i: i + 11) 10;
      };
      "DP-2" = {
        res = "1920x1080";
        hertz = "240";
        pos = "1920x0";
        hyprland.workspaces = builtins.genList (i: i + 3) 8;
      };
      "DP-1" = {
        res = "1920x1080";
        hertz = "60";
        pos = "3840x0";
        transform = 3;
        hyprland.workspaces = [2] ++ builtins.genList (i: i + 21) 9;
      };
    };
  };

  packages = {
    cli.enable = true;
    desktop.enable = true;
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
    jujutsu.enable = true;
    gh.enable = true;
    starship.enable = true;
    direnv.enable = true;
    nh.enable = true;
    cargo.enable = true;
    fastfetch.enable = true;
    opencode.enable = true;
    herdr.enable = true;
    zsh.enable = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    ghostty.enable = true;
    chromium.enable = true;
    vesktop.enable = true;
    obs-studio = {
      enable = true;
      # nvenc needs the nvidia driver
      package = pkgs.obs-studio.override {cudaSupport = true;};
    };
    rofi.enable = true;
    noctalia.enable = true;
    rclone = {
      enable = true;
      remotes.kurumi = {
        config = {
          type = "sftp";
          host = "192.168.1.202";
          user = "root";
          key_file = "${config.home.homeDirectory}/.ssh/kirsi_ed25519";
        };
        mounts."/opt/data" = {
          enable = true;
          mountPoint = "${config.home.homeDirectory}/nas";
          # skip the slow remote df that stalls file managers
          options = {
            disable = "About";
            vfs-cache-max-size = "10G";
          };
        };
      };
    };
  };

  services = {
    mirai.enable = true;
    kdeconnect.enable = true;
    jellyfin-mpv-shim.enable = true;
  };

  gtk.enable = true;
  xdg.mimeApps.enable = true;
  fonts.fontconfig.enable = true;

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="${config.home.homeDirectory}/.nix-profile/bin:$PATH";
  '';
}
