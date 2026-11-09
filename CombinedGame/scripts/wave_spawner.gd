class_name WaveSpawner
extends Node

#fired when a wave begins and carries the number for the HUD
signal wave_started(number: int)
#fired when all enemies are cleared, upgrades happen after
signal wave_cleared(number: int)
#fired once all waves have been cleared
signal all_waves_cleared

#different enemy scenes.
@export var goblin: PackedScene 
@export var masked_orc: PackedScene
@export var orc_warrior: PackedScene
@export var spawn_interval: float = 0.5
#amount of seconds between the round ending and starting
@export var time_between_waves: float = 5.0
#minimum amount of pixels away from the player the enemies will spawn
@export var min_spawn_distance: float = 80.0
# Level 2 (dungeon2.tscn) sets this true for bigger, earlier-orc waves.
@export var hard_mode: bool = false

var waves: Array = []
#current wave
var wave_number := 0
#remaining enemies
var alive := 0 
#true if currently spawning in enemies
var spawning := false

func _ready() -> void:
	if hard_mode:
		# Level 2: bigger waves, orcs from wave 2, more warriors late.
		waves = [
			[[goblin, 5]],                                              # 1
			[[goblin, 6], [masked_orc, 1]],                             # 2  reward
			[[goblin, 5], [masked_orc, 3]],                             # 3
			[[goblin, 4], [masked_orc, 4], [orc_warrior, 1]],           # 4
			[[goblin, 3], [masked_orc, 4], [orc_warrior, 2]],           # 5  reward
			[[masked_orc, 5], [orc_warrior, 2]],                        # 6
			[[goblin, 5], [masked_orc, 4], [orc_warrior, 3]],           # 7  reward
			[[masked_orc, 6], [orc_warrior, 3]],                        # 8
			[[goblin, 4], [masked_orc, 5], [orc_warrior, 4]],           # 9
			[[masked_orc, 6], [orc_warrior, 4]],                        # 10 placeholder for the boss
		]
		return
	waves = [
		[[goblin, 3]],                                              # 1
		#[[goblin, 5]],                                              # 2  reward
		#[[goblin, 4], [masked_orc, 1]],                             # 3  tier 2 appears
		#[[goblin, 3], [masked_orc, 3]],                             # 4
		#[[goblin, 2], [masked_orc, 3], [orc_warrior, 1]],           # 5  tier 3, big reward
		#[[goblin, 4], [masked_orc, 3], [orc_warrior, 1]],           # 6
		#[[masked_orc, 4], [orc_warrior, 2]],                        # 7  shaman slot later
		#[[goblin, 4], [masked_orc, 4], [orc_warrior, 2]],           # 8
		#[[masked_orc, 4], [orc_warrior, 3]],                        # 9
		#[[goblin, 4], [masked_orc, 4], [orc_warrior, 3]],           # 10 placeholder for the boss
	]

func start() -> void:
	_next_wave()

func _next_wave() -> void:
	wave_number += 1
	wave_started.emit(wave_number)
	
	var queue: Array[PackedScene] = []
	
	for entry in waves[wave_number - 1]:
		
		var scene: PackedScene = entry[0]
		var count: int = entry[1]
		
		if scene == null:
			push_warning("WaveSpawner: wave %d has an empty enemy slot." % wave_number)
			continue
			
		for _i in count:
			queue.append(scene)
	
	#shuffle the list so that enemy types spawn in random order, ie not all goblins at once
	queue.shuffle()
	
	spawning = true
	
	for scene in queue:
		_spawn_enemy(scene)
		await get_tree().create_timer(spawn_interval).timeout
		if not is_inside_tree():
			return
	
	spawning = false
	_check_cleared()
		
func _spawn_enemy(scene: PackedScene) -> void:
	var enemy: Node2D = scene.instantiate()
	get_parent().add_child(enemy)
	
	#set the enemy to a set spawn point
	enemy.global_position = _pick_spawn_position()
	alive += 1
	
	#calls this func when an enemy dies ("exits" the tree)
	enemy.tree_exited.connect(_on_enemy_removed)
	
func _pick_spawn_position() -> Vector2:
	
	#stores all of the set spawn points
	var points := get_tree().get_nodes_in_group("spawn_point")
	#get the player node for knowing their position
	var player := get_tree().get_first_node_in_group("player") as Node2D
	
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
	if wave_number >= waves.size():
		all_waves_cleared.emit()
		return
	
	#wait for the amount of time stored in time_between_waves
	await get_tree().create_timer(time_between_waves).timeout
	
	#advance to the next wave only if we are still in the scene
	if is_inside_tree():
		_next_wave()
	
