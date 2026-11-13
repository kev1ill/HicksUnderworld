class_name Projectile
extends Area2D

@export var speed: float = 110.0
@export var damage: int = 1
@export var lifetime: float = 4.0

#set by the shaman before the bolt is added to the scene
var direction := Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
