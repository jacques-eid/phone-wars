class_name DebugOverlay
extends Node2D

@export var grid: Grid
@export var show_cells: bool = true
@export var show_coordinates: bool = false
@export var highlight_cell: Vector2i = Vector2i(-1, -1)

@onready var font: Font = preload("res://assets/fonts/Pixel Lofi.otf")

func _ready() -> void:
	grid.cell_short_tap.connect(_on_cell_clicked)
	
	
func _draw():
	if not show_cells:
		return

	for cell in grid.terrain_manager.terrain_cells.keys():
		var local_pos = cell * Const.CELL_SIZE
		draw_rect(Rect2(local_pos, Const.CELL_SIZE), Color(1, 1, 1, 0.3), false, 1.0)
		if show_coordinates:
			local_pos.y += Const.CELL_SIZE.y # Add an offset to write it on the bottom
			draw_string(font, local_pos, "%s:%s"%[cell.x, cell.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 12)

		# Highlight a cell (e.g., mouse over)
		# if highlight_cell.x != -1:
		# 	var local_pos = highlight_cell * cell_size
		# 	draw_rect(Rect2(local_pos, cell_size), Color(0, 1, 0, 0.3), true)


func _on_cell_clicked(cell: Vector2i) -> void:
	highlight_cell = cell
	queue_redraw()  # triggers _draw()
