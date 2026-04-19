class_name ProductionEntryPanel
extends Control


signal build_button_clicked(entry: ProductionEntry)


@onready var unit_icon: TextureRect = $PanelContainer/VBoxContainer/HBoxContainer/UnitIcon
@onready var unit_name: Label = $PanelContainer/VBoxContainer/HBoxContainer/UnitName
@onready var unit_cost: Label = $PanelContainer/VBoxContainer/HBoxContainer/UnitCost

@onready var build_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/BuildButton


func load_from_entry(entry: ProductionEntry, controller: TeamController) -> void:
	unit_name.text = UnitType.get_name_from_type(entry.unit_type)
	unit_cost.text = "%s"%entry.cost()
	unit_icon.texture = entry.unit_profile.icon.duplicate()
	controller.team.replace_unit_colors(unit_icon.material)
	
	build_button.disabled = not controller.can_buy(entry)

	build_button.pressed.connect(func(): build_button_clicked.emit(entry))
	
