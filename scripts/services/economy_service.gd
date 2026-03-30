class_name EconomyService
extends Node


func calculate_income(buildings_manager: BuildingsManager, team: Team) -> int:
	var total_income := 0

	for building: Building in buildings_manager.get_friendly_buildings(team):
		print('building: ', building.name, 'income: ', building.income())
		total_income += building.income()

	return total_income 


func add_money(team: Team, money: int) -> void:
	print('adding money: ', money)
	team.funds += money
