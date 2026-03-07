class_name SelectionIndicator
extends Node2D

@export var color := Color(0.7, 0.6, 0.2, 0.75)

var grid: Grid
var has_selection: bool
var selected_pos: Vector2i

func setup(p_grid: Grid, ui_controller: UIController):
	grid = p_grid

	ui_controller.show_selected.connect(show_selected)
	ui_controller.clear_selected.connect(clear)
	
	material = material.duplicate()
	material.set_shader_parameter("base_color", color)


func _draw() -> void:
	if not has_selection:
		return

	var pos: Vector2 = grid.get_world_position_from_cell(selected_pos)
	draw_rect(
		Rect2(pos-Const.CELL_SIZE*0.5, Const.CELL_SIZE),
		color,
	)



func show_selected(cell_pos: Vector2i):
	has_selection = true
	selected_pos = cell_pos
	queue_redraw()


func clear():
	has_selection = false
	queue_redraw()
