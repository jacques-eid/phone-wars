class_name UIController
extends CanvasLayer

signal camera_pan_enabled(enabled: bool)

signal show_selected(cell_position: Vector2)
signal clear_selected() 


signal show_movement_range(reachable_cells: Array[Vector2i])
signal clear_movement_range()

signal show_attackable(cells: Array[Vector2i])
signal clear_attackable()

signal game_paused()
signal game_resumed()

signal end_turn()
signal exit_level()


const ATTACK_CLICKED = "attack_clicked"
const BUILD_CLICKED = "build_clicked"
const CANCEL_CLICKED = "cancel_clicked"
const CELL_TAP = "cell_tap"
const LONG_PRESS = "long_press"
const LONG_PRESS_RELEASE = "long_press_release"


const UNIT_SELECTED_SIGNAL = "unit_selected_signal"
const UNIT_DESELECTED_SIGNAL = "unit_deselected_signal"
const BUILDING_SELECTED_SIGNAL = "building_selected_signal"
const BUILDING_DESELECTED_SIGNAL = "building_deselected_signal"
const ATTACK_SIGNAL = "attack_signal"
const ATTACK_CANCELLED_SIGNAL = "attack_cancelled_signal"
const ATTACK_DONE_SIGNAL = "attack_done_signal"
const RESET_SIGNAL = "reset_signal"


@onready var game_hud: GameHUD = $GameHUD
@onready var settings_hud: SettingsHUD = $SettingsHud
@onready var team_display: TeamDisplay = $TeamDisplay
@onready var production_panel: ProductionPanel = $ProductionPanel

@onready var start_turn_animation: StartTurnAnimation = $Animations/StartTurnAnimation

@onready var capture_popup: CapturePopup = $Popups/CapturePopup
@onready var combat_popup: CombatPopup = $Popups/CombatPopup
@onready var info_popup: InfoPopup = $Popups/InfoPopup

@onready var damage_effect: DamageEffect = $Effects/DamageEffect

@onready var ui_fx_layer: Node2D = $FXLayer

var grid: Grid
var buy_unit_orchestrator: BuyUnitOrchestrator
var combat_orchestrator: CombatOrchestrator
var capture_orchestrator: CaptureOrchestrator
var merge_units_orchestrator: MergeUnitsOrchestrator
var movement_orchestrator: MovementOrchestrator
var start_turn_orchestrator: StartTurnOrchestrator

var state_machine: LimboHSM
var idle_state: UIIdleState
var unit_selected_state: UIUnitSelectedState
var building_selected_state: UIBuildingSelectedState
var attack_preview_state: UIAttackPreviewState

var active_controller: HumanController
var is_playable: bool

func setup(p_level_manager: LevelManager) -> void:
	grid = p_level_manager.grid
	buy_unit_orchestrator = BuyUnitOrchestrator.new(team_display, p_level_manager.audio_service)
	combat_orchestrator = CombatOrchestrator.new(damage_effect, p_level_manager.fx_service, p_level_manager.audio_service)
	capture_orchestrator = CaptureOrchestrator.new(capture_popup, p_level_manager.fx_service, p_level_manager.audio_service)
	merge_units_orchestrator = MergeUnitsOrchestrator.new(team_display, p_level_manager.audio_service)
	movement_orchestrator = MovementOrchestrator.new(p_level_manager.audio_service)
	start_turn_orchestrator = StartTurnOrchestrator.new(start_turn_animation, team_display, p_level_manager.audio_service)


	init_state_machine()

	grid.cell_short_tap.connect(on_cell_tap)
	grid.cell_long_press.connect(on_long_press)
	grid.cell_long_press_release.connect(on_long_press_release)

	game_hud.cancel_button_clicked.connect(on_cancel_clicked)
	game_hud.end_turn_button_clicked.connect(func(): end_turn.emit())
	game_hud.settings_button_clicked.connect(on_settings_clicked)

	game_hud.idle_button_clicked.connect(on_idle_clicked)
	game_hud.capture_button_clicked.connect(on_capture_clicked)
	game_hud.merge_button_clicked.connect(on_merge_clicked)
	game_hud.attack_button_clicked.connect(on_attack_clicked)


	settings_hud.resume_button_clicked.connect(on_resume_clicked)
	settings_hud.exit_button_clicked.connect(func(): exit_level.emit())

	production_panel.cancel_button_clicked.connect(on_cancel_clicked)
	production_panel.build_clicked.connect(on_build_clicked)


func init_state_machine() -> void:
	idle_state = UIIdleState.new()
	unit_selected_state = UIUnitSelectedState.new()
	building_selected_state = UIBuildingSelectedState.new()
	attack_preview_state = UIAttackPreviewState.new()
	
	state_machine = LimboHSM.new()
	add_child(state_machine)
	state_machine.add_child(idle_state)
	state_machine.add_child(unit_selected_state)
	state_machine.add_child(building_selected_state)
	state_machine.add_child(attack_preview_state)

	state_machine.add_transition(idle_state, unit_selected_state, UNIT_SELECTED_SIGNAL)
	state_machine.add_transition(idle_state, building_selected_state, BUILDING_SELECTED_SIGNAL)
	state_machine.add_transition(unit_selected_state, idle_state, UNIT_DESELECTED_SIGNAL)
	state_machine.add_transition(building_selected_state, idle_state, BUILDING_DESELECTED_SIGNAL)
	state_machine.add_transition(unit_selected_state, attack_preview_state, ATTACK_SIGNAL)
	state_machine.add_transition(attack_preview_state, unit_selected_state, ATTACK_CANCELLED_SIGNAL)
	state_machine.add_transition(attack_preview_state, idle_state, ATTACK_DONE_SIGNAL)
	state_machine.add_transition(state_machine.ANYSTATE, idle_state, RESET_SIGNAL)

	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)


func on_cell_tap(cell: Vector2i) -> void:
	state_machine.dispatch(CELL_TAP, cell)


func on_long_press(cell: Vector2i) -> void:
	state_machine.dispatch(LONG_PRESS, cell)

	
func on_long_press_release(_cell: Vector2i) -> void:
	state_machine.dispatch(LONG_PRESS_RELEASE)


func on_cancel_clicked() -> void:
	state_machine.dispatch(CANCEL_CLICKED)


func on_build_clicked(entry: ProductionEntry) -> void:
	state_machine.dispatch(BUILD_CLICKED, entry)


func on_settings_clicked() -> void:
	game_hud.hide()
	team_display.animate_out()
	settings_hud.show()
	game_paused.emit()


func on_resume_clicked() -> void:
	settings_hud.hide()
	team_display.animate_in()
	game_hud.show()
	game_resumed.emit()


func on_idle_clicked() -> void:
	active_controller.exhaust_unit()
	state_machine.dispatch(UNIT_DESELECTED_SIGNAL)


func on_capture_clicked() -> void:
	active_controller.capture_building()
	game_hud.hide()
	team_display.animate_out()
	camera_pan_enabled.emit(false)
	clear_movement_range.emit()
	clear_attackable.emit()
	clear_selected.emit()
	await capture_orchestrator.execute(active_controller)
	game_hud.show()
	team_display.animate_in()
	camera_pan_enabled.emit(true)
	state_machine.dispatch(UNIT_DESELECTED_SIGNAL)


func on_merge_clicked() -> void:
	await merge_units_orchestrator.execute(active_controller)
	state_machine.dispatch(UNIT_DESELECTED_SIGNAL)


func on_attack_clicked() -> void:
	state_machine.dispatch(ATTACK_CLICKED)
	

func switch_team(new_team: Team) -> void:
	is_playable = new_team.is_playable()
	if is_playable:
		active_controller = new_team.controller
	state_machine.dispatch(RESET_SIGNAL)


func show_start_turn_intro(team: Team, new_funds: int) -> void:
	camera_pan_enabled.emit(false)
	game_hud.hide()
	await start_turn_orchestrator.execute(team, new_funds)
	game_hud.show()
	camera_pan_enabled.emit(true)
	

func show_attack_indicator() -> void:
	var cells: Array[Vector2i] = []
	if active_controller.merge_available():
		show_attackable.emit(cells)
		return

	cells = active_controller.get_units_in_attack_range_with_movement()
	show_attackable.emit(cells)


func show_movement_indicator() -> void:
	active_controller.update_movement_indicator()
	show_movement_range.emit(active_controller.get_reachable_cells())


func show_selection_indicator() -> void:
	show_selected.emit(active_controller.selected_cell_pos())


func can_move_to_cell(cell: Vector2i) -> bool:
	return active_controller.can_move_to_cell(cell)


func can_attack_cell(cell: Vector2i) -> bool:
	return active_controller.can_attack_cell(cell)


func handle_unit_movement(cell: Vector2i) -> void:
	game_hud.hide()
	clear_attackable.emit()
	clear_movement_range.emit()
	clear_selected.emit()
	await movement_orchestrator.execute(active_controller, cell)


func handle_unit_attack(cell: Vector2i) -> void:
	# Selected unit can attack without moving
	if active_controller.can_attack_without_moving(cell):
		active_controller.set_target_unit(cell)
		state_machine.dispatch(ATTACK_SIGNAL)
		return

	# Unit first need to move
	game_hud.hide()
	clear_attackable.emit()
	clear_movement_range.emit()
	clear_selected.emit()
	var best_cell: Vector2i = active_controller.choose_best_attack_position(cell)
	active_controller.set_target_unit(cell)
	await movement_orchestrator.execute(active_controller, best_cell)
	state_machine.dispatch(ATTACK_SIGNAL)


func handle_long_press(cell: Vector2i) -> void:
	var long_press_result: LongPressResult = active_controller.handle_long_press(cell)
	if long_press_result.unit == null and long_press_result.building == null:
		return
		
	game_hud.hide()
	camera_pan_enabled.emit(false)
	team_display.animate_out()

	if long_press_result.building != null:
		info_popup.with_building(long_press_result.building)
	else:
		var terrain_data: TerrainData = grid.terrain_manager.get_terrain_data(cell)
		info_popup.with_terrain(terrain_data)

	if long_press_result.unit != null:
		await info_popup.with_unit(long_press_result.unit)
		info_popup.position_dialog(long_press_result.unit)
	else:
		await info_popup.clear_unit_data()
		info_popup.position_dialog(long_press_result.building)

	info_popup.animate_in()

	if long_press_result.unit == null:
		return

	show_attackable.emit(long_press_result.cells_in_attack_range)


func handle_long_press_release() -> void:
	game_hud.show()
	clear_attackable.emit()
	info_popup.animate_out()
	camera_pan_enabled.emit(true)
	team_display.animate_in()


func show_combat_dialog() -> void:
	var edr: EstimatedDamageResult = active_controller.estimate_damage()
	
	if edr.building == null:
		combat_popup.with_terrain(edr.terrain_data)
	else:
		combat_popup.with_building(edr.building)
		
	team_display.animate_out()
	camera_pan_enabled.emit(false)

	combat_popup.with_estimated_damage(edr.estimated_damage)
	combat_popup.with_unit(edr.defender)

	combat_popup.position_dialog(edr.defender)
	combat_popup.animate_in()
