class_name BuildingType

enum Values {
	CITY,
	BASE,
	HQ,
}


static func get_name_from_type(val: Values) -> String:
	match val:
		Values.CITY:
			return "City"
		Values.BASE:
			return "Base" 
		Values.HQ:
			return "HQ"
	
	push_error("Unknown building type: %d" % val)
	return "NONE"  # default fallback

