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

signal exit_level()


const ATTACK_CLICKED = "attack_clicked"
const BUILD_CLICKED = "build_clicked"
const CANCEL_CLICKED = "cancel_clicked"
const CELL_TAP = "cell_tap"
const LONG_PRESS = "long_press"
const LONG_PRESS_RELEASE = "long_press_release"


const ACTION_RUNNING_SIGNAL = "action_running_signal"
const UNIT_SELECTED_SIGNAL = "unit_selected_signal"
const BUILDING_SELECTED_SIGNAL = "building_selected_signal"
const ATTACK_SIGNAL = "attack_signal"
const ATTACK_CANCELLED_SIGNAL = "attack_cancelled_signal"
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

var earn_coin_audio: AudioStream = preload("res://assets/sounds/ui/sfx_coin_double8.wav")
var spent_coin_audio: AudioStream = preload("res://assets/sounds/ui/sfx_coin_double1.wav")

var grid: Grid

var state_machine: LimboHSM
var idle_state: UIIdleState
var unit_selected_state: UIUnitSelectedState
var building_selected_state: UIBuildingSelectedState
var attack_preview_state: UIAttackPreviewState
var action_running_state: UIActionRunningState

var active_controller: TeamController
var is_playable: bool

var capture_orchestrator: CaptureOrchestrator
var combat_orchestrator: CombatOrchestrator
var start_turn_orchestrator: StartTurnOrchestrator


func _ready() -> void:
	visible = true


func setup(p_level_manager: LevelManager) -> void:
	grid = p_level_manager.grid

	init_state_machine()

	capture_orchestrator = CaptureOrchestrator.new(capture_popup, p_level_manager.fx_service)
	combat_orchestrator = CombatOrchestrator.new(damage_effect, p_level_manager.fx_service)
	start_turn_orchestrator = StartTurnOrchestrator.new(start_turn_animation, team_display,)

	grid.cell_short_tap.connect(_on_cell_tap)
	grid.cell_long_press.connect(_on_long_press)
	grid.cell_long_press_release.connect(_on_long_press_release)

	game_hud.cancel_button_clicked.connect(_on_cancel_clicked)
	game_hud.end_turn_button_clicked.connect(func(): active_controller._end_turn())
	game_hud.settings_button_clicked.connect(_on_settings_clicked)

	game_hud.idle_button_clicked.connect(_on_idle_clicked)
	game_hud.capture_button_clicked.connect(_on_capture_clicked)
	game_hud.merge_button_clicked.connect(_on_merge_clicked)
	game_hud.attack_button_clicked.connect(_on_attack_clicked)


	settings_hud.resume_button_clicked.connect(_on_resume_clicked)
	settings_hud.exit_button_clicked.connect(func(): exit_level.emit())

	production_panel.cancel_button_clicked.connect(_on_cancel_clicked)
	production_panel.build_clicked.connect(_on_build_clicked)


func init_state_machine() -> void:
	idle_state = UIIdleState.new()
	unit_selected_state = UIUnitSelectedState.new()
	building_selected_state = UIBuildingSelectedState.new()
	attack_preview_state = UIAttackPreviewState.new()
	action_running_state = UIActionRunningState.new()
	
	state_machine = LimboHSM.new()
	add_child(state_machine)
	state_machine.add_child(idle_state)
	state_machine.add_child(unit_selected_state)
	state_machine.add_child(building_selected_state)
	state_machine.add_child(attack_preview_state)
	state_machine.add_child(action_running_state)

	state_machine.add_transition(idle_state, unit_selected_state, UNIT_SELECTED_SIGNAL)
	state_machine.add_transition(idle_state, building_selected_state, BUILDING_SELECTED_SIGNAL)
	state_machine.add_transition(action_running_state, attack_preview_state, ATTACK_SIGNAL)
	state_machine.add_transition(attack_preview_state, unit_selected_state, ATTACK_CANCELLED_SIGNAL)
	state_machine.add_transition(state_machine.ANYSTATE, idle_state, RESET_SIGNAL)
	state_machine.add_transition(state_machine.ANYSTATE, action_running_state, ACTION_RUNNING_SIGNAL)

	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)


func _on_cell_tap(cell: Vector2i) -> void:
	state_machine.dispatch(CELL_TAP, cell)


func _on_long_press(cell: Vector2i) -> void:
	state_machine.dispatch(LONG_PRESS, cell)

	
func _on_long_press_release(_cell: Vector2i) -> void:
	state_machine.dispatch(LONG_PRESS_RELEASE)


func _on_cancel_clicked() -> void:
	state_machine.dispatch(CANCEL_CLICKED)


func _on_build_clicked(entry: ProductionEntry) -> void:
	state_machine.dispatch(BUILD_CLICKED, entry)


func _on_settings_clicked() -> void:
	game_hud.hide()
	team_display.animate_out()
	settings_hud.show()
	game_paused.emit()


func _on_resume_clicked() -> void:
	settings_hud.hide()
	team_display.animate_in()
	game_hud.show()
	game_resumed.emit()


func _on_idle_clicked() -> void:
	active_controller.exhaust_unit()
	state_machine.dispatch(RESET_SIGNAL)


func _on_capture_clicked() -> void:
	action_running_state.clear_selections = true
	state_machine.dispatch(ACTION_RUNNING_SIGNAL)
	await active_controller.capture_building()
	state_machine.dispatch(RESET_SIGNAL)


func _on_merge_clicked() -> void:
	game_hud.hide()
	await active_controller.merge_units()
	state_machine.dispatch(RESET_SIGNAL)


func _on_attack_clicked() -> void:
	state_machine.dispatch(ATTACK_CLICKED)
	

func _on_gameplay_event(event: GameplayEvent.Values, cargo: Variant) -> void:
	match event:
		GameplayEvent.Values.FUNDS_EARNED:
			await on_funds_earned(cargo)
		GameplayEvent.Values.FUNDS_SPENT:
			await on_funds_spent(cargo)
		GameplayEvent.Values.CAPTURE:
			await on_capture(cargo)
		GameplayEvent.Values.COMBAT:
			await on_combat(cargo)
		

func on_funds_earned(cargo: Variant) -> void:
	if not cargo is Team:
		return

	var team: Team = cargo as Team
	var id: int = AudioService.play_loop(earn_coin_audio, team_display.global_position)
	await team_display.update_funds(team.funds)
	AudioService.stop(id)

	active_controller.animation_finished.emit()


func on_funds_spent(cargo: Variant) -> void:
	if not cargo is Team:
		return

	var team: Team = cargo as Team
	var id: int = AudioService.play_loop(spent_coin_audio, team_display.global_position)
	await team_display.update_funds(team.funds)
	AudioService.stop(id)
	
	active_controller.animation_finished.emit()


func on_capture(cargo: Variant) -> void:
	if not cargo is CaptureResult:
		return

	var result: CaptureResult = cargo as CaptureResult
	await capture_orchestrator.execute(result)
	active_controller.animation_finished.emit()


func on_combat(cargo: Variant) -> void:
	if not cargo is CombatResult:
		return

	var result: CombatResult = cargo as CombatResult
	await combat_orchestrator.execute(result)
	active_controller.animation_finished.emit()


func switch_team(new_team: Team) -> void:
	is_playable = new_team.is_playable()
	if active_controller != null:
		active_controller.gameplay_event.disconnect(_on_gameplay_event)
			
	active_controller = new_team.controller
	active_controller.gameplay_event.connect(_on_gameplay_event)
	state_machine.dispatch(RESET_SIGNAL)


func switch_to_previous_state() -> void:
	state_machine.change_active_state(state_machine.get_previous_active_state())


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


func handle_long_press(cell: Vector2i) -> void:
	var long_press_result: LongPressResult = active_controller.handle_long_press(cell)
	if long_press_result.unit == null and long_press_result.building == null:
		return
		
	action_running_state.clear_selections = false
	state_machine.dispatch(ACTION_RUNNING_SIGNAL)

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


func handle_cell_tap_async(cell: Vector2i) -> void:
	var result: CellTapResult.Values = await active_controller.handle_cell_tap(cell)
	match result:
		CellTapResult.Values.ENTER_ATTACK_MODE:
			state_machine.dispatch(ATTACK_SIGNAL)
		CellTapResult.Values.UNIT_MOVED:
			switch_to_previous_state()
		CellTapResult.Values.NONE:
			switch_to_previous_state()


func handle_attack_async() -> void:
	await active_controller.perform_combat()
	state_machine.dispatch(RESET_SIGNAL)


func handle_build_async(entry: ProductionEntry) -> void:
	production_panel.hide()
	await team_display.animate_in()
	await active_controller.buy_unit(entry)
	state_machine.dispatch(RESET_SIGNAL)



func show_combat_dialog() -> void:
	var edr: EstimatedDamageResult = active_controller.estimate_damage()
	
	if edr.building == null:
		combat_popup.with_terrain(edr.terrain_data)
	else:
		combat_popup.with_building(edr.building)

	combat_popup.with_estimated_damage(edr.estimated_damage)
	combat_popup.with_unit(edr.defender)

	combat_popup.position_dialog(edr.defender)
	combat_popup.animate_in()
