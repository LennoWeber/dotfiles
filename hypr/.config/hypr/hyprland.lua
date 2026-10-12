-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    Hyprland Lua Config                      ║
-- ║           Konvertiert von hyprland.conf → hyprland.lua      ║
-- ╚══════════════════════════════════════════════════════════════╝

------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = "1",
})

-- monitor = DP-1, 1920x1080@60, 1920x0, 1  (deaktiviert)

hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",
	position = "auto-right",
	scale = "1",
})

hl.monitor({
	output = "DP-1",
	mode = "1920x1080@60.00Hz",
	position = "1920x0",
	scale = "1",
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Ghostty wie Terminal auf dem Mac (Config: ~/.config/ghostty/config)
local terminal = "ghostty"
local fileManager = "nemo"
local browser = "/home/lenno/.local/bin/zen"
local mainMod = "SUPER"
-- IPC an die aktive Shell (Noctalia oder L-Shell), siehe ~/.local/bin/shell-switch
local shell = "/home/lenno/.local/bin/shell-switch msg"
local menu = shell .. " panel-toggle launcher"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- graphical-session.target aktivieren (sonst startet xdg-desktop-portal nicht -> Flatpak-Dateidialoge kaputt)
	hl.exec_cmd("dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target")
	hl.exec_cmd("wl-paste --watch cliphist store &")
	hl.exec_cmd(
		"gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark; gsettings set org.cinnamon.desktop.interface icon-theme Papirus-Dark"
	)
	-- Fensterknöpfe links wie auf dem Mac (rot schließen, grün maximieren; Minimieren gibt es in Hyprland nicht).
	-- Die Ampelfarben setzt das GTK-Theme von L-Shell.
	hl.exec_cmd(
		"gsettings set org.gnome.desktop.wm.preferences button-layout 'close,maximize:'"
	)
	hl.exec_cmd("hyprpm reload n")
	-- zuletzt gewählte Shell (Noctalia oder L-Shell), Fallback auf die andere
	hl.exec_cmd("/home/lenno/.local/bin/shell-switch start")
	-- hl.exec_cmd('~/.config/hypr/scripts/spotify-launch.sh')
	-- hl.exec_cmd('~/.config/hypr/scripts/start-nwg-dock.sh')
	hl.exec_cmd("hypridle")
	hl.exec_cmd("nm-applet &")
	hl.exec_cmd("kdeconnect-indicator &")
end)

-- exec (jedes Mal bei Config-Reload)
hl.exec_cmd("~/.config/hypr/scripts/auto-workspace-monitors.sh")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("PATH", "/home/lenno/.local/bin:" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin"))
hl.env("XCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_SIZE", "18")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
-- Standard-Terminal für Programme, die eins öffnen (L-Shell, Noctalia, Desktop-Dateien mit Terminal=true)
hl.env("TERMINAL", "ghostty")

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Kein GTK_THEME: es erzwingt Dunkel auch im hellen Modus. Hell/Dunkel setzt die Shell über
-- gsettings (adw-gtk3 bzw. adw-gtk3-dark) passend zum Theme-Modus.

-- For Noctalia Color templates (vor LOOK AND FEEL, damit general.col unten gewinnt)
require("noctalia").apply_theme()

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		-- macOS-Look: feine neutrale Haarlinie statt farbigem Rahmen
		border_size = 1,
		col = {
			active_border = "rgba(ffffff26)",
			inactive_border = "rgba(ffffff12)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 4,
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		-- große, weiche Schatten wie bei macOS
		shadow = {
			enabled = true,
			range = 28,
			render_power = 3,
			offset = "0 8",
			color = "rgba(00000080)",
		},

		-- helles "Vibrancy"-Blur für Leiste, Dock, Panels
		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			brightness = 0.9,
			vibrancy = 0.2,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})

----------------
---- CURVES ----
----------------

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

--------------------
---- ANIMATIONS ----
--------------------

hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 2.7, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 2.4, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.05, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.75, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 0.87, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.73, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.52, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.91, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.75, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.9, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.7, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 0.97, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 0.61, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 0.97, bezier = "almostLinear", style = "fade" })

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "de",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},
})

------------------
---- GESTURES ----
------------------

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-----------------
---- DEVICES ----
-----------------

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

-- Allgemein
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
-- wie Cmd+Leertaste auf dem Mac
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(shell .. " screenshot-region"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.local/bin/toggle-laptop-rotation.sh"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(terminal .. " -e yazi"))

-- Fokus & Workspaces
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
	hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))
hl.bind(mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + ALT + left", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.workspace.move({ monitor = "r" }))

-- Maus-Binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Medien / Funktionstasten (XF86-Keysyms – gelten für Laptop UND MX Keys S)
-- Helligkeit (Laptop: F1/F2, MX Keys S: F4/F5)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(shell .. " brightness-down"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(shell .. " brightness-up"), { locked = true, repeating = true })

-- Mediensteuerung (Laptop: F7-F9, MX Keys S: F10 für Play/Pause)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(shell .. " media prev"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(shell .. " media play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(shell .. " media play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(shell .. " media next"), { locked = true })

-- Lautstärke (Laptop: F10-F12, MX Keys S: F11=Mute, F12=Leiser, Einfg=Lauter)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(shell .. " volume-mute"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(shell .. " volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(shell .. " volume-up"), { locked = true, repeating = true })

-- Mikrofon stumm (MX Keys S: F9)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(shell .. " mic-mute"), { locked = true, repeating = true })

-- Tastatur-Hintergrundbeleuchtung
hl.bind(
	"XF86KbdBrightnessDown",
	hl.dsp.exec_cmd(shell .. " keyboard-backlight-down"),
	{ locked = true, repeating = true }
)
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(shell .. " keyboard-backlight-up"), { locked = true, repeating = true })
hl.bind("XF86KbdLightOnOff", hl.dsp.exec_cmd(shell .. " keyboard-backlight-toggle"))

-- MX Keys S: F6 – Diktat/Spracheingabe
hl.bind("XF86Dictate", hl.dsp.exec_cmd(shell .. " panel-open launcher"))
-- MX Keys S: F7 – Emoji
hl.bind("XF86EmojiPicker", hl.dsp.exec_cmd(shell .. " panel-open launcher /emo"))
-- MX Keys S: F8 – Screenshot
hl.bind("Print", hl.dsp.exec_cmd(shell .. " screenshot-region"))
-- MX Keys S: Entf – Lock
hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd(shell .. " session lock"))

-- Shell-Auswahl: Noctalia oder L-Shell
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd("/home/lenno/.local/bin/shell-switch"))

-- Übersicht aller Schreibtische auf allen Monitoren (Expo, nur L-Shell)
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(shell .. " expo"))
-- Mission Control: Fenster des aktuellen Schreibtischs (nur L-Shell)
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(shell .. " overview"))

-- Noctalia v5 Panels
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(shell .. " settings-toggle"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(shell .. " panel-toggle control-center"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(shell .. " settings-toggle"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(shell .. " panel-toggle session"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(shell .. " session lock"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(shell .. " theme-mode-toggle"))
-- Mitteilungszentrale (L-Shell); shell-switch übersetzt das für Noctalia ins Kontrollzentrum
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(shell .. " panel-toggle notification-center"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(shell .. " panel-toggle wallpaper"))

------------------------
---- WINDOW RULES  ----
------------------------

hl.window_rule({ match = { class = "zen|zen-alpha|app.zen_browser.zen" }, workspace = 2 })
hl.window_rule({ match = { class = "code|antigravity|cursor|codium" }, workspace = 3 })
hl.window_rule({ match = { class = "ONLYOFFICE" }, workspace = 4 })
hl.window_rule({ match = { class = "spotify" }, workspace = 5 })

hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

hl.window_rule({ match = { class = "^(gnome-calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.Nautilus)$" }, float = true })

---------------------------
---- WORKSPACE RULES  ----
---------------------------

-- Persistente Workspaces 1–10 (ohne Monitor-Pinning)
for i = 1, 10 do
	hl.workspace_rule({ workspace = tostring(i), persistent = false })
end

-------------------------
---- LAYER RULES    ----
-------------------------

hl.layer_rule({
	name = "noctalia",
	match = {
		-- island/expo gibt es nur in L-Shell; L-Shell nutzt dieselben noctalia-Namespaces
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher|island|expo)$",
	},
	no_anim = true,
	-- unter dem leichtesten Glas-Tint (Dock: 0.45), über den weichen Schatten: Glas wird geblurrt, Schatten nicht
	ignore_alpha = 0.4,
	blur = true,
	blur_popups = true,
})
hl.layer_rule({
	match = { namespace = "^nwg-dock$" },
	blur = true,
	blur_popups = true,
	ignore_alpha = 0.5,
})

-- Rahmenfarben kommen nicht aus dem Theme (macOS-Look, siehe general.col): apply_theme() läuft deshalb
-- vor LOOK AND FEEL und liefert nur noch die Gruppen-Farben.
