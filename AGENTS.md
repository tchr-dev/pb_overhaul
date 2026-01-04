# PB Overhaul – Working Approach Summary

## Project Structure
- `Project_Brutality-PB_Staging/` is the upstream mod. Do not edit this folder.
- `pb_overhaul/` is the addon folder that gets packed into `pb_overhaul.pk3`.
- `dev_overhaul.sh` builds the PK3 and launches GZDoom with PB + addon.

## Load Order
Always load Project Brutality first, then the addon:
```
gzdoom -file Project_Brutality-PB_Staging build/pb_overhaul.pk3
```

## Menu Injection
- Use `pb_overhaul/MENUDEF.txt` to add entries to PB menus.
- Overhaul menu is injected into `PBSettings` and placed after Gearbox.
- Current path: `Options -> Project Brutality Settings -> Project Brutality Overhaul`.

## ZScript Addon Rules (Avoid Collisions)
- Do NOT place addon files at the same path as PB includes (e.g. `zscript/Weapons/Slot2/Deagle.zs`), or PB will include the addon file instead and break.
- Keep addon ZScript in a unique path, e.g. `pb_overhaul/zscript_overhaul/Deagle.zs`.
- Include addon scripts via `pb_overhaul/ZSCRIPT.txt`.

## Deagle Mag Size Implementation (Working)
- `pb_overhaul/CVARINFO` defines `pb_overhaul_deagle_mag` (default 7).
- `pb_overhaul/zscript_overhaul/Deagle.zs` replaces `PB_Deagle` with a subclass and updates reload logic to use the cvar.
- Helper functions used in states must be `action` functions.
- Cvar access should be guarded:
  - Use `let p = player;` and `Cvar.GetCvar("pb_overhaul_deagle_mag", p)`.
  - If `p` or cvar is null, return the default (7).
- Slider range is 1–20 in `pb_overhaul/MENUDEF.txt`.

## Ammo Max for Larger Mags (DECORATE)
- Use `pb_overhaul/DECORATE` to replace ammo max for `DeagleAmmo` and `LeftDeagleAmmo`.
- Replacement classes must have new names:
  - `ACTOR PB_Overhaul_DeagleAmmo : Ammo replaces DeagleAmmo`
  - `ACTOR PB_Overhaul_LeftDeagleAmmo : Ammo replaces LeftDeagleAmmo`
- Do not attempt `replaces` with the same class name.

## Common Pitfalls
- Reusing PB file paths in the addon breaks PB includes and causes ZScript errors.
- `replaces` on the same class name crashes or errors (use a new class name).
- Cvar access without a valid player can cause VM aborts.

## Quick Test
```
./dev_overhaul.sh
```
