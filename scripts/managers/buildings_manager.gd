class_name BuildingsManager
extends Node

var grid: Grid
var buildings: Dictionary = {} # Vector2i -> Unit

func setup() -> void:
	init_buildings()


func init_buildings() -> void:
	for building in get_children():
		if building is Building:
			var cell_pos: Vector2i = Vector2i(building.position / Vector2(Const.CELL_SIZE))
			buildings[cell_pos] = building
			building.cell_pos = cell_pos
			building.setup()
			print("adding building %s at %s" % [building.name, building.cell_pos])
			

func get_building_at(cell_pos: Vector2i) -> Building:
	return buildings.get(cell_pos, null) as Building


func get_hq_count(team: Team) -> int:
	var count: int = 0
	for building: Building in buildings.values():
		if building.type() == BuildingType.Values.HQ and \
			building.team.is_same_team(team):
			count +=1

	return count
