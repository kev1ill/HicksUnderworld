class_name PauseMenu
extends CanvasLayer
## Pause + settings overlay. Esc opens/closes it. While it is open the whole
## scene tree is paused, so the player, tweens and decor animations stop.
## Music and quit live here because both are game-wide, not scene-specific.

@onready var resume_button: Button = %ResumeButton
@onready var music_button: Button = %MusicButton
@onready var campus_button: Button = %CampusButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(close)
	music_button.pressed.connect(_toggle_music)
	campus_button.pressed.connect(_on_campus)
	quit_button.pressed.connect(_on_quit)
	_refresh_music()


func open() -> void:
	# A dialog or the lobby menu owns the screen; do not stack a pause menu on it.
	if Game.ui_busy:
		return
	show()
	get_tree().paused = true
	resume_button.grab_focus()


func close() -> void:
	hide()
	get_tree().paused = false


func _toggle_music() -> void:
	Game.set_music_enabled(not Game.music_enabled)
	_refresh_music()


func _refresh_music() -> void:
	music_button.text = "MUSIC: ON" if Game.music_enabled else "MUSIC: OFF"


func _on_campus() -> void:
	get_tree().paused = false
	hide()
	Game.go_to(Game.EXTERIOR, "start")


func _on_quit() -> void:
	get_tree().paused = false
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		get_viewport().set_input_as_handled()
		close()
	elif not Game.ui_busy:
		get_viewport().set_input_as_handled()
		open()
