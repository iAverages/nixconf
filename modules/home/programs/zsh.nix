{
  config,
  hostname,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zsh;
  home = config.home.homeDirectory;
  sshKey = "~/.ssh/${hostname}_ed25519";

  diffExcludes =
    ["yarn.lock" "*package-lock.json" "*pnpm-lock.yaml" "*flake.lock" "*build/*" "Cargo.lock"]
    |> map (pattern: "':!${pattern}'")
    |> lib.concatStringsSep " ";

  keybinds = {
    "^p" = "history-search-backward";
    "^n" = "history-search-forward";
  };

  completionStyles = {
    matcher-list = "'m:{a-zA-Z}={A-Za-z}'";
    list-colors = ''"''${(@s.:.)LS_COLORS}"'';
  };
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [zsh-completions eza bat neovim];

    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
      ZVM_VI_EDITOR = "nvim";
      PNPM_HOME = "${home}/.local/share/pnpm";
    };
    home.sessionPath = ["${home}/.local/share/pnpm" "${home}/.cargo/bin"];

    services.ssh-agent.enable = true;
    programs.fzf.enable = true;

    programs.zsh = {
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        path = "${home}/.zsh_history";
        size = 10000;
        append = true;
        ignoreSpace = true;
        ignoreDups = true;
        ignoreAllDups = true;
        saveNoDups = true;
        findNoDups = true;
        share = false;
      };

      # init vi-mode on source so the fzf keybinds loaded after it stick
      localVariables.ZVM_INIT_MODE = "sourcing";
      plugins = [
        {
          name = "zsh-vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      shellAliases = {
        ls = "eza";
        cat = "bat";
        rebuild = "nh os switch";
        rebuild-home = "nh home switch";
        rebuild-all = "rebuild && rebuild-home";
        zsource = "source ~/.zshrc";
        k = "kubectl";
        p = "pnpm";
        g = "git";
        gs = "git status";
        ga = "git add .";
        gp = "git push";
        changed = "git diff -w HEAD --staged -- . ${diffExcludes}";
        changes = "git diff -- . ${diffExcludes}";
      };

      initContent = lib.mkMerge [
        (lib.mkIf config.programs.tmux.enable (lib.mkOrder 200 ''
          if [[ -z $TMUX && -z $HERDR_ENV ]]; then
            tmux attach || tmux new
          fi
        ''))
        (lib.mapAttrsToList (key: widget: "bindkey '${key}' ${widget}") keybinds |> lib.concatLines)
        (lib.mapAttrsToList (style: value: "zstyle ':completion:*' ${style} ${value}") completionStyles |> lib.concatLines)
        "[[ -f ${sshKey} ]] && ! ssh-add -l >/dev/null && ssh-add -q ${sshKey}"
      ];
    };
  };
}
