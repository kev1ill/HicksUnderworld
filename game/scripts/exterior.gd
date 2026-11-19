extends Level
## Campus quad in front of the Hicks Center. Walking into the glass doors
## takes the player inside to the lobby.


func _ready() -> void:
	super()
	$DoorTrigger.body_entered.connect(_on_door_entered)
	$World/Player.combat_enabled = false
	if not Game.shown_controls_hint:
		Game.shown_controls_hint = true
		hud.show_hint("WASD / ARROWS: MOVE    E: INTERACT")


func _on_door_entered(body: Node2D) -> void:
	if body is Player:
		Game.go_to(Game.LOBBY, "front_door")
