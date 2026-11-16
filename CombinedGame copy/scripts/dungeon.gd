extends Node2D

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
	$HUD.show_banner("WELCOME, %s!" % Game.player_name)


func _unhandled_input(event: InputEvent) -> void:
	# Esc leaves the dungeon and returns to the Hicks lobby.
	if event.is_action_pressed("ui_cancel"):
		Game.go_to(Game.LOBBY, "from_hall")


func _on_victory() -> void:
	$HUD.show_message("Dungeon Cleared!")
