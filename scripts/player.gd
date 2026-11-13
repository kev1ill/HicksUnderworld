class_name Player
extends CharacterBody2D
## Dungeon player (sword, health, buffs) plus the intro's interaction system.
## Requires: the Game autoload (ui_busy), the Interactable class, and an
## optional node in group "hud" that has set_prompt(text).

@export var speed: float = 80.0
@export var invulnerable_time: float = 0.8
@export var commit_time: float = 0.3
@export var commit_speed_multiplier: float = 0.3
## Turn this off on the player instance in areas where swinging the sword
## shouldn't be allowed (for example the intro).
@export var combat_enabled := true
#how many pixels higher the sword pivot sits when attacking upwards
@export var up_swing_lift: float = 10.0


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var sword_pivot: Node2D = $SwordPivot
@onready var sword_hitbox: Area2D = $SwordPivot/Hitbox
@onready var sword_sprite: Sprite2D = $SwordPivot/Sprite2D
@onready var sword_shape: CollisionShape2D = $SwordPivot/Hitbox/CollisionShape2D

var can_attack := true
var invulnerable := false
var dead := false
var knockback := Vector2.ZERO
var hit_this_swing: Array[Node] = []
var facing: String = "down" #remembers last direction for idle animation
var attack_dir := Vector2.DOWN
var committed := false #for slowing player movement during their attack
#Damage per hit from the current weapon, set by equip_weapon
var weapon_damage: int = 1
#Speed multiplier from buffs
var speed_buff := 1.0
#Counts buffs, so an older buff's timer can't cancel a newer one
var _buff_id := 0
var attack_cooldown: float = 0.35
var swing_arc: float = 1.2
#the pivots normal position remembered from the scene so we can restore it
var pivot_home := Vector2.ZERO

# --- interaction (ported from the intro player) ---
var _nearby: Array[Interactable] = []
var _hud: Node


func _ready() -> void:
	add_to_group("player")
	_ensure_action("attack", KEY_SPACE)
	_ensure_action("interact", KEY_E)
	sword_pivot.visible = false
	sword_hitbox.monitoring = false

	sword_hitbox.body_entered.connect(_on_sword_hit)
	health.died.connect(_on_died)
	
	pivot_home = sword_pivot.position


## Adds an input action bound to a key if it doesn't already exist in the Input Map.
func _ensure_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = keycode
		InputMap.action_add_event(action, ev)


func _physics_process(delta: float) -> void:
	if dead:
		return
	var busy: bool = Game.ui_busy

	var dir := Vector2.ZERO
	if not busy:
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_speed := speed * speed_buff * (commit_speed_multiplier if committed else 1.0)
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

	if combat_enabled and not busy and can_attack and Input.is_action_just_pressed("attack"):
		_attack()

	_update_interaction(busy)


func _update_interaction(busy: bool) -> void:
	var target := _current_target()
	if not is_instance_valid(_hud):
		_hud = get_tree().get_first_node_in_group("hud")
	if _hud:
		_hud.set_prompt(target.prompt if target and not busy else "")
	if target and not busy and not committed and Input.is_action_just_pressed("interact"):
		target.interact()


func add_interactable(area: Interactable) -> void:
	if area not in _nearby:
		_nearby.append(area)


func remove_interactable(area: Interactable) -> void:
	_nearby.erase(area)


func _current_target() -> Interactable:
	var best: Interactable = null
	var best_d := INF
	for area in _nearby:
		if not is_instance_valid(area):
			continue
		var d := global_position.distance_squared_to(area.global_position)
		if d < best_d:
			best_d = d
			best = area
	return best


func _attack() -> void:
	sword_pivot.position = pivot_home
	if attack_dir.y < -.5:
		sword_pivot.position.y -= up_swing_lift
	committed = true
	get_tree().create_timer(commit_time).timeout.connect(func(): committed = false)
	can_attack = false
	hit_this_swing.clear()
	var aim := attack_dir.angle()
	var base := aim + PI / 2.0 #sword sprite points up
	var sweep := -1.0 if attack_dir.x < 0.0 else 1.0 #making sure the sword sweep is consistent facing both left and right
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
		body.take_hit(weapon_damage, global_position)


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
	# the game. Execution resumes here after 1.25 seconds.
	await get_tree().create_timer(1.25).timeout
	
	#Restart the whole scene from scratch.
	#get_tree().reload_current_scene()
	
	Game.go_to(Game.LOBBY, "from_hall")


func heal(amount: int) -> bool:
	if dead:
		return false
	return health.heal(amount)


#Applies a weapondata to the player
func equip_weapon(data: WeaponData) -> void:
	swing_arc = data.swing_arc
	attack_cooldown = data.cooldown
	weapon_damage = data.damage
	sword_sprite.texture = data.texture
	#the offset keeps the handle at the pivot, it moves the image up by half its height, so its bottom edge sits at the origin
	sword_sprite.offset = Vector2(0.0, -data.texture.get_height() / 2.0)
	#Resize the hitbox, set its length, then center it along the blade.
	var rect := sword_shape.shape as RectangleShape2D
	rect.size.y = data.reach
	sword_shape.position.y = -data.reach / 2.0 - 2.0


func apply_speed_buff(multiplier: float, duration: float) -> void:
	speed_buff = multiplier
	#tint the knight blue while buffed
	sprite.self_modulate = Color(.6, .85, 1.0)

	_buff_id += 1
	var my_id := _buff_id

	#end the buff after 'duration', only reset if no newer buff has since started
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if my_id == _buff_id:
			speed_buff = 1.0
			sprite.self_modulate = Color.WHITE
	)
