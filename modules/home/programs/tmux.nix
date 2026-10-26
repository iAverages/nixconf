{
  config,
  lib,
  ...
}: let
  cfg = config.programs.tmux;

  colors = {
    background = "#1f2329";
    foreground = "#f8f8f2";
    currentLine = "#44475a";
    green = "#618774";
    red = "#dc6f7a";
    purple = "#7e22ce";
    violet = "#8a38d2";
    muted = "#839496";
  };

  options = with colors; {
    repeat-time = 0;
    # allow kitty image protocol to work correctly
    allow-passthrough = "on";
    set-clipboard = "on";
    renumber-windows = "on";

    mode-style = "fg=${foreground},bg=${background}";
    message-style = "fg=${foreground},bg=${background}";
    message-command-style = "fg=${foreground},bg=${background}";
    pane-border-style = "fg=${background}";
    pane-active-border-style = "fg=${foreground}";

    status = "on";
    status-interval = 1;
    status-justify = "left";
    status-style = "fg=${violet},bg=${background}";
    status-left-length = 100;
    status-left-style = "NONE";
    status-right-style = "NONE";
    status-left = "#[fg=${red}] #{?window_zoomed_flag,↕,} #[bg=${background},fg=${foreground},bold] #S #[fg=${foreground},bg=${purple},bold] #(whoami) #[fg=${green},bg=${background}]";
  };

  windowOptions = with colors; {
    window-status-activity-style = "underscore,fg=${muted},bg=${background}";
    window-status-separator = "";
    window-status-style = "NONE,fg=${muted},bg=${background}";
    window-status-format = "#[fg=${background},bg=${background}]#[default] #I #{b:pane_current_path} #[fg=${background},bg=${background},nobold,nounderscore,noitalics]";
    window-status-current-format = "#[fg=${background},bg=${foreground}]#[fg=${currentLine},bg=${foreground}] #I #[fg=${foreground},bg=${currentLine}] #{b:pane_current_path} #[fg=${currentLine},bg=${background},nobold]";
  };

  appendOptions = {
    terminal-overrides = [",xterm-256color:Tc"];
    update-environment = ["TERM" "TERM_PROGRAM"];
  };

  unbinds = ["%" "\""];

  directions = {
    h = "L";
    j = "D";
    k = "U";
    l = "R";
  };

  bindings =
    [
      {
        key = "r";
        command = "source-file ${config.xdg.configHome}/tmux/tmux.conf \\; display Reloaded!";
      }
      {
        key = "o";
        command = "run-shell 'open #{pane_current_path}'";
      }
      {
        key = "e";
        command = "kill-pane -a";
        repeat = true;
      }
      {
        key = "v";
        command = "split-window -h -c '#{pane_current_path}'";
      }
      {
        key = "s";
        command = "split-window -v -c '#{pane_current_path}'";
      }
      {
        key = "c";
        command = "new-window -c '#{pane_current_path}'";
      }
      {
        key = "C-S-Left";
        command = "swap-window -t -1 \\; previous-window";
        root = true;
      }
      {
        key = "C-S-Right";
        command = "swap-window -t +1 \\; next-window";
        root = true;
      }
      {
        key = "m";
        command = "choose-window -F '#{window_index}: #{window_name}' 'join-pane -h -t %%'";
      }
      {
        key = "M";
        command = "choose-window -F '#{window_index}: #{window_name}' 'join-pane -v -t %%'";
      }
      {
        key = "b";
        command = "break-pane";
      }
    ]
    ++ lib.mapAttrsToList (key: dir: {
      inherit key;
      command = "select-pane -${dir}";
      repeat = true;
    })
    directions
    ++ lib.mapAttrsToList (key: dir: {
      key = "C-${key}";
      command = "resize-pane -${dir} 5";
      repeat = true;
    })
    directions;

  quote = value: "'${toString value}'";

  renderBinding = {
    key,
    command,
    repeat ? false,
    root ? false,
  }:
    lib.concatStringsSep " " (["bind"] ++ lib.optional repeat "-r" ++ lib.optional root "-n" ++ [key command]);
in {
  config = lib.mkIf cfg.enable {
    programs.tmux = {
      terminal = "tmux-256color";
      keyMode = "vi";
      historyLimit = 64096;
      escapeTime = 10;
      baseIndex = 1;
      focusEvents = true;
      clock24 = true;

      extraConfig =
        (options |> lib.mapAttrsToList (name: value: "set -g ${name} ${quote value}"))
        ++ (windowOptions |> lib.mapAttrsToList (name: value: "setw -g ${name} ${quote value}"))
        ++ (appendOptions |> lib.mapAttrsToList (name: map (value: "set -ga ${name} ${quote value}")) |> lib.concatLists)
        ++ (unbinds |> map (key: "unbind ${quote key}"))
        ++ (bindings |> map renderBinding)
        |> lib.concatLines;
    };
  };
}
