-- =============================================================================
--  Hyprw0lf Configuration
-- =============================================================================

-- Monitor setup. display_profile.sh owns runtime workspace placement.
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@119.98Hz", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-2", mode = "preferred", position = "auto", scale = 1.25 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Startup applications. This event fires once per compositor launch, not on reload.
hl.on("hyprland.start", function()
    local commands = {
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "/usr/lib/pam_kwallet_init",
        "~/.config/hypr/scripts/start_polkit_agent.sh",
        "~/.config/hypr/scripts/display_profile.sh apply",
        "~/.config/hypr/scripts/monitor_hotplug_watcher.sh",
        "/home/w0lf/.local/opt/waybar-lua-ipc-0.15.0/waybar",
        "~/.config/hypr/scripts/start_wallpaper_backend.sh",
        "~/.config/hypr/scripts/start_swayosd.sh",
        "~/.config/hypr/scripts/start_hyprsunset.sh",
        -- hypridle is managed by the enabled systemd user service.
        "swaync",
        "thunar --daemon",
        "blueman-applet",
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store",
    }

    for _, command in ipairs(commands) do
        hl.exec_cmd(command)
    end
end)

hl.env("XCURSOR_SIZE", "24")

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        scroll_method = "on_button_down",
        scroll_button = 2,
        touchpad = {
            natural_scroll = true,
        },
        sensitivity = 0,
    },
    cursor = {
        inactive_timeout = 3,
        -- Mixed AMD/NVIDIA outputs can make hardware cursor blits fail on HDMI.
        no_hardware_cursors = true,
    },
    general = {
        gaps_in = 2,
        gaps_out = 4,
        border_size = 2,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
})

hl.device({
    name = "kensington-slimblade-trackball",
    sensitivity = -0.5,
    scroll_factor = 1.0,
    accel_profile = "adaptive",
    scroll_method = "on_button_down",
    scroll_button = 275,
})

hl.device({
    name = "logitech-usb-receiver-mouse",
    sensitivity = -0.2,
    scroll_factor = 1.0,
    accel_profile = "adaptive",
})

-- Theme-owned Hyprland tokens are rendered by ../bin/hypr-theme.
require("theme")

hl.curve("fluid", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})
hl.curve("overshoot", {
    type = "bezier",
    points = { { 0.13, 0.99 }, { 0.29, 1.1 } },
})
hl.curve("smoothOut", {
    type = "bezier",
    points = { { 0.36, 0 }, { 0.66, -0.56 } },
})
hl.curve("smoothIn", {
    type = "bezier",
    points = { { 0.25, 1 }, { 0.5, 1 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "overshoot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "fluid" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 10, bezier = "smoothIn" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "fluid", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "fluid", style = "slidefadevert 15%" })

-- Unified window rules (fixed sizing).
local window_rules = {
    {
        name = "brave-file-dialog",
        match = { class = "^brave$", title = "^(Save File|Open File)$" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.5", "monitor_h*0.6" },
    },
    {
        name = "brave-permission-dialog",
        match = { class = "^brave$", title = ".*wants to.*" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.3", "monitor_h*0.3" },
    },
    {
        name = "brave-google-sign-in",
        match = { class = "^brave$", title = "^Sign in - Google Accounts.*" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.4", "monitor_h*0.8" },
    },
    {
        name = "zen-file-dialog",
        match = { class = "^zen$", title = "^(Save File|Open File)$" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.5", "monitor_h*0.6" },
    },
    {
        name = "zen-permission-dialog",
        match = { class = "^zen$", title = ".*wants to.*" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.3", "monitor_h*0.3" },
    },
    {
        name = "zen-auth-dialog",
        match = { class = "^zen$", title = "^(Sign in - .*|Log in - .*|Authentication.*|Authorization.*).*" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.4", "monitor_h*0.8" },
    },
    {
        name = "brave-untitled",
        match = { class = "^brave-browser$", initial_title = "^Untitled.*$" },
        float = true, center = true,
        size = { "monitor_w*0.3", "monitor_h*0.6" },
    },
    {
        name = "picture-in-picture",
        match = { title = "^(Picture in picture|Picture-in-Picture)$" },
        float = true, pin = true,
        size = { "monitor_w*0.3", "monitor_h*0.3" },
        move = { "monitor_w*0.7-20", "monitor_h*0.7-20" },
    },
    {
        name = "pavucontrol",
        match = { class = "^org.pulseaudio.pavucontrol$" },
        float = true, center = true,
        size = { "monitor_w*0.55", "monitor_h*0.72" },
    },
    {
        name = "blueman-manager",
        match = { class = "^blueman-manager$" },
        float = true, center = true,
        size = { "monitor_w*0.4", "monitor_h*0.5" },
    },
    {
        name = "network-editor",
        match = { class = "^nm-connection-editor$" },
        float = true, center = true,
        size = { "monitor_w*0.4", "monitor_h*0.5" },
    },
    {
        name = "qalculate",
        match = { class = "^qalculate-gtk$" },
        float = true, center = true,
        size = { "monitor_w*0.4", "monitor_h*0.5" },
    },
    {
        name = "thunar-file-operation",
        match = { class = "^[Tt]hunar$", title = "^File Operation Progress$" },
        float = true, center = true,
        size = { "monitor_w*0.3", "monitor_h*0.2" },
    },
    {
        name = "thunar-dialog",
        match = { class = "^[Tt]hunar$", title = "^(Confirm to Replace|Properties|Alert|Error|Attention)$" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.3", "monitor_h*0.4" },
    },
    {
        name = "thunar-rename",
        match = { class = "^[Tt]hunar$", title = "^Rename.*" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.3", "monitor_h*0.3" },
    },
    {
        name = "imv",
        match = { class = "^imv$" },
        dim_around = true, float = true, center = true,
        size = { "monitor_w*0.5", "monitor_h*0.5" },
    },
    {
        name = "herdr-cockpit",
        match = { class = "^herdr-cockpit$" },
        workspace = "name:agents",
    },
}

for _, rule in ipairs(window_rules) do
    hl.window_rule(rule)
end

-- Keybindings.
local main_mod = "SUPER"
local function bind(keys, dispatcher, opts)
    hl.bind(keys, dispatcher, opts)
end
local function bind_exec(keys, command, opts)
    bind(keys, hl.dsp.exec_cmd(command), opts)
end

-- Application launchers.
bind_exec(main_mod .. " + C", "qalculate-gtk")
bind_exec(main_mod .. " + E", "emacsclient -c -a \"emacs\"")
bind_exec(main_mod .. " + RETURN", "fuzzel")
bind_exec(main_mod .. " + SHIFT + RETURN", "~/.config/hypr/scripts/theme_selector.sh")
bind_exec(main_mod .. " + CTRL + RETURN", "~/.config/hypr/scripts/transition_preset_selector.sh")
bind_exec(main_mod .. " + SPACE", "kitty")
bind_exec(main_mod .. " + W", "zen-browser")
bind_exec(main_mod .. " + Z", "thunar")

-- System and UI controls.
bind_exec(main_mod .. " + minus", "killall -SIGUSR1 waybar")
bind_exec(main_mod .. " + SHIFT + minus", "killall -SIGUSR2 waybar")
bind_exec(main_mod .. " + Home", "~/.config/waybar/scripts/power-menu.sh")
bind_exec(main_mod .. " + Delete", "loginctl lock-session")
bind_exec(main_mod .. " + N", "swaync-client -t -sw")
bind_exec(main_mod .. " + SHIFT + N", "~/.config/hypr/scripts/night_light.sh toggle")
bind_exec(main_mod .. " + SHIFT + A", "~/.config/hypr/scripts/select_playback_output.py", { dont_inhibit = true })
bind_exec(main_mod .. " + CTRL + A", "~/.config/hypr/scripts/herdr_cockpit.sh")
bind_exec(main_mod .. " + V", "~/.config/hypr/scripts/cliphist_selector.sh")

-- Window management.
bind(main_mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
bind(main_mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind(main_mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
bind(main_mod .. " + Q", hl.dsp.window.close())
bind(main_mod .. " + Tab", hl.dsp.layout("togglesplit"))

-- Focus and navigation.
for key, direction in pairs({ h = "left", l = "right", k = "up", j = "down" }) do
    bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
end

-- Window movement and resizing.
for key, delta in pairs({ l = { 5, 0 }, h = { -5, 0 }, k = { 0, -5 }, j = { 0, 5 } }) do
    bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true }))
    bind(main_mod .. " + ALT + " .. key, hl.dsp.window.move({ x = delta[1], y = delta[2], relative = true }))
end
for key, direction in pairs({ l = "right", h = "left", k = "up", j = "down" }) do
    bind(main_mod .. " + CTRL + " .. key, hl.dsp.window.move({ direction = direction }))
end

bind_exec(main_mod .. " + SHIFT + X", "pkill Xwayland")
bind_exec(main_mod .. " + SHIFT + M", "~/.config/hypr/scripts/display_profile.sh apply --notify")
bind_exec(main_mod .. " + CTRL + SHIFT + M", "~/.config/hypr/scripts/display_profile.sh repair --notify")

-- Scratchpad, groups, and fast focus.
bind(main_mod .. " + grave", hl.dsp.workspace.toggle_special("scratchpad"))
bind(main_mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
bind(main_mod .. " + G", hl.dsp.group.toggle())
bind(main_mod .. " + SHIFT + G", hl.dsp.group.lock({ action = "toggle" }))
bind(main_mod .. " + bracketright", hl.dsp.group.next())
bind(main_mod .. " + bracketleft", hl.dsp.group.prev())
bind(main_mod .. " + apostrophe", hl.dsp.focus({ last = true }))
bind(main_mod .. " + period", hl.dsp.window.cycle_next({ next = true }))
bind(main_mod .. " + comma", hl.dsp.window.cycle_next({ next = false }))
bind_exec(main_mod .. " + SHIFT + bracketright", "~/.config/hypr/scripts/move_current_workspace_to_monitor.sh next")
bind_exec(main_mod .. " + SHIFT + bracketleft", "~/.config/hypr/scripts/move_current_workspace_to_monitor.sh prev")

-- Mouse bindings.
bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Number-row workspace operations.
for workspace = 1, 10 do
    local number = workspace % 10
    local key = tostring(number)
    bind_exec(main_mod .. " + " .. key, "~/.config/hypr/scripts/workspace_handler.sh workspace " .. number)
    bind_exec(main_mod .. " + SHIFT + " .. key, "~/.config/hypr/scripts/workspace_handler.sh movetoworkspace " .. number)
    bind_exec(main_mod .. " + CTRL + " .. key, "~/.config/hypr/scripts/swap_pair.sh " .. number)
end

-- Media and hardware keys.
local repeat_locked = { repeating = true, locked = true }
local locked = { locked = true }
bind_exec("XF86AudioRaiseVolume", "~/.config/hypr/scripts/osd_control.sh volume up", repeat_locked)
bind_exec("XF86AudioLowerVolume", "~/.config/hypr/scripts/osd_control.sh volume down", repeat_locked)
bind_exec("XF86AudioMute", "~/.config/hypr/scripts/osd_control.sh volume mute", locked)
bind_exec("XF86AudioMicMute", "~/.config/hypr/scripts/osd_control.sh volume micmute", locked)
bind_exec("XF86MonBrightnessUp", "~/.config/hypr/scripts/osd_control.sh brightness up", repeat_locked)
bind_exec("XF86MonBrightnessDown", "~/.config/hypr/scripts/osd_control.sh brightness down", repeat_locked)
bind_exec(main_mod .. " + Prior", "~/.config/hypr/scripts/osd_control.sh brightness up", repeat_locked)
bind_exec(main_mod .. " + Next", "~/.config/hypr/scripts/osd_control.sh brightness down", repeat_locked)
bind_exec("XF86AudioPlay", "~/.config/hypr/scripts/osd_control.sh media play", locked)
bind_exec("XF86AudioNext", "~/.config/hypr/scripts/osd_control.sh media next", locked)
bind_exec("XF86AudioPrev", "~/.config/hypr/scripts/osd_control.sh media prev", locked)
bind_exec("XF86AudioStop", "~/.config/hypr/scripts/osd_control.sh media stop", locked)

-- Screenshots.
bind_exec("Print", "~/.config/hypr/scripts/screenshot.sh output focused")
bind_exec("SHIFT + Print", "~/.config/hypr/scripts/screenshot.sh output laptop")
bind_exec("ALT + Print", "~/.config/hypr/scripts/screenshot.sh output external")
bind_exec(main_mod .. " + Print", "~/.config/hypr/scripts/screenshot.sh clipboard")
bind_exec(main_mod .. " + CTRL + Print", "~/.config/hypr/scripts/screenshot.sh region")
bind_exec(main_mod .. " + SHIFT + Print", "~/.config/hypr/scripts/screenshot.sh edit")

-- Workspace placement is owned by display_profile.sh so hotplug can use runtime
-- output names instead of stale connector assumptions.
-- Dual: 1-10 laptop, 11-20 external. Laptop-only: 1-20 laptop.
