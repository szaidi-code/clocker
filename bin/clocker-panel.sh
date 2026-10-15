#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${CLOCKER_CONFIG_DIR:-$HOME/.config/clocker}"
ZONES_FILE="$CONFIG_DIR/zones.conf"
FORMAT_FILE="$CONFIG_DIR/format.conf"
mkdir -p "$CONFIG_DIR"

if [[ ! -f "$ZONES_FILE" ]]; then
  cat > "$ZONES_FILE" << 'EOF'
# Clocker Time Zones
# Format: LABEL=IANA/Time_Zone
NYC=America/New_York
LDN=Europe/London
DXB=Asia/Dubai
EOF
fi

if [[ ! -f "$FORMAT_FILE" ]]; then
  echo "12h" > "$FORMAT_FILE"
fi

# Mode 1: Update time format (--set-format <12h|24h>)
if [[ "${1:-}" == "--set-format" ]]; then
  fmt="${2:-24h}"
  if [[ "$fmt" == "12h" || "$fmt" == "12" ]]; then
    echo "12h" > "$FORMAT_FILE"
  else
    echo "24h" > "$FORMAT_FILE"
  fi
  exit 0
fi

# Mode 2: Update a slot in zones.conf (--set-slot <0|1|2> <LABEL> <TZ>)
if [[ "${1:-}" == "--set-slot" ]]; then
  slot_idx="${2:-0}"
  new_label="${3:-}"
  new_tz="${4:-}"
  if [[ -z "$new_label" || -z "$new_tz" ]]; then
    echo "Usage: clocker-panel.sh --set-slot <index> <LABEL> <TZ>" >&2
    exit 1
  fi

  mapfile -t current_entries < <(
    while IFS= read -r raw || [[ -n "$raw" ]]; do
      line="${raw#"${raw%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue
      printf '%s\n' "$line"
    done < "$ZONES_FILE"
  )

  while (( ${#current_entries[@]} <= slot_idx )); do
    current_entries+=("UTC=Etc/UTC")
  done
  current_entries[$slot_idx]="${new_label}=${new_tz}"

  {
    echo "# Clocker Time Zones"
    echo "# Format: LABEL=IANA/Time_Zone"
    echo "# First 3 zones appear in the bar; all zones appear in the tooltip and time scroller."
    for entry in "${current_entries[@]}"; do
      printf '%s\n' "$entry"
    done
  } > "${ZONES_FILE}.tmp"
  mv "${ZONES_FILE}.tmp" "$ZONES_FILE"
  exit 0
fi

# Normalize compact relative offsets like +5h, -90m, +1d2h into GNU date syntax
normalize_expr() {
  local raw="$1"
  local trimmed="${raw#"${raw%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

  if [[ "$trimmed" =~ ^([+-]?)([0-9]+[[:space:]]*(w|wk|wks|week|weeks|d|day|days|h|hr|hrs|hour|hours|m|min|mins|minute|minutes|s|sec|secs|second|seconds)[[:space:]]*)+$ ]]; then
    local sign="${BASH_REMATCH[1]:-+}"
    local rest="${trimmed#"$sign"}"
    local out="now"
    while [[ -n "$rest" ]]; do
      rest="${rest#"${rest%%[![:space:]]*}"}"
      [[ -z "$rest" ]] && break
      if [[ "$rest" =~ ^([0-9]+)[[:space:]]*(w|wk|wks|week|weeks|d|day|days|h|hr|hrs|hour|hours|m|min|mins|minute|minutes|s|sec|secs|second|seconds)(.*)$ ]]; then
        local num="${BASH_REMATCH[1]}"
        local unit_raw="${BASH_REMATCH[2]}"
        rest="${BASH_REMATCH[3]}"
        local unit=""
        case "$unit_raw" in
          w|wk|wks|week|weeks) unit="weeks" ;;
          d|day|days) unit="days" ;;
          h|hr|hrs|hour|hours) unit="hours" ;;
          m|min|mins|minute|minutes) unit="minutes" ;;
          s|sec|secs|second|seconds) unit="seconds" ;;
        esac
        out+=" ${sign} ${num} ${unit}"
      else
        break
      fi
    done
    printf '%s\n' "$out"
    return 0
  fi

  printf '%s\n' "$trimmed"
}

saved_format="24h"
if [[ -f "$FORMAT_FILE" ]]; then
  saved_format=$(tr -d '[:space:]' < "$FORMAT_FILE")
fi
use_12h=false
if [[ "$saved_format" == "12h" ]]; then
  use_12h=true
fi

offset_raw=""
if [[ "${1:-}" == "--offset" ]]; then
  offset_raw="${2:-}"
fi

offset_trimmed="${offset_raw#"${offset_raw%%[![:space:]]*}"}"
offset_trimmed="${offset_trimmed%"${offset_trimmed##*[![:space:]]}"}"

offset_valid=true
target_epoch=$(date +%s)

if [[ -n "$offset_trimmed" ]]; then
  if [[ "$offset_trimmed" =~ ^[0-9]+$ ]]; then
    offset_valid=false
  else
    norm=$(normalize_expr "$offset_trimmed")
    if parsed_ep=$(date -d "$norm" +%s 2>/dev/null); then
      target_epoch="$parsed_ep"
    else
      offset_valid=false
    fi
  fi
fi

local_ymd=$(date -d "@$target_epoch" +%Y-%m-%d)
local_day_sec=$(date -u -d "$local_ymd" +%s)
local_time=$(date -d "@$target_epoch" +%H:%M)
local_date=$(date -d "@$target_epoch" +"%a, %b %d")

zones_json="[]"
idx=0

while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  line="${raw_line#"${raw_line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue

  label="${line%%=*}"
  tz="${line#*=}"
  label="${label#"${label%%[![:space:]]*}"}"
  label="${label%"${label##*[![:space:]]}"}"
  tz="${tz#"${tz%%[![:space:]]*}"}"
  tz="${tz%"${tz##*[![:space:]]}"}"
  [[ -z "$label" || -z "$tz" ]] && continue

  city_fallback="${tz##*/}"
  city_fallback="${city_fallback//_/ }"

  hm_24=$(TZ="$tz" date -d "@$target_epoch" +%H:%M)
  hm_12=$(TZ="$tz" date -d "@$target_epoch" +%-I:%M)
  ampm=$(TZ="$tz" date -d "@$target_epoch" +%p)
  hm_num=$(TZ="$tz" date -d "@$target_epoch" +%H%M)
  day_short=$(TZ="$tz" date -d "@$target_epoch" +%a)
  date_short=$(TZ="$tz" date -d "@$target_epoch" +"%b %d")
  full_date=$(TZ="$tz" date -d "@$target_epoch" +"%a, %b %d %Y")
  utc_off=$(TZ="$tz" date -d "@$target_epoch" +"UTC%:z")
  zone_ymd=$(TZ="$tz" date -d "@$target_epoch" +%Y-%m-%d)
  zone_day_sec=$(date -u -d "$zone_ymd" +%s)
  day_diff=$(( (zone_day_sec - local_day_sec) / 86400 ))

  day_marker=""
  if (( day_diff > 0 )); then
    day_marker="+${day_diff}d"
  elif (( day_diff < 0 )); then
    day_marker="${day_diff}d"
  fi

  is_offhours=false
  if (( 10#$hm_num < 900 || 10#$hm_num > 1800 )); then
    is_offhours=true
  fi

  suffix="(now)"
  if [[ -n "$offset_trimmed" && "$offset_valid" == true ]]; then
    if [[ "$offset_trimmed" =~ ^[+-] ]]; then
      suffix="(${offset_trimmed} from now)"
    else
      suffix="(${offset_trimmed})"
    fi
  fi
  printf -v copy_str_24 "%-4s %s %s  %s" "$label" "$day_short" "$hm_24" "$suffix"
  printf -v copy_str_12 "%-4s %s %s %s  %s" "$label" "$day_short" "$hm_12" "$ampm" "$suffix"

  zones_json=$(jq -cn \
    --argjson arr "$zones_json" \
    --argjson index "$idx" \
    --arg label "$label" \
    --arg tz "$tz" \
    --arg city "$city_fallback" \
    --arg time "$hm_24" \
    --arg time24 "$hm_24" \
    --arg time12 "$hm_12" \
    --arg ampm "$ampm" \
    --arg dayShort "$day_short" \
    --arg dateShort "$date_short" \
    --arg fullDate "$full_date" \
    --arg utcOffset "$utc_off" \
    --arg dayMarker "$day_marker" \
    --argjson offhours "$is_offhours" \
    --arg copyText24 "$copy_str_24" \
    --arg copyText12 "$copy_str_12" \
    '$arr + [{
      index: $index,
      label: $label,
      tz: $tz,
      city: $city,
      time: $time,
      time24: $time24,
      time12: $time12,
      ampm: $ampm,
      dayShort: $dayShort,
      dateShort: $dateShort,
      fullDate: $fullDate,
      utcOffset: $utcOffset,
      dayMarker: $dayMarker,
      offhours: $offhours,
      copyText: $copyText24,
      copyText24: $copyText24,
      copyText12: $copyText12
    }]')

  idx=$(( idx + 1 ))
done < "$ZONES_FILE"

jq -cn \
  --arg offsetExpr "$offset_trimmed" \
  --argjson offsetValid "$offset_valid" \
  --argjson use12h "$use_12h" \
  --arg localTime "$local_time" \
  --arg localDate "$local_date" \
  --argjson zones "$zones_json" \
  '{
    offsetExpr: $offsetExpr,
    offsetValid: $offsetValid,
    use12h: $use12h,
    localTime: $localTime,
    localDate: $localDate,
    zones: $zones
  }'
