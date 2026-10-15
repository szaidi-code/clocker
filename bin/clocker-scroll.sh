#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${CLOCKER_CONFIG_DIR:-$HOME/.config/clocker}"
ZONES_FILE="$CONFIG_DIR/zones.conf"
PLACEHOLDER="+5h, -90m, 15:00, tomorrow 9am"

prompt_input() {
  if command -v omarchy-menu-input >/dev/null 2>&1; then
    omarchy-menu-input "$PLACEHOLDER" --width 480 || true
  elif command -v walker >/dev/null 2>&1; then
    walker --dmenu -p "$PLACEHOLDER" < /dev/null || true
  elif command -v wofi >/dev/null 2>&1; then
    wofi --dmenu -p "$PLACEHOLDER" < /dev/null || true
  else
    echo "No supported launcher (omarchy-menu-input, walker, wofi) found" >&2
    return 1
  fi
}

prompt_select() {
  local title="$1"
  shift
  local items=("$@")
  if command -v omarchy-menu-select >/dev/null 2>&1; then
    omarchy-menu-select "$title" "${items[@]}" -- --width 480 || true
  elif command -v walker >/dev/null 2>&1; then
    printf '%s\n' "${items[@]}" | walker --dmenu -p "$title" || true
  elif command -v wofi >/dev/null 2>&1; then
    printf '%s\n' "${items[@]}" | wofi --dmenu -p "$title" || true
  else
    printf '%s\n' "${items[@]}"
  fi
}

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

is_relative_input() {
  local trimmed="$1"
  [[ "$trimmed" =~ ^[+-] ]]
}

compute_results() {
  local raw_input="$1"
  local trimmed="${raw_input#"${raw_input%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

  # Reject bare integer numbers (e.g. "12345") that GNU date might misinterpret
  if [[ -z "$trimmed" || "$trimmed" =~ ^[0-9]+$ ]]; then
    printf "Couldn't parse: %s\n" "$raw_input"
    return 1
  fi

  local normalized
  normalized=$(normalize_expr "$trimmed")

  local target_epoch
  if ! target_epoch=$(date -d "$normalized" +%s 2>/dev/null); then
    printf "Couldn't parse: %s\n" "$raw_input"
    return 1
  fi

  local suffix
  if is_relative_input "$trimmed"; then
    suffix="(${trimmed} from now)"
  else
    suffix="(${trimmed})"
  fi

  if [[ ! -f "$ZONES_FILE" ]]; then
    printf "Couldn't parse: missing %s\n" "$ZONES_FILE"
    return 1
  fi

  while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
    local line="${raw_line#"${raw_line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue

    local label="${line%%=*}"
    local tz="${line#*=}"
    label="${label#"${label%%[![:space:]]*}"}"
    label="${label%"${label##*[![:space:]]}"}"
    tz="${tz#"${tz%%[![:space:]]*}"}"
    tz="${tz%"${tz##*[![:space:]]}"}"
    [[ -z "$label" || -z "$tz" ]] && continue

    local formatted
    formatted=$(TZ="$tz" date -d "@$target_epoch" +"%a %H:%M")
    printf "%-4s %s  %s\n" "$label" "$formatted" "$suffix"
  done < "$ZONES_FILE"
  return 0
}

print_only=false
query_arg=""

while (( $# > 0 )); do
  case "$1" in
    --print|--query|-q)
      print_only=true
      shift
      if (( $# > 0 )); then
        query_arg="$1"
        shift
      fi
      ;;
    *)
      query_arg="$1"
      shift
      ;;
  esac
done

if [[ "$print_only" == true ]]; then
  compute_results "$query_arg" || true
  exit 0
fi

if [[ -z "$query_arg" ]]; then
  query_arg=$(prompt_input)
fi

# User cancelled prompt
if [[ -z "${query_arg// /}" ]]; then
  exit 0
fi

mapfile -t result_lines < <(compute_results "$query_arg" || true)

if (( ${#result_lines[@]} == 0 )); then
  result_lines=("Couldn't parse: $query_arg")
fi

# If input was invalid, show the single error line and exit 0
if [[ "${result_lines[0]}" == "Couldn't parse:"* ]]; then
  prompt_select "Clocker" "${result_lines[0]}" >/dev/null || true
  exit 0
fi

selected=$(prompt_select "Clocker ($query_arg)" "${result_lines[@]}")
if [[ -n "$selected" ]] && command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$selected" | wl-copy
fi
exit 0
