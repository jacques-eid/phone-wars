class_name AIBuyResult
extends AIScoreResult


var building: Building
var production_entry: ProductionEntry


func _to_string() -> String:
    return "building: %s - unit_type: %s - %s" % [building.name, UnitType.get_name_from_type(production_entry.unit_type), super._to_string()]