class_name Hud
extends CanvasLayer
## On-screen UI: interaction prompt, location banner, controls hint and a
## typewriter dialog box.

signal dialog_finished

@onready var prompt_panel: PanelContainer = $Prompt
@onready var prompt_label: Label = $Prompt/Label
@onready var banner: PanelContainer = $Banner
@onready var banner_label: Label = $Banner/Label
@onready var hint: Label = $Hint
@onready var dialog: PanelContainer = $Dialog
@onready var dialog_name: Label = $Dialog/VBox/Name
@onready var dialog_text: Label = $Dialog/VBox/Text

var _lines: Array = []
var _index := 0
var _typing: Tween


func _ready() -> void:
	add_to_group("hud")
	prompt_panel.hide()
	dialog.hide()
	hint.hide()
	banner.modulate.a = 0.0


func set_prompt(text: String) -> void:
	if text == "":
		prompt_panel.hide()
	else:
		prompt_label.text = text
		prompt_panel.show()


func show_banner(text: String) -> void:
	banner_label.text = text
	var t := create_tween()
	t.tween_property(banner, "modulate:a", 1.0, 0.4)
	t.tween_interval(2.2)
	t.tween_property(banner, "modulate:a", 0.0, 0.6)


func show_hint(text: String) -> void:
	hint.text = text
	hint.show()
	hint.modulate.a = 1.0
	var t := create_tween()
	t.tween_interval(6.0)
	t.tween_property(hint, "modulate:a", 0.0, 1.0)


## Show a sequence of lines; awaits until the player has read them all.
func say(speaker: String, lines: Array) -> void:
	Game.ui_busy = true
	_lines = lines
	_index = 0
	dialog_name.text = speaker
	dialog.show()
	_show_line()
	await dialog_finished


func _show_line() -> void:
	dialog_text.text = _lines[_index]
	dialog_text.visible_characters = 0
	var n := dialog_text.text.length()
	_typing = create_tween()
	_typing.tween_property(dialog_text, "visible_characters", n, n * 0.025)


func _unhandled_input(event: InputEvent) -> void:
	if not dialog.visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if _typing and _typing.is_running():
			_typing.kill()
			dialog_text.visible_characters = -1
			return
		_index += 1
		if _index < _lines.size():
			_show_line()
		else:
			dialog.hide()
			Game.release_ui()
			dialog_finished.emit()
