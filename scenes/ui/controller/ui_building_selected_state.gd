class_name UIBuildingSelectedState
extends LimboState


var ui_controller: UIController


func _setup() -> void:
	ui_controller = agent

	add_event_handler(ui_controller.CANCEL_CLICKED, _on_cancel_clicked)
	add_event_handler(ui_controller.BUILD_CLICKED, _on_build_clicked)


func _enter() -> void:
	ui_controller.visible = true
	ui_controller.game_hud.hide()
	ui_controller.production_panel.show()
	ui_controller.team_display.animate_out()

	var selected_building: Building = ui_controller.active_controller.selected_building
	ui_controller.production_panel.load_production_list(
		selected_building.production_list, 
		selected_building.team)
	ui_controller.show_selection_indicator()


func _exit() -> void:
	ui_controller.game_hud.show()
	ui_controller.production_panel.hide()
	ui_controller.team_display.animate_in()
	ui_controller.clear_selected.emit()


func _on_cancel_clicked() -> bool:
	deselect_building()
	return true


func _on_build_clicked(cargo: Variant) -> bool:
	if not cargo is ProductionEntry:
		return true

	var entry: ProductionEntry = cargo as ProductionEntry

	var selected_building: Building = ui_controller.active_controller.selected_building
	var team: Team = selected_building.team
	if not team.can_buy(entry):
		return true
	
	ui_controller.production_panel.hide()
	await ui_controller.team_display.animate_in()
	await ui_controller.buy_unit_orchestrator.execute(ui_controller.active_controller, entry, selected_building.cell_pos)
	deselect_building()

	return true


func deselect_building() -> void:
	ui_controller.active_controller.deselect_building()
	ui_controller.state_machine.dispatch(ui_controller.BUILDING_DESELECTED_SIGNAL)