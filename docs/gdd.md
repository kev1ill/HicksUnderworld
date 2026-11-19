# Game Design Document (GDD)

## 1. Game Concept

**Working Title:**  The Hicks Underworld

**Genre:** 2D Roguelike

**Platform(s):**  PC

**Elevator Pitch:** A desperate Kalamazoo College student descends into the secret underground beneath Hicks Center in search of the legendary K-cash, only to uncover the weirdest, funniest, and most chaotic secrets the campus has been hiding for years. 

**Target Audience:** Kalamazoo College Students and gamers who enjoy a difficult, Roguelike experience.

## 2. Core Loop

The player spawns into a dungeon where they must eliminate enemies through melee combat while avoiding enemy attacks. The enemy's goal is to eliminate the player. At certain wave thresholds the player is rewarded with an upgrade to health and weapon; however, there is a small chance the player will not receive a weapon upgrade and will instead be rewarded with a speed buff, health is always upgraded at each reward. New, stronger enemies will appear with each wave. Each player has a starting health bar, each hit from an enemy does varying damage. The player can collect randomly generated health flasks each wave to restore health. To advance to the next dungeon the player needs to defeat every wave in the given dungeon. When the player loses all of their health, they restart the game completely.

## 3. Game Mechanics

**Player Actions:**

The player can move up, down, left, right and diagonally given there is not a collision object in the way. The player enagages in combat by swinging their sword in whatever direction they are facing.

**Interactions:**

Players can pick up items (potions for healing) simply by touching the health flask. Players can also interact with interactable objects like the Underworld Door and the receptionist by pressing E when in proximity.

**Rules:**

The player is constrained by their health bar, meaning that when enemies have inflicted enough damage, the player must restart. The player cannot leave the map until every wave has been defeated. When attacking, the player faces a cooldown time where they cannot attack and their movement speed is slowed. The player can only heal up to their current max health, meaning that trying to use a health flask at full health does nothing and the flask remains on the ground.

**Rewards:**

The player receives an increase to their max health (one heart) at every reward interval. The player has a large chance to increase their weapon by one tier, a small chance to go up two tiers, and an even smaller chance to receive a speed boost and not receive any weapon upgrade. The player also gets one heart of health restored at each upgrade, and health flasks that restore one heart drop at random from enemies. The more 'powerful' the enemy, the higher the chance of a health flask dropping. Also, when a player enters a new dungeon, their health is fully restored.

**Feedback:**

The HUD provides feedback to the player by showing the health bar. Empty hearts represent health that has been lost, and full/half hearts represent health the player currently has. The HUD also shows the current wave and the current weapon the player has. The HUD constantly updates to provide feedback to the player. Visually, the player's sprite tints red when taking damage, and the same goes for enemies. The player's sprite tints blue when a speed buff is active. The orc shaman tints yellow when it is charging a shot, so the player knows what is coming. Our game also includes audio cues for taking damage, hitting enemies and picking up health flasks.

---

## 4. Story & Narrative

**Premise:**

A broke Kalamazoo College student ventures into the secret underground beneath Hicks Center to find the legendary K-cash, but the only way to reach it is to defeat the Guardians of Hicks, who protect the hidden treasure with absurd campus lore, strange powers, and a lot of attitude. 

**Main Characters:**

K Student (player), The Guardians of Hicks (enemies)

**Conflict/Goal (What drives the player?):**

In order to achieve the goal of getting the Legendary K-Cash in the Hicks Underworld, the player must defeat all of the enemies that stand in their way.

## 5. Level & World Design

**Setting/Theme:**

The setting for this game is the K College campus; however, the player spends the majority of their time in the multiple dungeons under Hicks 

**Level Structure):**

The beginning of the game (exterior and lobby scenes) function as a small open world map. The main section of the game is a linear sequence of progression to new dungeons after defeating the prior dungeon.

**Tutorial/Onboarding:**

The opening scene features text instructions to explain the simple mechanics.

**Progression:**

The game gets progressively harder by introducing new enemy types, bigger waves and new dungeon layouts.

## 6. Visual & Audio Style

**Art Style Reference:**

16x16 pixel art, 2D top-down

**Color Palette:**

 A dark, muted dungeon base (deep blues and grays) with one or two bright accent colors reserved for pickups and danger, so the important things pop.

**Music/Audio Resources:**

A moody, slightly goofy chiptune that contrasts with the comedy.

---

## 7. User Interface (UI/UX)

**HUD:**

Health bar in the top left, current wave below that and the current weapon just below the wave label. 

**Menus:**

Pause menu featured in all playable scenes: resume button, music toggle button, quit to campus button and quit game button

The lobby panel shows just before the player enters the first dungeon: Textbox for player to set their name, back button and start button

**Accessibility Features:**

The player has the ability to toggle music on and off. The player receives both audio and visual cues when taking and receiving damage. Large font sizes.

---

## 8. Technical Requirements

**Engine:**

Godot

**Programming Language(s):**

GDscript

**Tools for Assets:**

art from https://0x72.itch.io/dungeontileset-ii

audio from https://schniersky.itch.io/bitcade-free-sfx-pack

**Deployment Platform:**

Web for desktop
