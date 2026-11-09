# Combined Game - Merge Notes

BushraGame (Hicks Center lobby) + KevinGameFolder (dungeon roguelike)
merged into this folder. The originals were left untouched.

## How to run

1. Godot 4.3+ (standard build, no .NET needed), Project Manager -> Import
   -> pick `project.godot` in this folder -> Import & Edit.
2. Press F5. Godot will re-import Kevin's assets on first open - that is normal.

## Flow

| Step | Scene | What happens |
|---|---|---|
| 1 | `scenes/exterior.tscn` (main scene) | Campus quad. Walk into the front doors. |
| 2 | `scenes/lobby.tscn` | Hicks lobby. Talk to the receptionist, or press E at the glowing GAME HALL doors, type a name, press Start. |
| 3 | `scenes/dungeon.tscn` | Kevin's dungeon. Waves of goblins / orcs, sword combat, rewards. Your lobby name shows in the welcome banner. Esc returns to the lobby. |

The hook is one line in `scripts/game.gd`:
`GAME_HALL` was `res://scenes/game_hall.tscn` (placeholder) and is now
`res://scenes/dungeon.tscn`. `scripts/lobby_panel.gd` already called
`Game.go_to(Game.GAME_HALL, "start")`, so no lobby UI change was needed.
`scenes/game_hall.tscn` is now unused and kept only as a placeholder.

## What was renamed (and why)

Both projects used the same paths for different things, so Kevin's
colliding files were renamed instead of overwriting Bushra's:

- `scenes/player.tscn` -> `scenes/dungeon_player.tscn`
  (`scripts/player.gd` -> `scripts/dungeon_player.gd`)
  Bushra's player is the lobby walker (run_* actions, interactables);
  Kevin's is the combat knight (move_* actions, sword, health).
- `scripts/hud.gd` -> `scripts/dungeon_hud.gd`
  Bushra's HUD is prompts / dialog; Kevin's is hearts / wave / banner.
- Everything else from Kevin was copied unchanged at the same `res://`
  paths: `assets/`, `resources/`, `floorC.tscn`, `wallC.tscn`,
  `scenes/dungeon.tscn`, `goblin.tscn`, `masked_orc.tscn`,
  `orc_warrior.tscn`, `health_flask.tscn`, and
  `scripts/dungeon.gd`, `enemy.gd`, `health.gd`, `health_flask.gd`,
  `reward_manager.gd`, `wave_spawner.gd`, `weapon_data.gd`
  (plus their `.uid` files).
- Not copied: Kevin's `project.godot`, the stray Bushra scene copies
  under Kevin's `scripts/` and `scripts/scenes/`, and Kevin's duplicate
  `art/` (identical to Bushra's). Kevin's `hicks_pixel.fnt` at the
  project root *was* copied, because `dungeon.tscn` references both
  `res://fonts/hicks_pixel.fnt` and `res://hicks_pixel.fnt`.

References were updated to match the renames:
`scenes/dungeon.tscn` now points at `dungeon_player.tscn` and
`dungeon_hud.gd`; `scenes/dungeon_player.tscn` now points at
`scripts/dungeon_player.gd`. The `.uid` values were kept, so Godot
still resolves them.

## project.godot

Bushra's `project.godot` had unresolved merge-conflict markers
(`<<<<<<< HEAD` / `>>>>>>>`) - it would not have loaded as-is.
This project uses the resolved lobby side from `project.godot.bak`
(main scene `exterior.tscn`, 320x180 viewport, GL Compatibility,
Game autoload, lobby theme), plus Kevin's inputs and physics layers:

- `run_*` - Bushra lobby movement (WASD / arrows)
- `move_*` - Kevin dungeon movement (WASD / arrows)
- `attack` - mouse click, Space, or J (dungeon sword)
- `interact` - E or Space (lobby doors / talking)
- Physics layers named world / player / enemy (from Kevin)

Viewport stays 320x180 like the lobby. That works for the dungeon
because Kevin's dungeon player already has a Camera2D that follows it.

## Small fixes made during the merge

- `scripts/dungeon.gd`: Esc (`ui_cancel`) now returns to the lobby
  (`Game.go_to(Game.LOBBY, "from_hall")`), and the dungeon shows
  `WELCOME, <name>!` from the name typed in the lobby.
- `scripts/wave_spawner.gd`: fixed the player lookup from group
  `"Player"` to `"player"` (the dungeon player joins `"player"`,
  lowercase - the old lookup always returned null, so enemies could
  spawn right on top of the player).

## Known behaviour (unchanged from Kevin's game)

- Dying in the dungeon restarts the dungeon scene (it does not go
  back to the lobby). Esc is the way back to the lobby while alive.
- The dungeon has no pause menu yet - Esc goes straight to the lobby.
- `scripts/game.gd` re-adds the `move_*` / `interact` input events
  at runtime even though they are now also in `project.godot`, so
  those actions may appear twice in the Input Map. That is harmless.
