extends Node
## Global game state and scene transitions. Registered as the "Game" autoload.

const EXTERIOR := "res://scenes/exterior.tscn"
const LOBBY := "res://scenes/lobby.tscn"
const GAME_HALL := "res://scenes/dungeon.tscn"
## Background music track. Drop an .ogg/.wav here and it plays automatically.
const MUSIC_PATH := "res://music/Minifantasy_Dungeon_Music/Music/Goblins_Den_(Battle).wav"

## Sound effects. The lists let play_sfx_random pick a different variant each time.
const SFX_SWING: Array[AudioStream] = [
	preload("res://music/Minifantasy_Dungeon_SFX/07_human_atk_sword_1.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/07_human_atk_sword_2.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/07_human_atk_sword_3.wav"),
]
const SFX_SWORD_HIT: Array[AudioStream] = [
	preload("res://music/Minifantasy_Dungeon_SFX/26_sword_hit_1.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/26_sword_hit_2.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/26_sword_hit_3.wav"),
]
const SFX_PLAYER_HURT: Array[AudioStream] = [
	preload("res://music/Minifantasy_Dungeon_SFX/11_human_damage_1.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/11_human_damage_2.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/11_human_damage_3.wav"),
]
const SFX_ENEMY_HURT: Array[AudioStream] = [
	preload("res://music/Minifantasy_Dungeon_SFX/21_orc_damage_1.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/21_orc_damage_2.wav"),
	preload("res://music/Minifantasy_Dungeon_SFX/21_orc_damage_3.wav"),
]
const SFX_ENEMY_DIED: AudioStream = preload("res://music/Minifantasy_Dungeon_SFX/24_orc_death_spin.wav")
const SFX_PLAYER_DIED: AudioStream = preload("res://music/Minifantasy_Dungeon_SFX/14_human_death_spin.wav")
const SFX_INTERACT: AudioStream = preload("res://music/Bitcade-Free-SFX-Pack-Vol1/WAV/UI/bitcade_ui_confirm.wav")


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

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0



func _ready() -> void:
	_setup_music()
	_setup_sfx()

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
		
	## Build a pool of sound players so overlapping effects don't cut each other off.
func _setup_sfx() -> void:
	for i in 8:
		var player := AudioStreamPlayer.new()
		player.name = "SFX%d" % i
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_sfx_players.append(player)


## Play one sound, cycling through the pool so a new sound never cuts off
## one that's still playing.
func play_sfx(stream: AudioStream, volume_db := -20.0) -> void:
	if stream == null or _sfx_players.is_empty():
		return
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()


## Play a random sound from a list (swings and hits have 3 variants each).
func play_sfx_random(streams: Array[AudioStream], volume_db := -6.0) -> void:
	if streams.is_empty():
		return
	play_sfx(streams[randi() % streams.size()], volume_db)

	set_music_enabled(music_enabled)


## Mute/unmute the music without stopping the track, so it resumes in place.
func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if _music != null:
		_music.volume_db = -6.0 if enabled else -80.0
