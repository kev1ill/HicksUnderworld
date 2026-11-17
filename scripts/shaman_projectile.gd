class_name Projectile
extends Area2D

@export var speed: float = 110.0
@export var damage: int = 1
@export var lifetime: float = 4.0

#set by the shaman before the bolt is added to the scene
var direction := Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Run _on_body_entered when the bolt touches a wall or the player.
	area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Fly in a straight line.
	position += direction * speed * delta
	# Count down the lifetime and delete at zero.
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		
func _on_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	# Walls have no take_hit, so only the player is hurt. The bolt is used up either way.
	if target.has_method("take_hit"):
		target.take_hit(damage, global_position)
	queue_free()

# Draws the bolt in code, so no sprite is needed: a dark outline circle
# with a bright green circle on top. The -8 y offset draws it at chest height,
# while the collision stays on the ground plane like every other character
# (their origin is at their feet).
func _draw() -> void:
	draw_circle(Vector2(0, -8), 4.0, Color(0.1, 0.2, 0.1))
	draw_circle(Vector2(0, -8), 3.0, Color(0.5, 1.0, 0.4))
	
# Called by the player's sword when it hits the deflect zone.
func destroy() -> void:
	# queue_free is safe to call from a physics callback, and calling it twice is harmless.
	queue_free()
