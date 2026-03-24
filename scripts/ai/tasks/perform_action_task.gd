extends AsyncTask


func _run_async() -> void:
    var top_result: AIActionResult = blackboard.get_var("top_result")

    match top_result.type:
        AIActionType.Values.ATTACK:
            _run(handle_attack, top_result)


func handle_attack(top_result: AIActionResult) -> void:
    var ai_controller: AIController = agent as AIController
    ai_controller.target_unit = top_result.target_unit

    if ai_controller.can_attack_without_moving(top_result.target_unit.cell_pos):
        await ai_controller.perform_combat()
        return

    var target_cell: Vector2i = ai_controller.choose_best_attack_position(top_result.target_unit.cell_pos)
    ai_controller.move_command = await ai_controller.move_unit_to_cell(target_cell)
    await ai_controller.perform_combat()

