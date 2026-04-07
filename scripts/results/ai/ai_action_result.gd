class_name AIActionResult
extends AIScoreResult


var unit: Unit
var type: AIActionType.Values
var target_unit: Unit
var target_building: Building
var target_cell: Vector2i


func _to_string() -> String:
    return "unit: %s - type: %s - %s" % [unit.debug_name, type, super._to_string()]