# PB Overhaul

Addon mod for Project Brutality that will host configurable weapon/monster overrides and other adjustments.

## Structure

- `pb_overhaul/` — addon content (packed into `pb_overhaul.pk3`).
- `dev_overhaul.sh` — packs the addon and launches GZDoom with PB + addon.

## Quick Start

1. Ensure Project Brutality is available at `Project_Brutality-PB_Staging` (ignored by git).
2. Run the dev script:

```bash
./dev_overhaul.sh
```

Optional environment variables:

- `IWAD_PATH` — path to your IWAD (e.g. `doom2.wad`).
- `GZDOOM_CMD` — path to the GZDoom executable.
- `PB_PATH` — Project Brutality folder path.

## Current Features

- Project Brutality Overhaul menu with a placeholder screen.
- Deagle mag size slider (1–20, chamber adds +1).

Menu path:

```
Options -> Project Brutality Settings -> Project Brutality Overhaul
```

## Packaging

The script creates `build/pb_overhaul.pk3` from `pb_overhaul/` and launches:

```
<gzdoom> -file Project_Brutality-PB_Staging build/pb_overhaul.pk3
```

## Notes

- Project Brutality sources are not included in this repo.
- Load order matters: PB first, then this addon.
