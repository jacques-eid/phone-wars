class_name DebugHelper


static var counters = {
    UnitType.Values.INFANTRY: 0,
    UnitType.Values.RECON: 0,
    UnitType.Values.ARTILLERY: 0,
    UnitType.Values.LIGHT_TANK: 0,
}

static func generate_unit_name(unit_type: UnitType.Values, team_id: int) -> String:
    counters[unit_type] += 1

    return "T%d_%s_%d" % [
        team_id,
        UnitType.get_name_from_type(unit_type),
        counters[unit_type]
    ]