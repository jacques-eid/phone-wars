class_name AIBuyResult
extends AIScoreResult


var building: Building
var production_entry: ProductionEntry


func _to_string() -> String:
    return "building: %s - unit_type: %s - %s" % [building.name, production_entry.unit_profile.type, super._to_string()]