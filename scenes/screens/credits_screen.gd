extends Control


@onready var main_menu_scene: PackedScene = preload("res://scenes/main_menu/main_menu.tscn")



@onready var credits_root: Control = $CreditsRoot

var scroll_speed: float = 50.0
var is_running: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	credits_root.position.y = get_viewport_rect().size.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_running:
		return

	credits_root.position.y -= scroll_speed * delta

	if credits_root.position.y < -credits_root.size.y:
		exit_credits()


func _input(event) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			exit_credits()


func exit_credits() -> void:
	is_running = false

	var tween = create_tween()
	tween.tween_property(credits_root, "modulate:a", 0.0, 0.3)

	await tween.finished
	get_tree().change_scene_to_packed(main_menu_scene)
