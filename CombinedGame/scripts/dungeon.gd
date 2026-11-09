extends Node2D
## One dungeon level. Level 1 (dungeon.tscn) advances to Level 2
## (dungeon2.tscn) on victory; Level 2 (next_level_scene == "")
## returns to the lobby instead.

@export var next_level_scene: String = ""
@export var level_title: String = "LEVEL 1 - THE HICKS UNDERWORLD"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD._bind($Player/Health)
	
	#give the manager the player and equip the starting sword
	$RewardManager.setup($Player)
	$WaveSpawner.wave_started.connect($HUD.show_wave)
	#when the wave is cleared the manager decides on a reward/message
	$WaveSpawner.wave_cleared.connect($RewardManager.on_wave_cleared)
	#shows the banner when a reward is given
	$RewardManager.reward_given.connect($HUD.show_banner)
	#sends the victory message if all of the waves have been cleared
	$WaveSpawner.all_waves_cleared.connect(_on_victory)
	#start the wave spawner
	$WaveSpawner.start()
	# Name typed in the Hicks lobby, carried over by the Game autoload.
	$HUD.show_banner("%s\nWELCOME, %s!" % [level_title, Game.player_name])


func _unhandled_input(event: InputEvent) -> void:
	# Esc leaves the dungeon and returns to the Hicks lobby.
	if event.is_action_pressed("ui_cancel"):
		Game.go_to(Game.LOBBY, "from_hall")


func _on_victory() -> void:
	if next_level_scene != "":
		# Carry the weapon and health upgrades into the next level.
		Game.dungeon_weapon_index = $RewardManager.weapon_index
		Game.dungeon_health_bonus = maxi($Player/Health.max_health - 6, 0)
		$HUD.show_message("Level Cleared!\nDescending deeper...")
		await get_tree().create_timer(2.0).timeout
		if is_inside_tree():
			Game.go_to(next_level_scene, "start")
		return
	$HUD.show_message("Dungeon Cleared!")
	# Final level: reset progress and head back to the lobby.
	Game.dungeon_weapon_index = 0
	Game.dungeon_health_bonus = 0
	await get_tree().create_timer(2.5).timeout
	if is_inside_tree():
		Game.go_to(Game.LOBBY, "from_hall")
