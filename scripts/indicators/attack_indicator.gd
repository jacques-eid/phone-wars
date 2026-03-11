class_name AttackIndicator
extends Node2D

@export var color := Color(1, 0, 0, 0.75)

var grid: Grid

var cells: Array[Vector2i] = []
var units: Array[Unit] = []


func setup(p_grid: Grid, ui_controller: UIController):
	grid = p_grid 

	ui_controller.show_attackable.connect(show_cells)
	ui_controller.clear_attackable.connect(clear)
	
	material = material.duplicate()
	material.set_shader_parameter("base_color", color)


func _draw() -> void:
	for cell in cells:
		var pos: Vector2 = grid.get_world_position_from_cell(cell)
		draw_rect(
			Rect2(pos-Const.CELL_SIZE*0.5, Const.CELL_SIZE),
			color,
		)


func show_cells(new_cells: Array[Vector2i]):
	cells = new_cells.duplicate()
	queue_redraw()


func clear():
	cells.clear()
	queue_redraw()
