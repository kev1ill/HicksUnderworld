extends Area2D

@export var heal_amount: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("heal") and body.heal(heal_amount):
			queue_free()
			return
			
