class_name WaveSpawner
extends Node

#fired when a wave begins and carries the number for the HUD
signal wave_started(number: int)
#fired when all enemies are cleared, upgrades happen after
signal wave_cleared(number: int)
#fired once all waves have been cleared
signal all_waves_cleared

#holds the different scenes for the different enemies
@export var enemy_scenes: Array[PackedScene] = []
#amount of enemies spawned on wave 1
@export var wave1_size: int = 4
#amount of new enemies each wave
@export var growth_per_wave: int = 3
#amount of waves for this dungeon
@export var max_waves: int = 5
#amount of time (seconds) between each enemy spawning
@export var spawn_interval: float = 0.5
#amount of seconds between the round ending and starting
@export var time_between_waves: float = 5.0
#minimum amount of pixels away from the player the enemies will spawn
@export var min_spawn_distance: float = 80.0

#current wave
var wave_number := 0
#remaining enemies
var alive := 0 
#true if currently spawning in enemies
var spawning := false

func start() -> void:
	_next_wave()

func _next_wave() -> void:
	wave_number += 1
	wave_started.emit(wave_number)
	
	#wave 1 = 4 enemies, wave 2 = 7, and so on
	var count := wave1_size + (wave_number - 1) * growth_per_wave
	
	spawning = true
	
	for i in count:
		#Spawn an enemy	
		_spawn_enemy()
		#Pause this function for spawn_interval seconds without freezing the game.
		await get_tree().create_timer(spawn_interval).timeout
		#If the scene was reloaded while we waited (player died), stop here.
		if not is_inside_tree():
			return
		#Done creating enemies for this wave.
		spawning = false
		#In case every enemy is already dead, check whether the wave is over.
		_check_cleared()
		
func _spawn_enemy() -> void:
	if enemy_scenes.is_empty():
		push_warning("Spawner has no enemies assigned")
		return
	
	var scene : PackedScene = enemy_scenes.pick_random()
	#create an enemy from enemy scenes list
	var enemy : Node2D = scene.instantiate()
	#instantiate the enemy
	get_parent().add_child(enemy)
	
	#set the enemy to a set spawn point
	enemy.global_position = _pick_spawn_position()
	alive += 1
	
	#calls this func when an enemy "exits" the tree
	enemy.tree_exited.connect(_on_enemy_removed)
	
func _pick_spawn_position() -> Vector2:
	
	#stores all of the set spawn points
	var points := get_tree().get_nodes_in_group("spawn_point")
	#get the player node for knowing their position
	var player := get_tree().get_first_node_in_group("Player") as Node2D
	
	#filters all of the possible spawn points to make sure only valid ones are included
	var valid: Array = points.filter(func(p: Node2D) -> bool:
		return player == null or p.global_position.distance_to(player.global_position) >= min_spawn_distance
		)
	
	#if no valid points, then fall back to the original list
	if valid.is_empty():
		valid = points
	
	#pick a random valid point
	var marker: Node2D = valid.pick_random()
	
	#create some random offset so that enemies spawning in the same spot dont stack on top of each other
	return marker.global_position + Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
	
func _on_enemy_removed() -> void:
	if not is_inside_tree():
		return
		
	alive -=1
	_check_cleared()

func _check_cleared() -> void:
	if spawning or alive > 0:
		return
	
	#the wave is over
	wave_cleared.emit(wave_number)
	if wave_number >= max_waves:
		all_waves_cleared.emit()
		return
	
	#wait for the amount of time stored in time_between_waves
	await get_tree().create_timer(time_between_waves).timeout
	
	#advance to the next wave only if we are still in the scene
	if is_inside_tree():
		_next_wave()
	
