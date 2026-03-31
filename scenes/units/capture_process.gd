class_name CaptureProcess
extends Resource


var building: Building
var capturing_component: CapturingComponent
var progress: int

func _init(build: Building, unit: Unit) -> void:
	building = build
	progress = building.max_capture_points()
	capturing_component = unit.capturing_component
	capturing_component.show()
	

static func load_from_capture_process(cp: CaptureProcess, unit: Unit) -> CaptureProcess:
	var new_cp: CaptureProcess = CaptureProcess.new(cp.building, unit)
	new_cp.progress = cp.progress

	return new_cp
	

func resolve(unit: Unit) -> CaptureResult:
	var result: CaptureResult = CaptureResult.new()
	result.building = building
	result.unit = unit

	if unit.team.is_same_team(building.team):
		return result

	result.max_capture_points = building.max_capture_points()
	result.previous_capture_points = progress
	
	progress -= unit.capture_capacity()
	if progress <= 0:
		progress = 0
		result.capture_done = true

	result.new_capture_points = progress
	print("capture_capacity %s / progress %s" %[unit.capture_capacity(), progress])

	return result

	
func capture_done(unit: Unit) -> void:	
	if progress > 0:
		return

	building.captured(unit.team)


func clear_capture() -> void:
	capturing_component.hide()


func can_finish_next_turn(unit: Unit) -> bool:
	return unit.capture_capacity() > progress
