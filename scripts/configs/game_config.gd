extends Node


var combat_config_path: String = "data/combat_matrix.txt"
var movement_config_path: String = "data/movement_matrix.txt"

var combat_config: CombatConfig = CombatConfig.new()
var movement_config: MovementConfig = MovementConfig.new()


func _ready() -> void:
	combat_config.load_from_file(combat_config_path)
	movement_config.load_from_file(movement_config_path)


func get_flat_attack_damage(attacker: UnitType.Values, defender: UnitType.Values) -> float:
	return combat_config.get_flat_attack_damage(attacker, defender)


func get_movement_cost(unit_type: UnitType.Values, terrain_type: TerrainType.Values) -> float:
	return movement_config.get_movement_cost(unit_type, terrain_type)