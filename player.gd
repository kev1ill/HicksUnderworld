extends CharacterBody2D

@export var speed: float = 80.0
@export var attack_cooldown: float = 0.35
@export var invulnerable_time: float = 0.8
@export var swing_arc: float = 1.2
@export var commit_time: float = 0.3
@export var commit_speed_multiplier: float = 0.3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var sword_pivot: Node2D = $SwordPivot
@onready var sword_hitbox: Area2D = $SwordPivot/Hitbox

var can_attack := true
var invulnerable := false
var dead := false
var knockback := Vector2.ZERO
var hit_this_swing: Array[Node] = []
var facing: String = "down" #remembers last direction for idle animation
var attack_dir := Vector2.DOWN
var committed := false

func _ready() -> void:
	add_to_group("player")
	sword_pivot.visible = false
	sword_hitbox.monitoring = false
	sword_hitbox.body_entered.connect(_on_sword_hit)
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if dead:
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_speed := speed * (commit_speed_multiplier if committed else 1.0)
	velocity = dir * move_speed + knockback
	knockback = knockback.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()
	
	#if |dir| > 0 sprite should not be idle
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			facing = "side"
			sprite.flip_h = dir.x < 0
			attack_dir = Vector2(signf(dir.x), 0.0)
		elif dir.y < 0:
			facing = "up"
			attack_dir = Vector2.UP
		else:
			facing = "down"
			attack_dir = Vector2.DOWN
		sprite.play("run_" + facing)
	else:
		sprite.play("idle_" + facing)
	
	if Input.is_action_just_pressed("attack") and can_attack:
		_attack()
		
func _attack() -> void:
	committed = true
	get_tree().create_timer(commit_time).timeout.connect(func(): committed = false)
	can_attack = false
	hit_this_swing.clear()
	var aim := attack_dir.angle()
	var base := aim + PI / 2.0 #sword sprite points up
	var sweep := -1.0 if attack_dir.x < 0.0 else 1.0
	sword_pivot.rotation = base - swing_arc * sweep
	sword_pivot.visible = true
	sword_hitbox.monitoring = true

	var tween := create_tween()
	tween.tween_property(sword_pivot, "rotation", base + swing_arc * sweep, 0.15)
	tween.tween_callback(_end_swing)
	get_tree().create_timer(attack_cooldown).timeout.connect(func(): can_attack = true)
	
func _end_swing() -> void:
	sword_pivot.visible = false
	sword_hitbox.monitoring = false
	
func _on_sword_hit(body: Node) -> void:
	if body in hit_this_swing:
		return
	hit_this_swing.append(body)
	if body.has_method("take_hit"):
		body.take_hit(1, global_position)
		
func take_hit(amount: int, from: Vector2) -> void:
	if invulnerable or dead:
		return
	invulnerable = true
	knockback = from.direction_to(global_position) * 160.0
	sprite.modulate = Color(1, 0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, invulnerable_time)
	tween.tween_callback(func(): invulnerable = false)
	health.take_damage(amount)
	
func _on_died() -> void:
	sprite.play("die")
	dead = true
	# "await" pauses this function until the timer finishes, without freezing
	# the game. Execution resumes here after 1 second.
	await get_tree().create_timer(1.25).timeout
	# Restart the whole scene from scratch.
	get_tree().reload_current_scene()
	
func heal(amount: int) -> bool:
	if dead:
		return false
	return health.heal(amount)
