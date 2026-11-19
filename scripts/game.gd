extends Node
## Global game state and scene transitions. Registered as the "Game" autoload.

const EXTERIOR := "res://scenes/exterior.tscn"
const LOBBY := "res://scenes/lobby.tscn"
const GAME_HALL := "res://scenes/dungeon.tscn"
## Background music. Each scene picks a track from SCENE_MUSIC; switching
## between two scenes that share a track keeps it playing without restarting.
const MUSIC_TOWN := "res://music/Minifantasy_Dungeon_Music/Music/Goblins_Dance_(Battle).wav"
const MUSIC_DUNGEON := "res://music/Minifantasy_Dungeon_Music/Music/Goblins_Den_(Regular).wav"
const SCENE_MUSIC := {
	"res://scenes/exterior.tscn": MUSIC_TOWN,
	"res://scenes/lobby.tscn": MUSIC_TOWN,
	"res://scenes/dungeon.tscn": MUSIC_DUNGEON,
	"res://scenes/dungeon2.tscn": MUSIC_DUNGEON,
	"res://scenes/dungeon3.tscn": MUSIC_DUNGEON,
}
const MUSIC_VOLUME_DB := -6.0

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
var _music_path := ""

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
	_play_music_for_scene(scene_path)
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
	# Loop: restart the track when it ends. (The WAVs are also imported with
	# Loop Mode = Forward, in which case this never fires.)
	_music.finished.connect(_music.play)
	set_music_enabled(music_enabled)
	# The first scene isn't loaded through go_to(), so pick its track once
	# it exists. This also works when running a single scene with F6.
	_play_music_for_current_scene.call_deferred()


func _play_music_for_current_scene() -> void:
	var scene := get_tree().current_scene
	if scene != null:
		_play_music_for_scene(scene.scene_file_path)


## Switch to the track for this scene. Does nothing if that track is already
## playing, so exterior <-> lobby doesn't restart the song. Scenes not listed
## in SCENE_MUSIC keep whatever is currently playing.
func _play_music_for_scene(scene_path: String) -> void:
	if not SCENE_MUSIC.has(scene_path):
		return
	play_music(SCENE_MUSIC[scene_path])


## Play a music track by path. Safe to call repeatedly with the same track.
func play_music(path: String) -> void:
	if path == _music_path and _music.playing:
		return
	if not ResourceLoader.exists(path):
		push_warning("Music file not found: " + path)
		return
	_music_path = path
	_music.stream = load(path)
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


## Mute/unmute the music without stopping the track, so it resumes in place.
func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if _music != null:
		_music.volume_db = MUSIC_VOLUME_DB if enabled else -80.0
