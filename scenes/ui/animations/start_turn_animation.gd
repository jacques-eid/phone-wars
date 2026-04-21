class_name StartTurnAnimation
extends Control


@onready var banner: PanelContainer = $Banner
@onready var title_label: RichTextLabel = $Banner/HBoxContainer/TitleLabel
@onready var team_label: RichTextLabel = $Banner/HBoxContainer/TeamLabel


func _ready() -> void:
	banner.size.x = get_viewport_rect().size.x
	banner.material = banner.material.duplicate()
	reset_banner_position()


func play(team: Team, from_load: bool) -> void:
	if from_load:
		title_label.text = "Resume Turn:"
	
	set_team_label(team)
	team.replace_ui_colors(banner.material)
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	await animate_banner_in()
	await get_tree().create_timer(0.3).timeout
	await animate_team_label_display()
	await get_tree().create_timer(0.5).timeout
	await animate_banner_out()

	reset_banner_position()
	title_label.text = "New Turn:"


func set_team_label(team: Team) -> void:
	team_label.text = team.team_name()
	team_label.visible_ratio = 0.0


func animate_banner_in() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	var screen_center: Vector2 = get_viewport_rect().size * 0.5

	# Vertical center
	banner.position.y = screen_center.y - banner.size.y * 0.5

	var target_x: float = screen_center.x - banner.size.x * 0.5
	tween.tween_property(banner, "position:x", target_x, 0.5)

	await tween.finished

	
func animate_banner_out() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	var screen_size: Vector2 = get_viewport_rect().size

	var target_x: float = screen_size.x + banner.size.x
	tween.tween_property(banner, "position:x", target_x, 0.5)

	await tween.finished


func animate_team_label_display() -> void:
	var tween = create_tween()
	tween.tween_property(team_label, "visible_ratio", 1.0, 1.0)

	await tween.finished


func reset_banner_position() -> void:
	var screen_center: Vector2 = get_viewport_rect().size * 0.5
	banner.position.y = screen_center.y - banner.size.y * 0.5
	banner.position.x = - banner.size.x
