# "extends Enemy" means this inherits everything from enemy.gd (health,
# knockback, contact damage, drops) and only adds or replaces things.
extends Enemy

# The bolt to fire. Drag projectile.tscn here in the Inspector.
@export var projectile_scene: PackedScene
# Backs away if the player is closer than this (pixels).
@export var min_distance: float = 60.0
# Walks closer if the player is farther than this.
@export var max_distance: float = 100.0
# Seconds between shots.
@export var fire_interval: float = 2.2
# Seconds the shaman glows and stands still before firing.
@export var windup_time: float = 0.5
# It won't start a shot if the player is farther away than this.
@export var fire_range: float = 140.0

# Countdown to the next shot.
var fire_timer := 0.0
# Time left in the current windup.
var windup_left := 0.0
# True while glowing and aiming.
var winding_up := false

func _ready() -> void:
	# Run the parent's _ready first (finds the player, connects death).
	# Overriding a function replaces it, so super._ready() is how you keep it.
	super._ready()
	# Randomize the first shot, so two shamans don't fire in sync.
	fire_timer = randf_range(1.0, fire_interval)

func _physics_process(delta: float) -> void:
	# Run the parent's movement and contact damage first.
	super._physics_process(delta)
	if not is_instance_valid(player):
		return

	# During the windup, count down and fire when it ends.
	if winding_up:
		windup_left -= delta
		if windup_left <= 0.0:
			_fire()
			_end_windup()
		return

	# Otherwise count down to the next shot. Only start one if the player is in range.
	fire_timer -= delta
	if fire_timer <= 0.0 and global_position.distance_to(player.global_position) <= fire_range:
		_start_windup()

# REPLACES the parent's chase behavior: keep a distance instead.
func _get_move_direction() -> Vector2:
	# Stand still while aiming, so the telegraph is readable.
	if winding_up:
		return Vector2.ZERO
	var to_player := player.global_position - global_position
	var distance := to_player.length()
	# Too close: walk directly away.
	if distance < min_distance:
		return -to_player.normalized()
	# Too far: walk toward the player.
	if distance > max_distance:
		return _direction_to(player.global_position)
	# In the comfortable range: stand and wait for the next shot.
	return Vector2.ZERO

func _start_windup() -> void:
	winding_up = true
	windup_left = windup_time
	# Tint the sprite gold as a warning. self_modulate is separate from the
	# red hit flash, so the two don't fight.
	sprite.self_modulate = Color(1.0, 0.8, 0.3)

func _end_windup() -> void:
	winding_up = false
	sprite.self_modulate = Color.WHITE
	# Start the countdown to the next shot.
	fire_timer = fire_interval

func _fire() -> void:
	# Do nothing if you forgot to assign the scene in the Inspector.
	if projectile_scene == null:
		return
	# Build the bolt. "as Projectile" lets us set its direction variable.
	var bolt := projectile_scene.instantiate() as Projectile
	# Start at the shaman. This works because the Dungeon sits at (0, 0).
	bolt.position = position
	# Aim at the player's position right now. It doesn't lead the target,
	# so sidestepping after the glow dodges it.
	bolt.direction = global_position.direction_to(player.global_position)
	get_parent().add_child(bolt)
