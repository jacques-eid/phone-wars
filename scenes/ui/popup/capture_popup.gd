class_name CapturePopup
extends BasePopup


@onready var capture_points_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CapturePointsLabel
@onready var max_capture_points_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MaxCapturePointsLabel
@onready var capture_points_texture: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/CapturePoints

@onready var capture_animation: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2
@onready var unit_proxy: UnitProxy = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/UnitProxyWrapper/UnitProxy
@onready var building_icon: Sprite2D = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/BuildingIconWrapper/BuildingIcon
@onready var building_icon_wrapper: Control = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/BuildingIconWrapper


func load(result: CaptureResult) -> void:
    capture_points_label.text = "%s" % result.previous_capture_points
    max_capture_points_label.text = "%s" % result.max_capture_points

    var ratio: float = result.previous_capture_points as float / result.max_capture_points
    capture_points_texture.scale.x = ratio

    unit_proxy.load_from_unit(result.unit)

    building_icon.texture = result.building.icon().duplicate()
    building_icon.position = Const.CELL_SIZE / 2.0

    if unit_proxy.facing == FaceDirection.Values.LEFT:
        capture_animation.move_child(building_icon_wrapper, 0)
    else:
        capture_animation.move_child(building_icon_wrapper, 1)

    result.building.team.replace_building_colors(building_icon.material)


func update(result: CaptureResult) -> void:
    var tween = create_tween()
    tween.set_parallel(true)

    tween.tween_method(
        func(value: float):
            capture_points_label.text = str(int(round(value))),
        float(capture_points_label.text),
        result.new_capture_points,
        1.5)

    var ratio: float = result.new_capture_points as float / result.max_capture_points
    tween.tween_property(
        capture_points_texture,
        "scale:x",
        ratio,
        1.5)

    await tween.finished
    await get_tree().create_timer(0.5).timeout



func play_unit_attack(fx_service: FXService) -> void:
    await unit_proxy.play_attack(fx_service)


func play_building_impacts(fx_service: FXService) -> void:
    var weapon: Weapon = unit_proxy.weapon
    weapon._play_impact(unit_proxy.facing, building_icon, fx_service.play_ui_fx)