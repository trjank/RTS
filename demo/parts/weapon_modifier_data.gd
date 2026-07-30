class_name WeaponModifierData extends PartData

var modifiers := WeaponModifiers.new():
	set = set_modifiers
var modifier_data: Dictionary:
	get = get_modifier_data,
	set = set_modifier_data
var modifier_boundary := Boundary.ALL_EDGES
var modshare_efficiency := 1.0

func get_modifier_data() -> Dictionary:
	return modifiers.to_dict()

func set_modifier_data(new_modifier_data: Dictionary) -> void:
	modifiers.load_dict(new_modifier_data)

func set_modifiers(new_modifiers) -> void:
	modifiers = new_modifiers if new_modifiers != null else modifiers

func create_ship_data_part(id := ShipData.NULL_ID, rect := Rect2i(), rotation := Rotation.Discrete.ROT_0, boundary := _boundary) -> ShipDataPart:
	return ShipDataWeaponModifier.new(id, self, rect, rotation, boundary)
