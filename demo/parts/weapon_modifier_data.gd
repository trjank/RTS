class_name WeaponModifierData extends PartData

static func _static_init() -> void:
	PartData.subtypes.weapon_modifier = WeaponModifierData.new
