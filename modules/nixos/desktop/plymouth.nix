{
  config,
  lib,
  ...
}: let
  cfg = config.boot.plymouth;
in {
  config = lib.mkIf cfg.enable {
    boot = {
      plymouth.logo = ./plymouth.png;

      # silent boot
      consoleLogLevel = 3;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
