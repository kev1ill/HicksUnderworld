extends CanvasLayer

@export var full_heart: Texture2D
@export var half_heart: Texture2D
@export var empty_heart: Texture2D

@onready var box: HBoxContainer = $HBoxContainer
@onready var wave_label: Label = $WaveLabel
@onready var banner: Label = $BannerLabel

var _banner_tween: Tween

# binds the hud to the health node
func _bind(health: Health) -> void:
	# listens for the changed signal emitted by the health node on the player
	health.changed.connect(_update)
	# calls _update to show the correct amount of health
	_update(health.current, health.max_health)


# updates the players health
func _update(current: int, max: int) -> void:
	# clear all hearts from the hud before processing how much health remains
	for node in box.get_children():
		box.remove_child(node)

	#one heart for every two health, rounded up to nearest whole number
	for i in range(ceili(max / 2.0)):
		#create a new image display
		var icon := TextureRect.new()
		# current amount of health minus the amount used by each heart (i)
		var remaining := current - i * 2
		
		# if the player has enough health remaining for a full heart display a full heart
		if remaining >= 2: icon.texture = full_heart
		elif remaining == 1: icon.texture = half_heart
		else: icon.texture = empty_heart
		
		# add the heart to the container (healthbar)
		box.add_child(icon)
		
func show_wave(num: int) -> void:
	wave_label.text = "Wave %d" % num
	
func show_message(text: String) -> void:
	wave_label.text = text
	
func show_banner(text: String, hold_time: float = 2.0) -> void:
	banner.text = text
	#sets the transparency of the banner to 1 meaning fully visible
	banner.modulate.a = 1.0
	
	#if there is still an active message destroy it
	if _banner_tween:
		_banner_tween.kill()
		
	#wait then fade the visibility of the banner back to 0
	_banner_tween = create_tween()
	_banner_tween.tween_interval(hold_time)
	_banner_tween.tween_property(banner, "modulate:a", 0.0, 1.0)
	
