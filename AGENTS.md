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
- Keep addon ZScript in a unique path, e.g. `pb_overhaul/zscript_overhaul/HellsBells.zs`.
- Include addon scripts via `pb_overhaul/ZSCRIPT.txt`.

## Hell's Bells (PB Deagle Replacement)
- `PB_HellsBells` replaces `PB_Deagle` so map spawns and `give pb_deagle` yield Hell's Bells.
- Console give: `give pb_hellsbells`.
- Uses its own mag ammo classes (`HellsBellsAmmo`, `LeftHellsBellsAmmo`) while consuming `PB_LowCalMag` reserve.
- Magazine size is controlled by `pb_overhaul_hellsbells_mag` (7–20, chamber adds +1).

## Common Pitfalls
- Reusing PB file paths in the addon breaks PB includes and causes ZScript errors.
- `replaces` on the same class name crashes or errors (use a new class name).
- Cvar access without a valid player can cause VM aborts.

## Quick Test
```
./dev_overhaul.sh
```

## Controls Note
- Ensure `Reload` and `Weapon Special` are bound in GZDoom controls for testing reloads and dual wield toggle.

## Commits
- Group related changes into one commit with a clear, present-tense message.
- Do not commit Project Brutality sources.
