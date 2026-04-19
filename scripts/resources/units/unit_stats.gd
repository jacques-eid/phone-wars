class_name UnitStats
extends Resource


var movement_points: int
var capture_capacity: int
var health: int
var cost: int
var min_range: int
var max_range: int


func _to_string() -> String:
    return "mov_points: [%s] - capture_points: [%s] - max_healh: [%s] - \
cost: [%s] - range: [%s-%s]" % [
            movement_points,
            capture_capacity,
            health,
            cost,
            min_range,
            max_range
        ] 