class_name AIActionType

enum Values {
	ATTACK = 0,
	CAPTURE = 1,
	MERGE = 2,
	MOVE = 3,
}


static func get_name_from_type(v: Values) -> String:
	match v:
		Values.ATTACK:
			return "Attack"
		Values.CAPTURE:
			return "Capture"
		Values.MERGE:
			return "Merge"
		Values.MOVE:
			return "Move"

	return ""