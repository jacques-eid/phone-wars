class_name SettingsHUD
extends Control

signal resume_button_clicked(toast_message: String)
signal save_button_clicked()
signal load_button_clicked()
signal exit_button_clicked()


@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var save_button: Button = $PanelContainer/VBoxContainer/SaveButton
@onready var load_button: Button = $PanelContainer/VBoxContainer/LoadButton
@onready var exit_button: Button = $PanelContainer/VBoxContainer/ExitButton


func _ready() -> void:
	visible = false
	resume_button.pressed.connect(func(): resume_button_clicked.emit(""))
	save_button.pressed.connect(on_save_game)
	load_button.pressed.connect(func(): load_button_clicked.emit())
	exit_button.pressed.connect(func(): exit_button_clicked.emit())
	
	load_button.disabled = not SaveManager.save_exists()



func on_save_game() -> void:
	save_button.disabled = true
	save_button.text = "Saving..."

	save_button_clicked.emit()

	save_button.text = "Save"
	save_button.disabled = false

	resume_button_clicked.emit("Game saved")
