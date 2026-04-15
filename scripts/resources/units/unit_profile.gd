class_name UnitProfile
extends Resource


@export var icon: Texture2D = null
@export var move_sound: AudioStream = null
@export var type: UnitType.Values = UnitType.Values.INFANTRY
@export var movement_points: int = 3
@export var capture_capacity: int = 10
@export var health: int = 10
@export var cost: int = 100
@export var weapon: Weapon