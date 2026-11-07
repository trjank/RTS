class_name Ship extends Unit

signal target_changed(new_target: Target)

const MIN_MASS := 0.1

static var show_behavior := false

@export var hp_bar: PipBar
@export var shield_bar: PipBar
@export var energy_bar: PipBar
@export var ui: Node3D
@export var behavior_indicator: Label3D
@export var part_nodes: Node3D
@export var detection: Area3D

var shield := 0.0:
	set = set_shield
var energy := 0.0:
	set = set_energy
var target: Target

var _max_hp := 0.0
var _max_shield := 0.0
var _max_energy := 0.0
var _detection_cache: Array[Node3D] = []

static func create() -> Ship:
	return preload("res://ships/ship.tscn").instantiate()

var data: ShipData:
	set = set_data

func _ready() -> void:
	super()
	#
	collision_layer |= Globals.Layer.SHIPS
	behavior_indicator.visible = show_behavior

func set_hp(new_hp: float) -> void:
	super(minf(new_hp, _max_hp) )

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
	#
	for part in part_nodes.get_children():
		part.queue_free()
	if data == null:
		return clear_stats()
	for ship_part in data.node_parts:
		_create_part_node(ship_part)
	texture = data.get_texture()
	sprite.material_override = data.get_material()
	size = Measurement.METERS_PER_TILE * data.get_ship_rect().size
	value = data.cost
	reset_stats()

func set_player_owner(new_player_owner: Player) -> void:
	super(new_player_owner)
	#
	var color := player_owner.color
	color.ok_hsl_l = 0.5
	sprite.set_instance_shader_parameter("player_color", color if player_owner != null else Color.BLACK)
	#sprite.set_instance_shader_parameter("player_color", player_owner.color if player_owner != null else Color.BLACK)

func clear_stats() -> void:
	thrust = 0.0
	hp = 1.0
	mass = 1.0
	value = StrategicResources.NONE
	update_inertia_tensor()

func reset_stats() -> void:
	if data == null:
		return
	_max_hp = data.max_hp
	_max_energy = data.max_energy
	thrust = data.thrust
	hp = data.max_hp
	mass = maxf(data.mass, MIN_MASS)
	update_inertia_tensor()

func update_ui() -> void:
	super()
	#
	if not is_node_ready():
		return
	ui.visible = selected
	hp_bar.max_value = _max_hp
	shield_bar.max_value = _max_shield
	energy_bar.max_value = _max_energy
	shield_bar.visible = not is_zero_approx(_max_shield)

func _on_death_animation() -> void:
	part_nodes.queue_free()

func _create_part_node(ship_part: ShipDataPart) -> void:
	assert(ship_part.get_data().becomes_node_on_ship() )
	#
	var part := ship_part.get_data().create_part()
	part_nodes.add_child(part)
	part.on_ship_ready(ship_part, self)

func is_enemy(unit: Unit) -> bool:
	return player_owner == null or unit.player_owner == null or player_owner.team != unit.player_owner.team

func is_friend(unit: Unit) -> bool:
	return unit != self and not is_enemy(unit)

func _update_detection_cache() -> void:
	_detection_cache = detection.get_overlapping_bodies()
	_detection_cache.sort_custom(distance_sorter)

func find_near(predicate: Callable) -> Array[Node]:
	_update_detection_cache()
	return _detection_cache.filter(predicate)

func find_nearest(predicate: Callable) -> Unit:
	_update_detection_cache()
	var i := _detection_cache.find_custom(predicate, 1)
	return _detection_cache[i] if i != -1 else null

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

func drain_energy(energy_drain: float) -> void:
	energy -= energy_drain

func distance_sorter(a: Node3D, b: Node3D) -> bool:
	return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)

func update_behavior_indicator() -> void:
	var behavior := get_behavior_flags()
	var text := ""
	if behavior & Behavior.KITE:
		text += " KITE "
	if behavior & Behavior.BROADSIDE:
		text += " BROADSIDE "
	if behavior & Behavior.TRACK:
		text += " TRACK "
	if behavior & Behavior.FLEE:
		text += " FLEE "
	if behavior & Behavior.ATTACK:
		text += " ATTACK "
	behavior_indicator.text = text

func _physics_process(dt: float) -> void:
	energy += data.energy_per_sec * dt

func _process(_dt: float) -> void:
	update_behavior_indicator()
	ui.global_rotation = Vector3.ZERO
	hp_bar.value = hp
	shield_bar.value = shield
	energy_bar.value = energy
