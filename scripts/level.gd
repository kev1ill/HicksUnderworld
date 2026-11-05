class_name Level
extends Node2D
## Base for walkable scenes: puts the player on the spawn marker chosen by
## Game.spawn_id and shows the location banner.

@export var location_name := ""

@onready var player: Player = $World/Player
@onready var hud: Hud = $HUD


func _ready() -> void:
	var spawn := get_node_or_null("Spawns/" + Game.spawn_id) as Marker2D
	if spawn == null:
		spawn = $Spawns.get_child(0)
	player.global_position = spawn.global_position
	if location_name != "":
		hud.show_banner(location_name)
