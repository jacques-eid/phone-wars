class_name UIBuildingSelectedState
extends UIState

func _enter(_params: Dictionary = {}) -> void:
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


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _on_cancel_clicked() -> void:
	deselect_building()


func _on_build_clicked(entry: ProductionEntry) -> void:
	var selected_building: Building = ui_controller.active_controller.selected_building
	var team: Team = selected_building.team
	if not team.can_buy(entry):
		return
	
	ui_controller.production_panel.hide()
	await ui_controller.team_display.animate_in()
	await ui_controller.buy_unit_orchestrator.execute(ui_controller.active_controller, entry, selected_building.cell_pos)
	deselect_building()


func deselect_building() -> void:
	ui_controller.active_controller.deselect_building()
	ui_controller.fsm.change_state(ui_controller.idle_state)