{pkgs, ...}: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true;
      addons = with pkgs; [
        fcitx5-mozc
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "gb";
            DefaultIM = "keyboard-gb";
          };
          "Groups/0/Items/0".Name = "keyboard-gb";
          "Groups/0/Items/1".Name = "mozc";
        };
        globalOptions = {
          "Hotkey/TriggerKeys"."0" = "Super+space";
        };
      };
    };
  };
}
