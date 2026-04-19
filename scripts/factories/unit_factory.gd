class_name UnitFactory


var scenes: Dictionary[UnitType.Values, PackedScene] = {
	UnitType.Values.INFANTRY: preload("res://scenes/units/infantry.tscn"),
	UnitType.Values.RECON: preload("res://scenes/units/recon.tscn"),
	UnitType.Values.ARTILLERY: preload("res://scenes/units/artillery.tscn"),
	UnitType.Values.LIGHT_TANK: preload("res://scenes/units/light_tank.tscn"),
}


func spawn(unit_type: UnitType.Values) -> Unit:
	var scene: PackedScene = scenes[unit_type]
	var config: UnitStats = GameConfig.get_unit_stats(unit_type)
	var unit: Unit = scene.instantiate() as Unit
	unit.type = unit_type
	unit.apply_config(config)

	return unit
