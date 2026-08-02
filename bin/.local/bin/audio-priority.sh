#!/usr/bin/env bash
# Pick the audio output by priority: first connected device in PRIORITY wins.
# Falls through to WirePlumber's own choice (HDMI/analog) when none are present.
#
#   audio-priority.sh           apply once
#   audio-priority.sh --watch   apply, then re-apply on every device change
#
# Reorder PRIORITY to change preference. Match is on MAC address, so it works
# whether the sink shows up as bluez_output.AA:BB:.. or bluez_output.AA_BB_..

set -uo pipefail

PRIORITY=(
    "74:77:86:82:FF:80"  # AirPods Pro3 de Ale
    "AC:80:0A:1C:F0:78"  # WH-1000XM5
)

# Move already-playing streams to the new output. Set to 0 to leave per-app
# routing alone and only change where new streams land.
MOVE_EXISTING_STREAMS=1

norm() { printf '%s' "${1//:/_}" | tr '[:upper:]' '[:lower:]'; }

# Echo the sink name matching a MAC address, if that sink currently exists.
find_sink() {
    local want name
    want=$(norm "$1")
    while IFS=$'\t' read -r _ name _; do
        if [[ "$(norm "$name")" == *"$want"* ]]; then
            printf '%s\n' "$name"
            return 0
        fi
    done < <(pactl list short sinks)
    return 1
}

apply() {
    local addr target current idx
    target=""
    for addr in "${PRIORITY[@]}"; do
        if target=$(find_sink "$addr"); then
            break
        fi
        target=""
    done

    # Nothing preferred is connected: leave the default alone. WirePlumber
    # already falls back to the highest-priority wired output on its own.
    [[ -z "$target" ]] && return 0

    current=$(pactl get-default-sink 2>/dev/null) || current=""
    [[ "$current" == "$target" ]] && return 0

    pactl set-default-sink "$target" || return 1
    printf 'audio-priority: default sink -> %s\n' "$target"

    if [[ "$MOVE_EXISTING_STREAMS" == 1 ]]; then
        while IFS=$'\t' read -r idx _; do
            pactl move-sink-input "$idx" "$target" 2>/dev/null
        done < <(pactl list short sink-inputs)
    fi
}

if [[ "${1:-}" != "--watch" ]]; then
    apply
    exit $?
fi

apply

# Re-apply on device changes. A single connect emits a burst of events, so
# after the first one we drain until the stream has been quiet for a second.
# Only sink/card events are interesting; ignoring the rest keeps a noisy
# player from triggering us on every volume tick.
pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
        *"on sink"* | *"on card"* | *"on server"*) ;;
        *) continue ;;
    esac
    while read -r -t 1 _; do :; done
    apply
done
