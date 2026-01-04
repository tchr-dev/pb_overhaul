#!/usr/bin/env bash
set -euo pipefail

# Packs the pb_overhaul addon into a PK3 and launches GZDoom with Project Brutality.
# Optional env vars:
#   PK3_NAME   (default: pb_overhaul.pk3)
#   SRC_DIR    (default: pb_overhaul)
#   DIST_DIR   (default: build)
#   PB_PATH    (default: Project_Brutality-PB_Staging)
#   GZDOOM_CMD (default: gzdoom)
#   IWAD_PATH  (default: empty)
#   CLEAN_CONFIG (default: 0)
# Extra args passed to this script are forwarded to gzdoom.

PK3_NAME="${PK3_NAME:-pb_overhaul.pk3}"
SRC_DIR="${SRC_DIR:-pb_overhaul}"
DIST_DIR="${DIST_DIR:-build}"
PB_PATH="${PB_PATH:-Project_Brutality-PB_Staging}"
DEV_CONFIG="${DEV_CONFIG:-$DIST_DIR/dev-gzdoom.ini}"
IWAD_PATH="${IWAD_PATH:-}"
CLEAN_CONFIG="${CLEAN_CONFIG:-0}"
PK3_PATH="$DIST_DIR/$PK3_NAME"

resolve_gzdoom() {
	if [ -n "${GZDOOM_CMD:-}" ]; then
		echo "$GZDOOM_CMD"
		return
	fi

	if command -v gzdoom >/dev/null 2>&1; then
		command -v gzdoom
		return
	fi

	# Common macOS app bundle path.
	local mac_app="/Applications/GZDoom.app/Contents/MacOS/gzdoom"
	if [ -x "$mac_app" ]; then
		echo "$mac_app"
		return
	fi

	local home_app="$HOME/Applications/GZDoom.app/Contents/MacOS/gzdoom"
	if [ -x "$home_app" ]; then
		echo "$home_app"
		return
	fi

	echo ""
}

GZDOOM_PATH="$(resolve_gzdoom)"
if [ -z "$GZDOOM_PATH" ]; then
	echo "Could not find gzdoom. Set GZDOOM_CMD to the executable (e.g. /Applications/GZDoom.app/Contents/MacOS/gzdoom)." >&2
	exit 1
fi

package() {
	if [ ! -d "$SRC_DIR" ]; then
		echo "Source directory not found: $SRC_DIR" >&2
		exit 1
	fi

	mkdir -p "$DIST_DIR"
	if [ "$CLEAN_CONFIG" = "1" ] && [ -f "$DEV_CONFIG" ]; then
		rm -f "$DEV_CONFIG"
	fi
	if [ -f "$PK3_PATH" ]; then
		rm -f "$PK3_PATH"
	fi

	(
		cd "$SRC_DIR"
		zip -r "$PWD/../$PK3_PATH" . -x "*.DS_Store"
	)
}

run_gzdoom() {
	local args=()
	args+=(-config "$DEV_CONFIG")
	if [ -n "$IWAD_PATH" ]; then
		args+=(-iwad "$IWAD_PATH")
	fi
	"$GZDOOM_PATH" "${args[@]}" -file "$PB_PATH" "$PK3_PATH" "$@"
}

package
run_gzdoom "$@"
