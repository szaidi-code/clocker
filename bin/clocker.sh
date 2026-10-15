#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${CLOCKER_CONFIG_DIR:-$HOME/.config/clocker}"
ZONES_FILE="$CONFIG_DIR/zones.conf"

if [[ ! -f "$ZONES_FILE" ]]; then
  jq -cn --arg text "Clocker: no zones.conf" --arg tooltip "Missing $ZONES_FILE" --arg class "offhours" \
    '{text: $text, tooltip: $tooltip, class: $class}'
  exit 0
fi

now_epoch=$(date +%s)
local_ymd=$(date -d "@$now_epoch" +%Y-%m-%d)
local_day_sec=$(date -u -d "$local_ymd" +%s)

bar_parts=()
tooltip_lines=()
bar_class="normal"
shown_count=0

while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  # Strip leading/trailing whitespace
  line="${raw_line#"${raw_line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"

  [[ -z "$line" || "$line" == \#* ]] && continue
  [[ "$line" != *=* ]] && continue

  label="${line%%=*}"
  tz="${line#*=}"
  label="${label#"${label%%[![:space:]]*}"}"
  label="${label%"${label##*[![:space:]]}"}"
  tz="${tz#"${tz%%[![:space:]]*}"}"
  tz="${tz%"${tz##*[![:space:]]}"}"

  [[ -z "$label" || -z "$tz" ]] && continue

  hm_colon=$(TZ="$tz" date -d "@$now_epoch" +%H:%M)
  hm_num=$(TZ="$tz" date -d "@$now_epoch" +%H%M)
  full_date=$(TZ="$tz" date -d "@$now_epoch" +"%a, %b %d %Y %H:%M")
  utc_off=$(TZ="$tz" date -d "@$now_epoch" +"UTC%:z")
  zone_ymd=$(TZ="$tz" date -d "@$now_epoch" +%Y-%m-%d)
  zone_day_sec=$(date -u -d "$zone_ymd" +%s)
  day_diff=$(( (zone_day_sec - local_day_sec) / 86400 ))

  day_marker=""
  if (( day_diff > 0 )); then
    day_marker=" +${day_diff}"
  elif (( day_diff < 0 )); then
    day_marker=" ${day_diff}"
  fi

  if (( shown_count < 3 )); then
    bar_parts+=("${label} ${hm_colon}")
    if (( 10#$hm_num < 900 || 10#$hm_num > 1800 )); then
      bar_class="offhours"
    fi
    shown_count=$(( shown_count + 1 ))
  fi

  printf -v tip_line "%-4s %s (%s)%s (%s)" "$label" "$full_date" "$utc_off" "$day_marker" "$tz"
  tooltip_lines+=("$tip_line")
done < "$ZONES_FILE"

bar_text=""
for i in "${!bar_parts[@]}"; do
  if (( i > 0 )); then
    bar_text+=" · "
  fi
  bar_text+="${bar_parts[$i]}"
done

tooltip_text=""
for i in "${!tooltip_lines[@]}"; do
  if (( i > 0 )); then
    tooltip_text+=$'\n'
  fi
  tooltip_text+="${tooltip_lines[$i]}"
done

jq -cn \
  --arg text "$bar_text" \
  --arg tooltip "$tooltip_text" \
  --arg class "$bar_class" \
  '{text: $text, tooltip: $tooltip, class: $class}'
