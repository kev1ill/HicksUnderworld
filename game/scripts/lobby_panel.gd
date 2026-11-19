class_name LobbyPanel
extends CanvasLayer
## The pre-game menu shown at the Game Hall doors.

signal closed

@onready var name_edit: LineEdit = %NameEdit
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	hide()
	start_button.pressed.connect(_on_start)
	back_button.pressed.connect(close)
	name_edit.text_submitted.connect(func(_t: String) -> void: _on_start())


func open() -> void:
	Game.ui_busy = true
	name_edit.text = "" if Game.player_name == "PLAYER" else Game.player_name
	show()
	name_edit.grab_focus()


func close() -> void:
	hide()
	Game.release_ui()
	closed.emit()


func _on_start() -> void:
	var n := name_edit.text.strip_edges()
	Game.player_name = n.to_upper() if n != "" else "PLAYER"
	hide()
	Game.go_to(Game.GAME_HALL, "start")


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
