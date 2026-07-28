class_name WeaponModifierData extends PartData

var boundary_mask := Boundary.ALL_EDGES
var modifiers := WeaponModifiers.new():
	set = set_modifiers
var modifier_data: Dictionary:
	get = get_modifier_data,
	set = set_modifier_data

func get_modifier_data() -> Dictionary:
	return modifiers.to_dict()

func set_modifier_data(new_modifier_data: Dictionary) -> void:
	modifiers.load_dict(new_modifier_data)

func set_modifiers(new_modifiers) -> void:
	modifiers = new_modifiers if new_modifiers != null else modifiers
