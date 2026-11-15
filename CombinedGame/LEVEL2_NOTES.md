# Level 2 - The Deep Halls (`scenes/dungeon2.tscn`)

## How you get there

Lobby -> Level 1 (`scenes/dungeon.tscn`, 10 waves) -> on clearing
wave 10, "Level Cleared! Descending deeper..." -> Level 2 -> on
clearing wave 10 there, "Dungeon Cleared!" -> back to the lobby.
Esc in either level returns to the lobby. Dying restarts the
current level (your weapon / health carry-over is kept).

Your weapon and max-health upgrades from Level 1 carry into
Level 2. They are saved in the `Game` autoload
(`dungeon_weapon_index`, `dungeon_health_bonus`) when Level 1 is
cleared, restored by `RewardManager.setup()`, and reset when a
new game starts from the lobby panel.

## The map

Built on the same `floorC.tscn` / `wallC.tscn` base as Level 1
(the big floor and wall layers are unchanged in `dungeon2.tscn`).
The playable arena is the inline `Floor` / `Wall` TileMapLayers,
redesigned to 40 x 26 tiles (640 x 416 px, tile = 16 px):

```
# = wall    . = floor    P = player start    S = enemy spawn
########################################
#......................................#
#..S................................S..#
#...##...........................##....#
#...##...........................##....#
#......................................#
#.........S...................S........#
#..................##..................#
#..................##..................#
#......................................#
#......................................#
########......############......########
#......................................#
#......................................#
#......................................#
#......................................#
#......S............#............S.....#
#...........##......#......##..........#
#.......####........#........####......#
#...##..............#............##....#
#...##...........................##....#
#......................................#
#...................#..................#
#..S..............P.#...............S..#
#......................................#
########################################
```

Design ideas, in order of importance:

- **Open, not a maze.** Every floor tile is reachable from the
  player start (checked with a flood fill when the map was
  generated). No sealed rooms - enemies chase in a straight line
  with no pathfinding, so a sealed room would trap them.
- **A middle divider with two wide gaps** (the `########` row).
  It splits the map into a north and a south half and creates
  two choke points, without ever fully blocking the player.
- **Pillars and cover.** 2x2 pillar blocks in the four corners
  of the arena, a central pillar in the north half, and low
  cover bars in the south half, so you can break line of
  contact and kite enemies around something.
- **A split south half.** A vertical wall with one gap divides
  the south half into east / west, so the bottom area is not
  just one empty room.
- **8 spawn points** spread to all four corners and the middle
  of each half, all at least 80 px from the player start, so
  waves come at you from different directions.

The player starts at the south entrance, tile (-2, 10).
The dungeon player's Camera2D follows you, so the 320x180
viewport shows one part of the arena at a time.

## Difficulty (`scripts/wave_spawner.gd`, `hard_mode = true`)

Level 2 uses the same 10-wave structure, but harder:

| Wave | Level 1 | Level 2 |
|---|---|---|
| 1 | 3 goblins | 5 goblins |
| 2 | 5 goblins | 6 goblins + 1 masked orc |
| 3 | 4 goblins + 1 orc | 5 goblins + 3 orcs |
| 5 | 2 goblins + 3 orcs + 1 warrior | 3 goblins + 4 orcs + 2 warriors |
| 10 | 4 goblins + 4 orcs + 3 warriors | 6 orcs + 4 warriors |

Spawning is also faster in Level 2 (`spawn_interval` 0.35s
instead of 0.5s, `time_between_waves` 3s instead of 5s).
Rewards still happen on waves 2, 5 and 7, same as Level 1.

## Files that make Level 2 work

- `scenes/dungeon2.tscn` - the level. Copy of `dungeon.tscn`
  with a new scene uid, new Floor/Wall tile data, 8 spawn
  points, player start at the south entrance, and
  `hard_mode = true` on the WaveSpawner.
- `scripts/dungeon.gd` - now has `next_level_scene` and
  `level_title` exports. Level 1 sets `next_level_scene` to
  `res://scenes/dungeon2.tscn`; Level 2 leaves it empty.
- `scripts/wave_spawner.gd` - `hard_mode` picks the harder
  wave table above.
- `scripts/reward_manager.gd` + `scripts/game.gd` +
  `scripts/lobby_panel.gd` - weapon / health carry-over
  between levels, reset on a new game.

## Tweaking it in the editor

Open `dungeon2.tscn` in Godot, select the `Floor` or `Wall`
TileMapLayer, and paint with the TileMap panel - the tilesets
are the same ones Level 1 uses. If you move the player start
or a spawn point, keep it on a floor tile, and keep spawn
points at least 5 tiles from the player start or the
WaveSpawner will ignore the distance filter. To change the
waves, edit the `hard_mode` table in `wave_spawner.gd`.
