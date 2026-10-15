# Clocker World Clock (`szaidi.clocker`)

A native [Omarchy](https://omarchy.org/) status bar widget and world clock popup inspired by the built-in Omarchy Weather panel. Displays a compact globe icon (`󰖟`) in the bar and opens a rich popup featuring your 3 favorite cities, an instant searchable city/timezone picker, a `12H | 24H` toggle, and an interactive time scroller (`+1h`, `+3h`, `+5h`, `Tomorrow 9am`, or custom expressions).

<p align="center">
  <img src="preview.png" alt="Clocker World Clock Popup" width="100%">
</p>

<p align="center">
  <img src="preview-search.png" alt="Clocker City & Timezone Search Drawer" width="100%">
</p>

## Installation

Install and enable directly via the Omarchy plugin CLI:

```bash
omarchy plugin add https://github.com/szaidi-code/clocker.git --enable
```

To place it right beside your center clock:

```bash
omarchy bar move szaidi.clocker --section center
```

## Features

- **Compact Bar Icon (`󰖟`)**: Takes a single status icon slot in your top bar alongside your clock and weather icons.
- **3 Favorite City Cards**:
  - Live time, relative day badge (`+1d` / `-1d`), 3-letter city code, UTC offset (`UTC-04:00`), and IANA timezone.
  - Click any city card to focus it in the large Hero clock and copy its formatted time to your Wayland clipboard (`wl-copy`).
- **Searchable City & Timezone Picker**:
  - Click the top-right city pill (` CITY `) or the `` icon on any of the 3 city cards to open the full-width search drawer.
  - Switch between `Slot 1`, `Slot 2`, and `Slot 3` and search offline across major world cities and all ~400 system IANA timezones (`timedatectl list-timezones`).
- **`12H | 24H` Segmented Toggle**:
  - Switch instantly between 12-hour (`AM`/`PM`) and 24-hour display; persists across restarts in `~/.config/clocker/format.conf`.
- **Time Scroller (`+5h`, `-90m`, `15:00`, `Tomorrow 9am`)**:
  - Use quick preset chips (`Live`, `+1h`, `+3h`, `+5h`, `Tomorrow 9am`) or click **`󰥔 Custom (+5h, 15:00…)`** to preview what time it will be across all 3 cities simultaneously.
  - Pure `bash` + GNU `date` + `jq` backend (`bin/clocker-panel.sh`) with zero network calls or external dependencies.

## IPC & CLI Commands

Control the popup from scripts or keybindings:

```bash
# Toggle the world clock popup
omarchy-shell szaidi.clocker toggle

# Open directly in city search mode
omarchy-shell szaidi.clocker edit

# Open / close / refresh explicitly
omarchy-shell szaidi.clocker open
omarchy-shell szaidi.clocker close
omarchy-shell szaidi.clocker refresh
```

Test the backend JSON generator directly:

```bash
~/.config/omarchy/plugins/szaidi.clocker/bin/clocker-panel.sh | jq .
~/.config/omarchy/plugins/szaidi.clocker/bin/clocker-panel.sh --offset "+5h" | jq .
```

## Configuration Storage

User preferences are stored outside the plugin directory in `~/.config/clocker/` so plugin updates never overwrite your favorite cities:
- `~/.config/clocker/zones.conf` — Your 3 favorite `LABEL=IANA/Zone` entries.
- `~/.config/clocker/format.conf` — Saved `12h` or `24h` preference.

## License

MIT © [Sajjad Zaidi](https://github.com/szaidi-code)
