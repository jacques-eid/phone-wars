extends BTAction


func _tick(_delta: float) -> Status:
	var ai_controller: AIController = agent as AIController
	ai_controller.selected_unit = select_random_unit(ai_controller)
	ai_controller.selected_unit.select()
	
	print("selected unit: ", ai_controller.selected_unit.name)

	return SUCCESS


func select_random_unit(ai_controller: AIController) -> Unit:
	var units: Array[Unit] = ai_controller.units_manager.get_units_for_team(ai_controller.team)

	return units[randi() % units.size()]