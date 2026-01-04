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

usage() {
	cat <<'EOF'
Usage: ./dev_overhaul.sh [options] [-- gzdoom args...]

Options:
  --pack-only            Build PK3 only
  --run-only             Launch without rebuilding PK3
  --clean-config         Remove dev config before launch
  --iwad PATH            Set IWAD path
  --pb PATH              Set Project Brutality path
  --gzdoom CMD           Set GZDoom executable
  --config PATH          Set dev config path
  --pk3 NAME             Set PK3 name
  --src DIR              Set source dir
  --dist DIR             Set build dir
  --extra-file PATH      Load an extra file after the addon (repeatable)
  -h, --help             Show this help
EOF
}

PK3_NAME="${PK3_NAME:-pb_overhaul.pk3}"
SRC_DIR="${SRC_DIR:-pb_overhaul}"
DIST_DIR="${DIST_DIR:-build}"
PB_PATH="${PB_PATH:-Project_Brutality-PB_Staging}"
DEV_CONFIG="${DEV_CONFIG:-}"
IWAD_PATH="${IWAD_PATH:-}"
CLEAN_CONFIG="${CLEAN_CONFIG:-0}"

DEV_CONFIG_SET=0
if [ -n "$DEV_CONFIG" ]; then
	DEV_CONFIG_SET=1
fi

RUN_GZDOOM=1
PACK_PK3=1
declare -a EXTRA_FILES
declare -a PASSTHROUGH_ARGS
EXTRA_FILES=()
PASSTHROUGH_ARGS=()

while [ $# -gt 0 ]; do
	case "$1" in
		--pack-only)
			RUN_GZDOOM=0
			;;
		--run-only)
			PACK_PK3=0
			;;
		--clean-config)
			CLEAN_CONFIG=1
			;;
		--iwad)
			IWAD_PATH="${2:-}"
			shift
			;;
		--pb)
			PB_PATH="${2:-}"
			shift
			;;
		--gzdoom)
			GZDOOM_CMD="${2:-}"
			shift
			;;
		--config)
			DEV_CONFIG="${2:-}"
			DEV_CONFIG_SET=1
			shift
			;;
		--pk3)
			PK3_NAME="${2:-}"
			shift
			;;
		--src)
			SRC_DIR="${2:-}"
			shift
			;;
		--dist)
			DIST_DIR="${2:-}"
			shift
			;;
		--extra-file)
			EXTRA_FILES+=("${2:-}")
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		--)
			shift
			PASSTHROUGH_ARGS+=("$@")
			break
			;;
		*)
			PASSTHROUGH_ARGS+=("$1")
			;;
	esac
	shift
done

if [ "$DEV_CONFIG_SET" -eq 0 ]; then
	DEV_CONFIG="$DIST_DIR/dev-gzdoom.ini"
fi

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
	args+=(-file "$PB_PATH" "$PK3_PATH")
	if [ ${#EXTRA_FILES[@]} -gt 0 ]; then
		args+=("${EXTRA_FILES[@]}")
	fi
	if [ ${#PASSTHROUGH_ARGS[@]} -gt 0 ]; then
		args+=("${PASSTHROUGH_ARGS[@]}")
	fi
	"$GZDOOM_PATH" "${args[@]}"
}

if [ "$PACK_PK3" -eq 1 ]; then
	package
fi

if [ "$RUN_GZDOOM" -eq 1 ]; then
	if [ ! -f "$PK3_PATH" ]; then
		echo "PK3 not found: $PK3_PATH (run without --run-only or build it first)" >&2
		exit 1
	fi
	run_gzdoom
fi
