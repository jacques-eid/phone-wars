class_name UIState
extends State


var ui_controller: UIController

func _init(state_name: String, p_controller: UIController) -> void:
	super._init(state_name)
	ui_controller = p_controller

func _enter(_params: Dictionary = {}) -> void:
	pass


func _exit() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _on_cell_tap(_cell: Vector2i) -> void:
	pass


func _on_long_press(_cell: Vector2i) -> void:
	pass
	

func _on_long_press_release(_cell: Vector2i) -> void:
	pass
	

func _on_cancel_clicked() -> void:
	pass


func _on_build_clicked(_entry: ProductionEntry) -> void:
	pass


func _on_attack_clicked() -> void:
	pass
