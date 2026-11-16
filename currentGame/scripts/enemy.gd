class_name Enemy
extends CharacterBody2D

#keeps track of which 'tier' in the hierarchy this enemy is
@export var tier: int = 1
@export var speed: float = 40.0
@export var contact_damage: int = 1
@export var hit_cooldown: float = 0.0
#handles how much to knockback, will change per enemy
@export var knockback_strength: float = 150.0
@export var speed_variance: float = 0.15
#How far from the player (in pixels) this enemy aims while still far away.
@export var flank_radius: float = 40.0
@export var drop_scene: PackedScene
@export var drop_chance: float = .1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var contact_area: Area2D = $ContactArea

var player: Node2D
var knockback := Vector2.ZERO
var cooldown := 0.0
var flank_angle := 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	health.died.connect(_on_died)
	
	speed *= randf_range(1.0 - speed_variance, 1.0 + speed_variance)
	#Pick a random side of the player to approach from (TAU is a full circle)
	flank_angle = randf() * TAU
	
func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var distance := global_position.distance_to(player.global_position)
	#1 when far away, shrinking to 0 as the enemy gets within about 24 pixels
	var offset_scale := clampf((distance - 24.0) / 80.0, 0.0, 1.0)
	#The aim point: the player's position plus an offset on this enemy's chosen side
	#As offset_scale shrinks, the aim point slides onto the player.
	var target := player.global_position + Vector2.from_angle(flank_angle) * flank_radius * offset_scale
	var dir := global_position.direction_to(target)
	velocity = dir * speed + knockback
	knockback = knockback.move_toward(Vector2.ZERO, 500.0 * delta)
	move_and_slide()
	
	#flip the enemy sprite if the player is to the left
	sprite.flip_h = player.global_position.x < global_position.x
	sprite.play("run")
	
	cooldown = max(cooldown - delta, 0.0)
	if cooldown == 0.0:
		for area in contact_area.get_overlapping_areas():
			var hurtbox_target := area.get_parent()
			if hurtbox_target.has_method("take_hit"):
				hurtbox_target.take_hit(contact_damage, global_position)
				cooldown = hit_cooldown

func take_hit(amount: int, from: Vector2) -> void:
	knockback = from.direction_to(global_position) * knockback_strength
	sprite.modulate = Color(1, .3, .3)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, .2)
	health.take_damage(amount)
	
func _on_died() -> void:
	if drop_scene != null and randf() < drop_chance:
		var drop := drop_scene.instantiate() as Node2D
		drop.position = position
		get_parent().add_child.call_deferred(drop)
	
	#removes the enemy from the scene tree
	queue_free()
	
