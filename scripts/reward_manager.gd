class_name RewardManager
extends Node

signal reward_given(text: String)
signal weapon_changed(weapon_name: String, tier: int, max_tier: int)

@export var weapons: Array[WeaponData] = []
@export var health_bonus: int = 2
@export var buff_multiplier: float = 1.4
@export var buff_duration: float = 20.0

#waves where the player is rewarded and the chances of each reward
var reward_table := {} 

#Position in the weapons list, 0 is rusty sword
var weapon_index := 0
var player

func _ready() -> void:
	match get_parent().name:
		"Dungeon2": 
			reward_table = {
			2: [.85, .15],
			5: [.7, .2],
			7: [.8, .1]
		}
		"Dungeon":
			reward_table = {
			2: [.8, .1],
			5: [.7, .2],
			7: [.8, .1]
		}

#called by the dungeon to give the player the rusty sword at the start
# On Level 2 this restores the weapon / health earned in Level 1,
# which dungeon.gd saved into the Game autoload on victory.
func setup(p) -> void:
	player = p
	
	if not weapons.is_empty():
		weapon_index = clampi(Game.dungeon_weapon_index, 0, weapons.size() - 1)
		if Game.dungeon_health_bonus > 0:
			player.health.increase_max(Game.dungeon_health_bonus)
		_equip(weapon_index)

func on_wave_cleared(wave: int) -> void:
	#give a message for every wave
	var message := "Wave %d cleared!" % wave
	#if there is a reward for completing the wave, tell the player
	if reward_table.has(wave):
		message += "\n" + _give_reward(wave)
	
	reward_given.emit(message)
	
func _give_reward(wave: int) -> String:
	#automatically increase player health at each reward interval
	player.health.increase_max(health_bonus)
	
	var odds: Array = reward_table[wave]
	var roll := randf()
	var tiers := 0
	
	if roll < odds[0]:
		tiers = 1
	elif roll < (odds[0] + odds[1]):
		tiers = 2
		
	var top := weapons.size() - 1
	if tiers > 0 and weapon_index < top:
		var old_index := weapon_index
		var new_index := mini(weapon_index + tiers, top)
		_equip(new_index)
		
		var big := " (big upgrade!)" if weapon_index - old_index >= 2 else ""
		return "New Weapon: %s%s\nMax health increased!" % [weapons[weapon_index].display_name, big]
		
	player.apply_speed_buff(buff_multiplier, buff_duration)
	return "Speed Boost!\nMax health increased!"
	
# One place that equips a weapon and announces it, so the HUD can't get out of date.
func _equip(index: int) -> void:
	weapon_index = index
	player.equip_weapon(weapons[index])
	weapon_changed.emit(weapons[index].display_name, index + 1, weapons.size())

# Re-announces the current weapon. The Dungeon calls this once at the start,
# in case the starting weapon was equipped before the HUD was listening.
func refresh_weapon_display() -> void:
	if not weapons.is_empty():
		weapon_changed.emit(weapons[weapon_index].display_name, weapon_index + 1, weapons.size())
