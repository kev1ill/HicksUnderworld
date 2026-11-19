extends Level
## Inside the Hicks Center. The Game Hall doors open the lobby panel where the
## player enters a name and starts the game.

@onready var lobby_panel: LobbyPanel = $LobbyPanel
@onready var arrow: Sprite2D = $Decor/Arrow
@onready var door_glow: Sprite2D = $Decor/DoorGlow
@onready var receptionist: Sprite2D = $World/Receptionist


func _ready() -> void:
	super()
	$HallDoor.interacted.connect(lobby_panel.open)
	$InfoDesk.interacted.connect(_talk_to_receptionist)
	$ExitDoor.body_entered.connect(_on_exit)
	$World/Player.combat_enabled = false
	_start_idle_animations()


func _talk_to_receptionist() -> void:
	await hud.say("RECEPTIONIST", [
		"WELCOME TO THE WEIMER K. HICKS CENTER!",
		"THE HICKS UNDERWORLD IS THROUGH THE BIG DOORS AT THE BACK. WALK UP TO THEM AND PRESS E.",
		"YOU CAN PICK A NAME BEFORE YOU START. ENTER AT YOUR OWN RISK!",
	])


func _on_exit(body: Node2D) -> void:
	if body is Player:
		Game.go_to(Game.EXTERIOR, "from_lobby")


func _start_idle_animations() -> void:
	var bob := create_tween().set_loops()
	bob.tween_property(arrow, "position:y", arrow.position.y + 2, 0.45).set_trans(Tween.TRANS_SINE)
	bob.tween_property(arrow, "position:y", arrow.position.y, 0.45).set_trans(Tween.TRANS_SINE)

	var glow := create_tween().set_loops()
	glow.tween_property(door_glow, "modulate:a", 0.25, 0.9).set_trans(Tween.TRANS_SINE)
	glow.tween_property(door_glow, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

	var blink := create_tween().set_loops()
	blink.tween_interval(2.6)
	blink.tween_callback(func() -> void: receptionist.frame = 1)
	blink.tween_interval(0.15)
	blink.tween_callback(func() -> void: receptionist.frame = 0)
