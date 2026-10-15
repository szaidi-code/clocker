#!/usr/bin/env bash
set -euo pipefail

SHELL_JSON="$HOME/.config/omarchy/shell.json"
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"

if [[ "${1:-}" == "--restore-backups" ]]; then
  [[ -f "${SHELL_JSON}.bak-clocker" ]] && cp "${SHELL_JSON}.bak-clocker" "$SHELL_JSON"
  [[ -f "${BINDINGS_LUA}.bak-clocker" ]] && cp "${BINDINGS_LUA}.bak-clocker" "$BINDINGS_LUA"
else
  if [[ -f "$SHELL_JSON" ]]; then
    tmp_json=$(mktemp)
    jq '
      .bar.layout.left = ((.bar.layout.left // []) | map(select(.id != "szaidi.clocker"))) |
      .bar.layout.center = ((.bar.layout.center // []) | map(select(.id != "szaidi.clocker"))) |
      .bar.layout.right = ((.bar.layout.right // []) | map(select(.id != "szaidi.clocker")))
    ' "$SHELL_JSON" > "$tmp_json"
    mv "$tmp_json" "$SHELL_JSON"
  fi

  if [[ -f "$BINDINGS_LUA" ]]; then
    tmp_lua=$(mktemp)
    awk '
      /^-- clocker:begin$/ { skip = 1; next }
      /^-- clocker:end$/   { skip = 0; next }
      !skip { print }
    ' "$BINDINGS_LUA" > "$tmp_lua"
    mv "$tmp_lua" "$BINDINGS_LUA"
  fi
fi

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
fi

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi

echo "Clocker removed from active configuration."
