#!/usr/bin/env bash
# apply-zen-flatpak-theme.sh
# Ensures the Noctalia Zen Browser theming is applied to the Flatpak profile,
# which the upstream community template's apply.sh does not cover.
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
css_chrome="$cache_dir/noctalia/zen-browser/zen-userChrome.css"
css_content="$cache_dir/noctalia/zen-browser/zen-userContent.css"
line_chrome="@import \"$css_chrome\";"
line_content="@import \"$css_content\";"

# Flatpak Zen Browser profile location
flatpak_zen="$HOME/.var/app/app.zen_browser.zen/.zen"

if [[ ! -d "$flatpak_zen" ]]; then
    exit 0
fi

# Find all chrome directories in the Flatpak Zen profile
find "$flatpak_zen" -mindepth 2 -maxdepth 2 -type d -name chrome -print0 2>/dev/null |
    while IFS= read -r -d '' dir; do
        # Skip storage/permanent/chrome (not a profile chrome dir)
        [[ "$dir" == *"/storage/"* ]] && continue

        user_chrome="$dir/userChrome.css"
        user_content="$dir/userContent.css"
        mkdir -p "$dir"
        touch "$user_chrome" "$user_content"

        # Add import lines if not present
        if ! grep -Fq "$line_chrome" "$user_chrome"; then
            printf '%s\n' "$line_chrome" >>"$user_chrome"
        fi
        if ! grep -Fq "$line_content" "$user_content"; then
            printf '%s\n' "$line_content" >>"$user_content"
        fi
    done
