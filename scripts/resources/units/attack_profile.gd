class_name AttackProfile
extends Resource

@export var min_range: int = 1
@export var max_range: int = 1

@export var dmg_vs_light: float = 5
@export var dmg_vs_reinforced: float = 3

@export var is_range: bool = false

func get_attack_dmg(unit_type: UnitType.Values) -> float:
    if UnitType.is_light_type(unit_type):
        return dmg_vs_light
    
    return dmg_vs_reinforced