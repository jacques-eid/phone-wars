class_name UnitContext

var grid_pos: Vector2i
var min_range: int
var max_range: int
var team: Team


static func create_unit_context(unit: Unit) -> UnitContext:
	var unit_context: UnitContext = UnitContext.new()
	unit_context.team = unit.team
	unit_context.grid_pos = unit.cell
	unit_context.min_range = unit.min_attack_range()
	unit_context.max_range = unit.max_attack_range()

	return unit_context
