class_name Health
extends Node

signal changed(current: int, maximum: int)
signal died

@export var max_health: int = 6
var current: int
var player: CharacterBody2D = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current = max_health

func take_damage(amount: int) -> void:
	if current <= 0:
		return
	current = max(current - amount, 0)
	changed.emit(current, max_health)
	if current == 0:
		died.emit()

func heal(amount: int) -> bool:
	if (current <= 0 or current == max_health):
		return false
	
	current = min(amount + current, max_health)
	changed.emit(current, max_health)
	
	return true
	
#raises the max health and gives the player a health boost
func increase_max(amount: int) -> void:
	max_health += amount
	current += amount
	#send updated health to the HUD
	changed.emit(current, max_health)
