class_name TerrainType

enum Values {
	NONE,
	SEA,
	GRASS,
	FOREST,
	ROAD,
	HILL,
}

static func get_name_from_type(val: Values) -> String:
	match val:
		Values.SEA:
			return "Sea" 
		Values.GRASS:
			return "Grass"
		Values.FOREST:
			return "Forest"
		Values.ROAD:
			return "Road"
		Values.HILL:
			return "Hill"
	
	push_error("Unknown terrain type: %d" % val)
	return "NONE"


static func get_type_from_name(name: String) -> Values:
	match name.to_lower():
		"sea":
			return Values.SEA
		"grass":
			return Values.GRASS
		"forest":
			return Values.FOREST
		"road":
			return Values.ROAD
		"hill":
			return Values.HILL

	push_error("Unknown terrain type: %s" % name)
	return Values.NONE