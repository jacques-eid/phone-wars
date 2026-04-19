class_name ProductionEntry
extends Resource



@export var unit_type: UnitType.Values
@export var unit_profile: UnitProfile


func cost() -> int:
    return GameConfig.get_unit_stats(unit_type).cost