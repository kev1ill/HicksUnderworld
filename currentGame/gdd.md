# Game Design Document (GDD)
### Team's Project Template

## 1. Game Concept

**Working Title:**  The Hick's Underworld

**Genre:** 2D Roguelite

**Platform(s):**  PC

**Elevator Pitch (1-2 sentences):** A desperate Kalamazoo College student descends into the secret underground beneath Hicks Center in search of the legendary K-cash, only to uncover the weirdest, funniest, and most chaotic secrets the campus has been hiding for years. 

**Target Audience:** 

Kalamazoo College Students

## 2. Core Loop

The player spawns into a dungeon where they must eliminate enemies through either melee or projectile combat while avoiding traps. The enemy's goal is to eliminate the player. At certain score thresholds the player is rewarded with either an upgrade to health or combat ability. New, stronger enemies will appear with each wave. Each player has a starting health bar, each hit from an enemy does varying damage. The player can collect randomly generated items each wave to improve their stats or restore health. To advance to the next map the player needs to get a certain amount of score. When the player loses all of their health, they restart the game completely. 


## 3. Game Mechanics

**Player Actions (What can the player do?):**

Movement, Combat (Melee, projectile)

**Interactions (How do players interact with the game or characters? Controls setup?):**

Pick up items (potions for buffs and healing), attack enemies, progress to the next map

**Rules (What constraints or systems define the gameplay?):**

Health bar, cannot leave the map until enough score is accumulated

**Rewards (How does your game reward the players after completing tasks or in the gameplay? What kind of reward system do you envision?):**

Potions, level up system 

**Feedback (How does your game notifies the player? Audio-visual cues? Progress tracking via HUD? Positive/negative feedback?):**

visual and audio cues, HUD for health bar (health bar visually gets smaller), inventory, and score

---

## 4. Story & Narrative *(when applicable)*

**Premise (What is the story/world about?):**

A broke Kalamazoo College student ventures into the secret underground beneath Hicks Center to find the legendary K-cash, but the only way to reach it is to defeat the Guardians of Hicks, who protect the hidden treasure with absurd campus lore, strange powers, and a lot of attitude. 

**Main Characters:**

Dungeon raider (player), The Guardians of Hicks (bosses)

**Conflict/Goal (What drives the player?):**

Get all the legendary k-cash in the Hicks Underworld.

## 5. Level & World Design

**Setting/Theme:**

Dungeon under Hick's 

**Level Structure (linear, open world, hub-based?):**

Linear sequence of progression to new maps

**Tutorial/Onboarding (How will players learn mechanics?):**

Text instructions to explain the simple mechanics

**Progression (How does your game increase in difficulty or complexity?):**

new enemy types, stronger variants of existing enemies, bigger waves, and new maps with new trap types.

**Exploration/Challenges/Puzzles (if applicable):**

Explore stages, kill evil sprites, gain points, and move onto higher stages

## 6. Visual & Audio Style

**Art Style Reference (pixel art, 3D, realistic, low poly, etc.):**

16x16 pixel art, 2D top-down

**Color Palette:**

a dark, muted dungeon base (deep blues and grays) with one or two bright accent colors reserved for pickups, K-cash, and danger, so the important things pop.

**Music/Audio Resources (to complement the theme of your game):**

moody, slightly goofy chiptune that contrasts with the comedy.

---

## 7. User Interface (UI/UX)

**HUD (Heads-Up Display) Elements (health, score, minimap, progress tracking, etc.):**

Health bar, player inventory, score, current buffs 

**Menus (main, pause, inventory, etc.):**

Inventory, pause menu, settings menu, 

**Accessibility Features (if any):**
None at this moment 
---

## 8. Technical Requirements

**Engine:**

Godot

**Programming Language(s):**

GDscript

**Tools for Assets (art, sound, etc.):**

art from https://0x72.itch.io/dungeontileset-ii

**Deployment Platform (PC build, web, mobile, etc.):**

PC

## 9. Development Plan 

*Proposed Work Schedule: Describe here what your team will work on each week for the remainder of the term. This should function as a schedule or work plan to be followed and successfully develop your game prototype*:

W3: Begin developing prototypes to better understand godot and explore ideas for our official game.

W4: Finish the initial GDD, continue looking into implementing game mechanics such as health, combat, items and buffs

W5: Begin collaborating on the official project, begin level design process

W6:	Player movement, melee + projectile combat, first enemy type

W7:	Score system, wave spawning, item drops, HUD

W8:	Map 1 complete with tutorial text; exit and progression logic

W9:	Maps 2–3, new enemies and traps, level-up rewards
