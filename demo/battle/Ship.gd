class_name Ship extends Unit

signal target_changed(new_target: Target)

static var ui_scale_z_curve := preload("res://battle/curve_camera_z_ui_scale.tres")

@export var bar_hp: PipBar
@export var bar_shield: PipBar
@export var bar_energy: PipBar
@export var always_upright: Node2D
@export var behavior_indicator: Label
@export var part_nodes: Node2D

var shield := 0.0:
	set = set_shield
var energy := 0.0:
	set = set_energy
var target: Target

var _max_hp := 0.0
var _max_shield := 0.0
var _max_energy := 0.0

static func create() -> Ship:
	return preload("res://battle/ship.tscn").instantiate()

var data: ShipData:
	set = set_data

func set_hp(new_hp: float) -> void:
	super.set_hp(minf(new_hp, _max_hp) )

func set_target(new_target: Target) -> bool:
	if target == new_target:
		return true
	target = new_target
	target_changed.emit(target)
	return true

func set_shield(new_shield: float) -> void:
	shield = clampf(new_shield, 0.0, _max_shield)

func set_energy(new_energy: float) -> void:
	energy = clampf(new_energy, 0.0, _max_energy)

func set_data(new_data: ShipData) -> void:
	if data == new_data:
		return
	data = new_data
	for part in part_nodes.get_children():
		part.queue_free()
	if data == null:
		return clear_stats()
	for ship_part in data.node_parts:
		_create_part_node(ship_part)
	texture = data.get_texture()
	size = Grid.TILE_SIZE * data.get_ship_rect().size
	reset_stats()

func clear_stats() -> void:
	thrust = 0.0
	mass = 1.0

func reset_stats() -> void:
	if data == null:
		return
	thrust = data.thrust
	mass = data.mass

func _create_part_node(ship_part: ShipDataPart) -> void:
	assert(ship_part.get_data().becomes_node_on_ship() )
	#
	var part := ship_part.get_data().create_part()
	part_nodes.add_child(part)
	part._ship_init(ship_part, self)

func hit_shield(damage: float) -> float:
	var new_shield := shield - damage
	shield = new_shield
	return shield - new_shield

func hit(damage: float, from: Player = null, shield_penetration := 0.0) -> void:
	assert(0.0 <= shield_penetration and shield_penetration <= 1.0)
	#
	var shield_damage := shield_penetration * damage
	var shield_overkill := hit_shield(shield_damage)
	super.hit(damage - shield_damage + shield_overkill, from)

func update_behavior_indicator() -> void:
	var behavior := get_behavior_flags()
	var text := ""
	if behavior & BehaviorFlags.KITE:
		text += " KITE "
	if behavior & BehaviorFlags.BROADSIDE:
		text += " BROADSIDE "
	if behavior & BehaviorFlags.TRACK:
		text += " TRACK "
	if behavior & BehaviorFlags.FLEE:
		text += " FLEE "
	if behavior & BehaviorFlags.ATTACK:
		text += " ATTACK "
	behavior_indicator.text = text

func _process(_dt: float) -> void:
	update_behavior_indicator()
	always_upright.global_rotation = 0.0
	always_upright.global_scale = Vector2.ONE * ui_scale_z_curve.sample_baked(globals.main.camera.z)
	#bar_hp.value = hp
	#bar_shield.value = shield
	#bar_energy.value = energy
