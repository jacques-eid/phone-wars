class_name ProductionPanel
extends Control

signal cancel_button_clicked()
signal build_clicked(entry: ProductionEntry)


@onready var entry_scene: PackedScene = load("res://scenes/ui/buildings/production_entry_panel.tscn")
@onready var cancel_button: Button = $PanelContainer/MarginContainer/CancelButton
@onready var production_list: VBoxContainer = $PanelContainer/MarginContainer/MarginContainer/ProductionList


func _ready() -> void:
	cancel_button.pressed.connect(func(): cancel_button_clicked.emit())



func load_production_list(prod_list: ProductionList, controller: TeamController) -> void:
	# Clear previous
	for child in production_list.get_children():
		child.queue_free()

	# Build new
	for entry in prod_list.entries:
		var ui_entry: ProductionEntryPanel = entry_scene.instantiate()
		production_list.add_child(ui_entry)
		ui_entry.load_from_entry(entry, controller)
		ui_entry.build_button_clicked.connect(func(e: ProductionEntry): build_clicked.emit(e))
	
	