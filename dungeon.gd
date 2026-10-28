extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD._bind($Player/Health)
	
	$WaveSpawner.wave_started.connect($HUD.show_wave)
	$WaveSpawner.all_waves_cleared.connect(_on_victory)
	$WaveSpawner.start()

func _on_victory() -> void:
	$HUD.show_message("Dungeon Cleared!")
