class_name Player
extends CharacterBody2D
## Top-down player: 4-direction walk + sword attack (Space) using AnimatedSprite2D.
##
## Expected animations in the SpriteFrames resource:
##   idle_down, idle_right, idle_up
##   run_down,  run_right,  run_up
## Left is drawn by flipping the *_right animations horizontally.
##
## Optional (played if you add them, otherwise the attack just freezes movement):
##   attack_down, attack_right, attack_up   (turn Loop OFF for these)

enum Facing { DOWN, LEFT, RIGHT, UP }

@export var speed := 72.0
@export var attack_duration := 0.25  # seconds the player is locked in an attack
@export var art_faces_right := true  # false if your *_right animations actually look LEFT

var facing: int = Facing.DOWN

var _attacking := false
var _attack_t := 0.0
var _moving := false
var _nearby: Array[Interactable] = []
var _hud: Node

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_ensure_action("attack", KEY_SPACE)
	_ensure_action("interact", KEY_E)
	_update_sprite()


## Adds an input action bound to a key if it doesn't already exist in the Input Map.
func _ensure_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = keycode
		InputMap.action_add_event(action, ev)


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if not Game.ui_busy and not _attacking:
		dir = Input.get_vector("run_left", "run_right", "run_up", "run_down")
	velocity = dir * speed
	move_and_slide()

	# --- facing ---
	_moving = dir.length() > 0.1
	if _moving:
		if absf(dir.x) > absf(dir.y):
			facing = Facing.LEFT if dir.x < 0 else Facing.RIGHT
		else:
			facing = Facing.UP if dir.y < 0 else Facing.DOWN

	# --- attack ---
	if not _attacking and not Game.ui_busy and Input.is_action_just_pressed("attack"):
		_attacking = true
		_attack_t = 0.0

	if _attacking:
		_attack_t += delta
		if _attack_t >= attack_duration:
			_attacking = false
			_attack_t = 0.0

	_update_sprite()

	# --- interaction prompt ---
	var target := _current_target()
	if _hud == null:
		_hud = get_tree().get_first_node_in_group("hud")
	if _hud:
		_hud.set_prompt(target.prompt if target and not Game.ui_busy else "")
	if target and not Game.ui_busy and not _attacking and Input.is_action_just_pressed("interact"):
		target.interact()


func _update_sprite() -> void:
	var dir_name := "down"
	match facing:
		Facing.DOWN:
			dir_name = "down"
		Facing.UP:
			dir_name = "up"
		Facing.LEFT, Facing.RIGHT:
			dir_name = "right"

	# Flip for left (or invert if the art faces left by default)
	var want_left := facing == Facing.LEFT
	sprite.flip_h = want_left if art_faces_right else not want_left

	var state := "run" if _moving else "idle"
	var anim := "%s_%s" % [state, dir_name]

	if _attacking:
		var attack_anim := "attack_" + dir_name
		if sprite.sprite_frames.has_animation(attack_anim):
			anim = attack_anim

	if sprite.animation != anim:
		sprite.play(anim)
	elif not sprite.is_playing() and not anim.begins_with("attack"):
		sprite.play(anim)


func add_interactable(area: Interactable) -> void:
	if area not in _nearby:
		_nearby.append(area)


func remove_interactable(area: Interactable) -> void:
	_nearby.erase(area)


func _current_target() -> Interactable:
	var best: Interactable = null
	var best_d := INF
	for area in _nearby:
		var d := global_position.distance_squared_to(area.global_position)
		if d < best_d:
			best_d = d
			best = area
	return best
