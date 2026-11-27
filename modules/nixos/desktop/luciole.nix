{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.luciole;
in {
  imports = [inputs.luciole.nixosModules.default];

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true;
    services.avahi.enable = true;

    xdg.portal = {
      extraPortals = [
        inputs.luciole.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.xdg-desktop-portal-gtk
      ];

      config.common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["luciole" "gtk"];
      };
    };
  };
}
