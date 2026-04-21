class_name BuildingsManager
extends Node

var grid: Grid
var buildings: Dictionary[Vector2i, Building] = {}

func setup() -> void:
	init_buildings()


func init_buildings() -> void:
	for building in get_children():
		if building is Building:
			var cell_pos: Vector2i = Vector2i(floor(building.position / Vector2(Const.CELL_SIZE)))
			buildings[cell_pos] = building
			building.cell = cell_pos
			building.setup()
			print("adding building %s [%s] at %s" % [building.name, building.team, building.cell])
			

func get_buildings() -> Array[Building]:
	var results: Array[Building]
	results.assign(buildings.values())
	return results


func get_buildings_with_filter(callable: Callable) -> Array[Building]:
	var res: Array[Building]
	var arr = buildings.values().filter(func(building: Building): return callable.call(building))
	res.assign(arr)
	return res


func get_friendly_buildings(team: Team) -> Array[Building]:
	return get_buildings_with_filter(func(building: Building): return building.team.is_same_team(team))


func get_enemy_buildings(team: Team) -> Array[Building]:
	return get_buildings_with_filter(func(building: Building): return not building.team.is_same_team(team))


func get_building_at(cell_pos: Vector2i) -> Building:
	return buildings.get(cell_pos, null) as Building


func get_hq_count(team: Team) -> int:
	var count: int = 0
	for building: Building in buildings.values():
		if building.type() == BuildingType.Values.HQ and \
			building.team.is_same_team(team):
			count +=1

	return count
