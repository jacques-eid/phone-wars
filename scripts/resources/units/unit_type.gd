class_name UnitType

enum Values {
	NONE,
	INFANTRY,
	RECON,
	LIGHT_TANK,
	ARTILLERY,
}


static func get_name_from_type(val: Values) -> String:
	match val:
		Values.INFANTRY:
			return "Infantry" 
		Values.RECON:
			return "Recon"
		Values.LIGHT_TANK:
			return "Light tank"
		Values.ARTILLERY:
			return "Artillery"
	
	push_error("Unknown unit type: %d" % val)
	return "NONE"


static func get_type_from_name(name: String) -> Values:
	match name.to_lower():
		"infantry":
			return Values.INFANTRY
		"recon":
			return Values.RECON
		"artillery":
			return Values.ARTILLERY
		"light tank", "light_tank":
			return Values.LIGHT_TANK

	push_error("Unknown unit type: %s" % name)
	return Values.NONE


static func is_light_type(val: Values) -> bool:
	return val == Values.INFANTRY
