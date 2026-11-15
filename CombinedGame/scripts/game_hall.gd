extends Node2D
## Placeholder for the actual game. Replace this scene with your gameplay;
## Game.player_name holds the name typed in the lobby.

@onready var welcome: Label = %Welcome
@onready var badge: Sprite2D = $Badge


func _ready() -> void:
	welcome.text = "WELCOME, %s!" % Game.player_name
	var t := create_tween().set_loops()
	t.tween_property(badge, "position:y", badge.position.y - 3, 0.8).set_trans(Tween.TRANS_SINE)
	t.tween_property(badge, "position:y", badge.position.y, 0.8).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Game.go_to(Game.LOBBY, "from_hall")
