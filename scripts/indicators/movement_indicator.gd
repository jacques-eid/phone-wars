class_name MovementIndicator
extends Node2D

@export var color := Color(0.2, 0.6, 1.0, 0.75)

var grid: Grid
var cells: Array[Vector2i] = []


func setup(p_grid: Grid, ui_controller: UIController):
	grid = p_grid

	ui_controller.show_movement_range.connect(show_cells)
	ui_controller.clear_movement_range.connect(clear)


func _draw() -> void:
	for cell: Vector2i in cells:
		var pos: Vector2 = grid.get_world_position_from_cell(cell)
		draw_rect(
			Rect2(pos-Const.CELL_SIZE*0.5, Const.CELL_SIZE),
			color,
		)


func show_cells(reachable_cells: Array[Vector2i]):
	cells = reachable_cells.duplicate()
	queue_redraw()


func clear():
	cells.clear()
	queue_redraw()
