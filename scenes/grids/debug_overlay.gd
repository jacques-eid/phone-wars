class_name DebugOverlay
extends Node2D

@export var grid: Grid
@export var show_cells: bool = true
@export var highlight_cell: Vector2i = Vector2i(-1, -1)


func _ready() -> void:
	grid.cell_short_tap.connect(on_cell_clicked)

func _draw():
	for grid_map in grid.terrain_manager.terrain_layers:			
		# Draw grid
		if show_cells:
			for cell in grid_map.get_used_cells():
				var local_pos = cell * Const.CELL_SIZE
				draw_rect(Rect2(local_pos, Const.CELL_SIZE), Color(1, 1, 1, 0.3), false, 1.0)

		# Highlight a cell (e.g., mouse over)
		# if highlight_cell.x != -1:
		# 	var local_pos = highlight_cell * cell_size
		# 	draw_rect(Rect2(local_pos, cell_size), Color(0, 1, 0, 0.3), true)


func on_cell_clicked(cell: Vector2i) -> void:
	highlight_cell = cell
	queue_redraw()  # triggers _draw()
