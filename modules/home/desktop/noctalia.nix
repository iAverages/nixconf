{
  config,
  lib,
  ...
}: let
  cfg = config.programs.noctalia;
  defaultWallpaper = "${cfg.package}/share/noctalia/assets/noctalia-wallpaper.png";
in {
  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      systemd.enable = true;
      settings = {
        bar = {
          order = ["widgets"];
          widgets = {
            center = ["media"];
            end = ["tray" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "date" "clock" "session"];
            margin_edge = 10;
            margin_ends = 10;
            start = ["control-center" "workspaces"];
          };
        };
        control_center = {
          hidden_tabs = ["weather"];
          shortcuts = [
            {
              type = "wifi";
            }
            {
              type = "bluetooth";
            }
            {
              type = "nightlight";
            }
            {
              type = "notification";
            }
            {
              type = "power_profile";
            }
            {
              type = "audio";
            }
          ];
        };
        desktop_widgets = {
          enabled = false;
        };
        dock = {
          enabled = false;
          reserve_space = false;
          smart_auto_hide = true;
        };
        idle = {
          behavior_order = ["lock" "screen-off" "lock-and-suspend"];
          behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = 600.0;
            };
            lock-and-suspend = {
              action = "lock_and_suspend";
              enabled = false;
              timeout = 900.0;
            };
            screen-off = {
              action = "screen_off";
              enabled = false;
              timeout = 660.0;
            };
          };
        };
        lockscreen = {
          wallpaper = "/home/dan/.local/share/mirai/wallpaper";
        };
        lockscreen_widgets = {
          enabled = true;
          schema_version = 2;
          widget_order = ["lockscreen-login-box@DP-2" "lockscreen-login-box@DP-1" "lockscreen-login-box@HDMI-A-1" "lockscreen-widget-0000000000000001" "lockscreen-widget-0000000000000002"];
          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };
          widget = {
            "lockscreen-login-box@DP-1" = {
              box_height = 196.0;
              box_width = 720.0;
              cx = 540.0;
              cy = 1801.0;
              output = "DP-1";
              placement_height = 1920.0;
              placement_width = 1080.0;
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_container";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = true;
                show_unlock_hint = true;
                show_weather = true;
              };
            };
            "lockscreen-login-box@DP-2" = {
              box_height = 150.0;
              box_width = 810.0;
              cx = 960.0;
              cy = 540.0;
              output = "DP-2";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_container";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = false;
                show_unlock_hint = false;
                show_weather = true;
              };
            };
            "lockscreen-login-box@HDMI-A-1" = {
              box_height = 196.0;
              box_width = 720.0;
              cx = 960.0;
              cy = 961.0;
              output = "HDMI-A-1";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_container";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = true;
                show_unlock_hint = true;
                show_weather = true;
              };
            };
            lockscreen-widget-0000000000000001 = {
              box_height = 0.0;
              box_width = 0.0;
              cx = 960.0;
              cy = 177.0;
              output = "DP-2";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "clock";
              settings = {
                clock_style = "digital";
              };
            };
            lockscreen-widget-0000000000000002 = {
              box_height = 160.0;
              box_width = 1920.0;
              cx = 958.0;
              cy = 1004.0;
              output = "DP-2";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "audio_visualizer";
              settings = {
                background_opacity = 0.0;
                bands = 128;
                centered = false;
                color_1 = "primary";
                mirrored = true;
                show_when_idle = false;
              };
            };
          };
        };
        osd = {
          enabled = true;
          monitors = [];
          kinds = {
            media = false;
          };
        };
        shell = {
          avatar_path = "/home/dan/.face";
          polkit_agent = true;
          screen_time_enabled = true;
          time_format = "{:%H:%M:%S}";
          launcher = {
            app_grid = true;
            fetch_exchange_rates = false;
          };
          panel = {
            launcher_placement = "attached";
            open_near_click_session = true;
          };
          session = {
            actions = [
              {
                action = "lock";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "1";
                variant = "default";
              }
              {
                action = "logout";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "2";
                variant = "default";
              }
              {
                action = "lock_and_suspend";
                countdown_seconds = 0.0;
                enabled = false;
                shortcut = "3";
                variant = "default";
              }
              {
                action = "reboot";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "4";
                variant = "default";
              }
              {
                action = "shutdown";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "5";
                variant = "destructive";
              }
            ];
          };
        };
        theme = {
          builtin = "Catppuccin";
          community_palette = "Oxocarbon";
          mode = "dark";
          source = "builtin";
          templates.builtin_ids = ["luciole"];
          wallpaper_scheme = "m3-content";
        };
        wallpaper = {
          default = {
            path = defaultWallpaper;
          };
          directory = "/home/dan/Pictures/Wallpapers";
          enabled = false;
          last = {
            path = defaultWallpaper;
          };
        };
        widget = {
          audio_visualizer = {
            mirrored = false;
          };
          control-center = {
            glyph = "triangle-inverted-filled";
          };
          media = {
            art_size = 20;
            max_length = 428;
            title_scroll = "on_hover";
          };
          network = {
            anchor = true;
            show_label = false;
          };
        };
      };
    };
  };
}
