class_name MainMenu
extends Control


@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

@onready var music_manager: MusicManager = $Musics/MusicManager
@onready var music_service: MusicService = $Musics/MusicService

# Use load to prevent circular references in preloading scenes
@onready var level1_scene: PackedScene = load("res://scenes/levels/level1.tscn")
@onready var credits_scene: PackedScene = load("res://scenes/screens/credits_screen.tscn")


func _ready() -> void:
	music_manager.setup(music_service)

	play_button.pressed.connect(_on_play_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	load_button.disabled = not SaveManager.save_exists()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(level1_scene)


func _on_load_button_pressed() -> void:
	get_tree().change_scene_to_file(SaveManager.load_game())


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scene)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
