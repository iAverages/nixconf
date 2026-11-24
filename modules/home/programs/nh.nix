{
  config,
  lib,
  ...
}: let
  cfg = config.programs.nh;
in {
  config = lib.mkIf cfg.enable {
    programs.nh = {
      flake = "${config.home.homeDirectory}/nixconf";
      clean = {
        enable = true;
        extraArgs = "--keep 3 --keep-since 7d --no-direnv";
      };
    };
  };
}
