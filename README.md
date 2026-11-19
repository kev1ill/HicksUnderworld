# HicksUnderworld

### **Developers:** Kevin O'Neill, Collin Russell, Bushra Alhamadani

The player begins their quest for the Legendary K Cash on the K College campus quad. The player moves through a 2D pixel-art lobby modelled on the Weimer K. Hicks Center, walking into the building through the glass doors, and starts the game from the **Underworld** doors inside the lobby. Once the player has entered the **Underworld**, they are transported to the first dungeon. The player then fights their way through multiple waves of enemies in multiple 2D Roguelike style dungeons.

## Run it

1. Install **Godot 4.3** or newer (standard build, no .NET needed).
2. Project Manager → **Import** → pick `game/project.godot` → **Import & Edit**.
3. Press **F5** (Run Project).

## How to play

The player moves around the map using **WASD / arrow keys**. The player can interact with interactables by pressing E, and the player can attack using J, the space bar or by left clicking. The player can press the escape key at any point to open the pause menu.

## Flow

| Scene | What happens |
|---|---|
| `game/scenes/exterior.tscn` (main) | Campus quad in front of the Hicks Center. Walk into the front doors to go inside. |
| `game/scenes/lobby.tscn` | The lobby. Talk to the receptionist at the INFO desk, or press E at the glowing **Underworld** doors to open the lobby menu (name + Start Game). Walk out the bottom door to go back outside. |
| `game/scenes/dungeon.tscn` | The first dungeon where the player fights a series of orcs |

## Project layout

```
docs/         design docs (gdd.md)
game/         the Godot project (open game/project.godot)
  art/          pixel art (PNG) 
  fonts/        hicks_pixel.fnt – 5x7 bitmap font (all caps)
  scenes/       exterior, lobby, dungeon, player, ...
  scripts/      game.gd (autoload: input map, scene fades, player name), player.gd,
                interactable.gd, level.gd, hud.gd, lobby_panel.gd, ...
  ui/           hud.tscn, lobby_panel.tscn, theme.tres (orange/black pixel UI)
```
