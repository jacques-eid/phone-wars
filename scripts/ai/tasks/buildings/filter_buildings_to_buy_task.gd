extends BTAction


func _tick(_delta: float) -> Status:
    var ai_controller: AIController = agent as AIController
    var buildings: Array[Building] = ai_controller.get_buildings_to_buy()
    if len(buildings) == 0:
        return FAILURE

    blackboard.clear()
    blackboard.set_var("buildings", buildings)
    var results: Array[AIScoreResult] = []
    blackboard.set_var("results", results)

    return SUCCESS