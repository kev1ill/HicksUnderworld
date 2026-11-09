class_name Interactable
extends Area2D
## Drop this on an Area2D. When the player stands inside it, the HUD shows
## `prompt`; pressing interact (E / Space / pad A) emits `interacted`.

signal interacted

@export var prompt := "E: INTERACT"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interact() -> void:
	interacted.emit()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_interactable(self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.remove_interactable(self)
