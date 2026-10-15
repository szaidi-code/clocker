#!/usr/bin/env bash
set -euo pipefail

SHELL_JSON="$HOME/.config/omarchy/shell.json"
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/szaidi.clocker"

# 1. Create backups once (preserve original pre-clocker state on re-runs)
if [[ -f "$SHELL_JSON" && ! -f "${SHELL_JSON}.bak-clocker" ]]; then
  cp "$SHELL_JSON" "${SHELL_JSON}.bak-clocker"
fi

if [[ -f "$BINDINGS_LUA" && ! -f "${BINDINGS_LUA}.bak-clocker" ]]; then
  cp "$BINDINGS_LUA" "${BINDINGS_LUA}.bak-clocker"
fi

# 2. Idempotently add szaidi.clocker right after szaidi.clock (or omarchy.clock) in shell.json
if [[ -f "$SHELL_JSON" ]]; then
  tmp_json=$(mktemp)
  jq '
    # Remove any existing szaidi.clocker entries across all sections first
    .bar.layout.left = ((.bar.layout.left // []) | map(select(.id != "szaidi.clocker"))) |
    .bar.layout.center = ((.bar.layout.center // []) | map(select(.id != "szaidi.clocker"))) |
    .bar.layout.right = ((.bar.layout.right // []) | map(select(.id != "szaidi.clocker"))) |
    # Insert right after szaidi.clock or omarchy.clock in center
    .bar.layout.center = (
      (.bar.layout.center // []) as $c |
      ([ $c | to_entries[] | select(.value.id == "szaidi.clock" or .value.id == "omarchy.clock") | .key ][0]) as $idx |
      if $idx != null then
        $c[:($idx + 1)] + [{"id": "szaidi.clocker", "interval": 30}] + $c[($idx + 1):]
      else
        $c + [{"id": "szaidi.clocker", "interval": 30}]
      end
    )
  ' "$SHELL_JSON" > "$tmp_json"
  mv "$tmp_json" "$SHELL_JSON"
fi

# 3. Idempotently add SUPER + ALT + T binding to ~/.config/hypr/bindings.lua
if [[ -f "$BINDINGS_LUA" ]]; then
  tmp_lua=$(mktemp)
  awk '
    /^-- clocker:begin$/ { skip = 1; next }
    /^-- clocker:end$/   { skip = 0; next }
    !skip { print }
  ' "$BINDINGS_LUA" > "$tmp_lua"

  # Ensure a single trailing blank line before appending block
  cat >> "$tmp_lua" << 'EOF'
-- clocker:begin
o.bind("SUPER + ALT + T", "Clocker time scroller", "~/.config/clocker/clocker-scroll.sh")
-- clocker:end
EOF
  mv "$tmp_lua" "$BINDINGS_LUA"
fi

# 4. Validate and hot-reload Omarchy shell plugins + Hyprland
if [[ -d "$PLUGIN_DIR" ]] && command -v omarchy >/dev/null 2>&1; then
  omarchy plugin validate "$PLUGIN_DIR"
fi

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
fi

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi

echo "Clocker installed successfully."
