class_name EconomyService
extends Node


func calculate_income(buildings_manager: BuildingsManager, team: Team) -> int:
	var total_income := 0

	for building: Building in buildings_manager.buildings.values():
		if building.team.is_same_team(team):
			total_income += building.income()

	return total_income 


func add_money(team: Team, money: int) -> void:
	team.funds += money
