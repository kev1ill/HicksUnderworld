class_name WeaponData
extends Resource

#Shown in the reward message
@export var display_name: String = "Sword"
#The weapon's image
@export var texture: Texture2D
#Damage per hit
@export var damage: int = 1
#Half-width of the swing in radians, as before
@export var swing_arc: float = 1.2
#Length of the hitbox in pixels matched this to the sprite's height
@export var reach: float = 20.0
#Seconds between swings
@export var cooldown: float = 0.5
