class_name MoveUnitCommand
extends Command

var unit: Unit
var start_pos: Vector2
var start_cell: Vector2i
var target_cell: Vector2i
var path: Pathfinding.Path
var capture_process: CaptureProcess
var facing: FaceDirection.Values

func _init(p_unit: Unit, p_target_cell: Vector2i, p_path: Pathfinding.Path):
	unit = p_unit
	capture_process = unit.capture_process
	start_pos = p_unit.global_position
	start_cell = p_unit.cell
	target_cell = p_target_cell
	path = p_path
	facing = unit.facing


func execute():
	unit.cell = target_cell
	unit.movement_points -= path.cost
	unit.move_following_path(path.world_points)


func undo():
	unit.facing = facing
	unit.cell = start_cell
	unit.movement_points += path.cost
	unit.global_position = start_pos
	unit.select()
	if capture_process != null:
		unit.capture_process = CaptureProcess.load_from_capture_process(capture_process)
		capture_process = null
