class_name UIBuildingSelectedState
extends LimboState


var ui_controller: UIController


func _setup() -> void:
	ui_controller = agent

	add_event_handler(ui_controller.CANCEL_CLICKED, _on_cancel_clicked)
	add_event_handler(ui_controller.BUILD_CLICKED, _on_build_clicked)


func _enter() -> void:
	ui_controller.visible = true
	ui_controller.game_hud.hide_game_hud()
	ui_controller.production_panel.show()
	ui_controller.team_display.animate_out()

	var selected_building: Building = ui_controller.active_controller.selected_building
	ui_controller.production_panel.load_production_list(
		selected_building.production_list, 
		selected_building.team)
	ui_controller.show_selection_indicator()


func _exit() -> void:
	ui_controller.game_hud.show_game_hud()
	ui_controller.production_panel.hide()
	ui_controller.team_display.animate_in()
	ui_controller.clear_selected.emit()


func _on_cancel_clicked() -> bool:
	ui_controller.active_controller.deselect_building()
	ui_controller.state_machine.dispatch(ui_controller.RESET_SIGNAL)
	return true


func _on_build_clicked(cargo: Variant) -> bool:
	if not cargo is ProductionEntry:
		return true

	ui_controller.handle_build_async(cargo as ProductionEntry)
	return true