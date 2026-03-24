class_name GameHUD
extends Control

signal cancel_button_clicked()
signal end_turn_button_clicked()

signal settings_button_clicked()

signal idle_button_clicked()
signal attack_button_clicked()
signal capture_button_clicked()
signal merge_button_clicked()

@onready var cancel_button: Button = $MarginContainer/HBoxContainer/MainPanel/CancelButton
@onready var end_turn_button: Button = $MarginContainer/HBoxContainer/MainPanel/EndTurnButton

@onready var settings_button: Button = $MarginContainer/SettingsButton

@onready var action_panel: HBoxContainer = $MarginContainer/HBoxContainer/ActionPanel 
@onready var idle_button: Button = $MarginContainer/HBoxContainer/ActionPanel/IdleButton
@onready var attack_button: Button = $MarginContainer/HBoxContainer/ActionPanel/AttackButton
@onready var capture_button: Button = $MarginContainer/HBoxContainer/ActionPanel/CaptureButton
@onready var merge_button: Button = $MarginContainer/HBoxContainer/ActionPanel/MergeButton


var lock_visibility: bool

func _ready() -> void:
	cancel_button.pressed.connect(func(): cancel_button_clicked.emit())
	end_turn_button.pressed.connect(func(): end_turn_button_clicked.emit())
	settings_button.pressed.connect(func(): settings_button_clicked.emit())
	idle_button.pressed.connect(func(): idle_button_clicked.emit())
	attack_button.pressed.connect(func(): attack_button_clicked.emit())
	capture_button.pressed.connect(func(): capture_button_clicked.emit())
	merge_button.pressed.connect(func(): merge_button_clicked.emit())


func show_attack_preview_state() -> void:
	visible = true
	action_panel.visible = true
	idle_button.visible = false
	capture_button.visible = false
	merge_button.visible = false
	attack_button.visible = true
	cancel_button.visible = true
	end_turn_button.visible = false


func show_idle_state(lock_controller: bool) -> void:
	if lock_controller:
		visible = false
		lock_visibility = true
		return
		
	lock_visibility = false
	visible = true
	action_panel.visible = false
	cancel_button.visible = false
	end_turn_button.visible = true


func hide_idle_state() -> void:
	cancel_button.visible = true
	end_turn_button.visible = false


func show_moved_state(show_capture_button: bool, show_merge_button: bool) -> void:
	visible = true
	action_panel.visible = true
	cancel_button.visible = true
	idle_button.visible = true
	attack_button.visible = false
	capture_button.visible = show_capture_button
	merge_button.visible = false

	if show_merge_button:
		idle_button.visible = false
		attack_button.visible = false
		capture_button.visible = false
		merge_button.visible = true


func show_game_hud() -> void:
	if lock_visibility:
		return
	show()
	
	
func hide_game_hud() -> void:
	if lock_visibility:
		return
	hide()