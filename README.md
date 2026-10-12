<div align="center">

# ✦ dotfiles

**Hyprland · Noctalia · Neovim — mein Fedora-Desktop als Code**

[![Fedora](https://img.shields.io/badge/Fedora-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)](https://fedoraproject.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=hyprland&logoColor=black)](https://hyprland.org)
[![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io)
[![GNU Stow](https://img.shields.io/badge/managed%20with-GNU%20Stow-A42E2B?style=for-the-badge&logo=gnu&logoColor=white)](https://www.gnu.org/software/stow/)

</div>

---

## Überblick

| Bereich | Tools |
|---|---|
| **Compositor** | [Hyprland](https://hyprland.org) (Lua-Config) + hyprlock, hypridle |
| **Shell / Bar** | [Noctalia](https://github.com/noctalia-dev/noctalia-shell) auf [Quickshell](https://quickshell.outfoxxed.me), eigene `personal-shell`, Waybar |
| **Launcher** | rofi, walker, vicinae, wlogout |
| **Terminal** | kitty, ghostty, foot, alacritty, wezterm |
| **Editor** | Neovim ([LazyVim](https://www.lazyvim.org)), Doom Emacs, Zed |
| **CLI** | starship, yazi, btop, fastfetch, zathura |
| **Theming** | Noctalia-Paletten → werden per Skript in Terminal, rofi, Browser, Dock usw. übernommen |

## Installation

> [!WARNING]
> Das sind meine persönlichen Configs. Vor dem Übernehmen reinschauen – einige Pfade
> (z. B. `~/.local/bin/shell-switch`) setzen die Skripte aus dem `bin`-Paket voraus.

```sh
sudo dnf install stow git
git clone https://github.com/LennoWeber/dotfiles.git ~/dotfiles
cd ~/dotfiles

stow nvim kitty starship   # einzelne Pakete …
stow */                    # … oder alles
```

Stow legt für jedes Paket Symlinks von `~` in dieses Repo an. Bereits existierende
Dateien blockieren das – vorher wegsichern. Entfernen geht mit `stow -D <paket>`.

## Struktur

Jeder Ordner ist ein Stow-Paket, dessen Inhalt relativ zu `~` liegt:

```
dotfiles/
├── hypr/        → ~/.config/hypr          Hyprland, hyprlock, hypridle, Skripte
├── noctalia/    → ~/.config/noctalia      Settings, Paletten, Theme-Sync-Skripte
├── quickshell/  → ~/.config/quickshell/personal-shell
├── nvim/        → ~/.config/nvim          LazyVim + eigene Plugins/Keymaps
├── bin/         → ~/.local/bin            Helfer: shell-switch, Toggles, Fixes
└── …            kitty, ghostty, yazi, starship, fastfetch, …
```

<details>
<summary><b>Alle Pakete</b></summary>

| Paket | Ziel |
|---|---|
| `alacritty` `btop` `fastfetch` `foot` `ghostty` `kitty` `nvim` `rofi` `sway` `vicinae` `walker` `waybar` `wezterm` `wlogout` `yazi` `zathura` `zed` `hypr` `noctalia` | `~/.config/<paket>` |
| `quickshell` | `~/.config/quickshell/personal-shell` |
| `starship` | `~/.config/starship.toml` |
| `doom` | `~/.doom.d` |
| `x11` | `~/.Xresources` |
| `bin` | `~/.local/bin/*` |

</details>

## Credits

- [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) – Desktop-Shell & Farbsystem
- [LazyVim](https://github.com/LazyVim/LazyVim) – Neovim-Basis
- [ThePrimeagen](https://github.com/ThePrimeagen) – Inspiration für Harpoon-Workflow & Keymaps
