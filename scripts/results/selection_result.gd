class_name SelectionResult

enum Values {
	NONE,
	UNIT,
	BUILDING,
}


var value: Values = Values.NONE


func _init(v: Values) -> void:
	value = v