extends Node
## Global game state and scene transitions. Registered as the "Game" autoload.

const EXTERIOR := "res://scenes/exterior.tscn"
const LOBBY := "res://scenes/lobby.tscn"
const GAME_HALL := "res://scenes/dungeon.tscn"
## Background music track. Drop an .ogg/.wav here and it plays automatically.
const MUSIC_PATH := "res://audio/lobby_theme.ogg"

## Name the player typed in the lobby panel.
var player_name := "PLAYER"
## Progress carried from Level 1 to Level 2 (reset when a new game
## starts from the lobby panel). Base max health is 6.
var dungeon_weapon_index := 0
var dungeon_health_bonus := 0
## Music preference, owned by the pause/settings menu.
var music_enabled := true
## Which Marker2D (under "Spawns") the next scene should place the player on.
var spawn_id := "start"
## True while a dialog, menu or scene fade owns the input; the player freezes.
var ui_busy := false
var shown_controls_hint := false

var _fade: ColorRect
var _changing := false
var _music: AudioStreamPlayer


func _ready() -> void:
	_setup_music()
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0.07, 0.06, 0.07, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)


## Fade out, swap scenes, fade back in. `spawn` names the Marker2D to start on.
func go_to(scene_path: String, spawn := "start") -> void:
	if _changing:
		return
	_changing = true
	ui_busy = true
	spawn_id = spawn
	# The pause menu pauses the tree; never carry that into the next scene.
	get_tree().paused = false
	var out := create_tween()
	out.tween_property(_fade, "color:a", 1.0, 0.3)
	await out.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	ui_busy = false
	var back := create_tween()
	back.tween_property(_fade, "color:a", 0.0, 0.35)
	await back.finished
	_changing = false


## Give control back to the player a moment after a menu/dialog closes, so the
## key press that closed it doesn't immediately trigger something else.
func release_ui() -> void:
	await get_tree().create_timer(0.15).timeout
	if not _changing:
		ui_busy = false


func _setup_music() -> void:
	_music = AudioStreamPlayer.new()
	_music.name = "Music"
	# Keep playing while the game is paused and across scene changes.
	_music.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_music)
	if ResourceLoader.exists(MUSIC_PATH):
		_music.stream = load(MUSIC_PATH)
		_music.play()
	set_music_enabled(music_enabled)


## Mute/unmute the music without stopping the track, so it resumes in place.
func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if _music != null:
		_music.volume_db = -6.0 if enabled else -80.0
