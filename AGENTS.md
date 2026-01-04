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
- DECORATE-only properties (`Game`, `SpawnID`) are not valid in ZScript default blocks.
- ZScript state jumps must use `ResolveState(...)`, not `state(...)`.
- Frame code blocks must be attached to the frame line (no standalone `{ ... }` after a frame).
- `A_PlaySoundEx` is not available; use `A_StartSound`.
- Use instance properties like `AmmoGive1`, not `Weapon.AmmoGive1`, in methods.

## ZScript Porting Rules (GZDoom)

### 1) Inheritance and base classes
- Never inherit from DECORATE-only classes (e.g. `PB_RocketLauncher`).
- Before `class X : Y`, verify `Y` is a ZScript class, not a DECORATE actor.
- If porting:
  - Either rewrite the base class in ZScript, or
  - Inherit from a valid ZScript base (`Weapon`, `Actor`, `CustomInventory`, etc.).

### 2) State syntax
- Every state line must end with `;`.
- No standalone `{ ... }` blocks after state lines.
- Logic in states must be either inline on the frame line or moved into methods.

Example (invalid):
```
Spawn:
    TNT1 A 0
{
    DoSomething();
}
```

Example (valid):
```
Spawn:
    TNT1 A 0 { DoSomething(); }
    Loop;
```

### 3) State resolution by name
- Do not use `state("SomeState")` as a pointer (it is a string, not `State*`).
- Use `ResolveState("StateName")` for named transitions.
- Check the result for `null` before use.

Rule: Any named state transition must go through `ResolveState(...)`.

### 4) `default {}` actor properties
- Only use properties that exist in ZScript.
- Do not copy DECORATE-only properties into ZScript.

Forbidden in ZScript:
- `Game`
- `SpawnID`
- DECORATE-only flags without a ZScript equivalent

Before adding a property, confirm it exists in the ZScript API or parent class.

### 5) Sound functions
- Do not use DECORATE actions unless confirmed in ZScript.
- Use `A_StartSound(...)` or a known ZScript alternative.

Rule: If a function does not compile, treat it as DECORATE-only until proven otherwise.

### 6) Accessing weapon properties
- Inside class methods, do not prefix with `Weapon.` for own fields.

Invalid:
```
Weapon.AmmoGive1
```

Valid:
```
AmmoGive1
```

### 7) DECORATE → ZScript porting strategy
- Do not copy code mechanically.
- For each element, identify whether it is syntax, a property, or an action, and verify it exists in ZScript.
- If unsure:
  - Move logic into methods,
  - Replace actions with ZScript equivalents,
  - Verify with `-norun` before in-game testing.

### 8) Minimum self-check before claiming correctness
1. Base classes are valid ZScript classes.
2. `states` lines end with `;` and have no standalone `{ ... }` blocks.
3. Named state transitions use `ResolveState(...)`.
4. `default {}` contains no DECORATE-only properties.
5. Functions used are ZScript-accessible.
6. Class fields are accessed without invalid prefixes.

## Quick Test
```
./dev_overhaul.sh
```

## Controls Note
- Ensure `Reload` and `Weapon Special` are bound in GZDoom controls for testing reloads and dual wield toggle.

## Commits
- Group related changes into one commit with a clear, present-tense message.
- Do not commit Project Brutality sources.
