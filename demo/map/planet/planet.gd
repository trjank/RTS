@tool
class_name Planet extends Orbiter

const LABEL_OFFSET_METERS := 2.0
const MIN_RADIUS := 0.0
const MAX_RADIUS := 100.0
const MIN_CAPTURE_TIME_SEC := 0.1

@export var ui: Node3D
@export var label: Label3D
@export var mesh_instance: MeshInstance3D
@export var zone: Area3D
@export var zone_shape: CollisionShape3D
@export var hitbox: StaticBody3D
@export var hitbox_shape: CollisionShape3D
@export var progress_bar: PipBar
@export var low_lod_icon: Sprite3D

var resource_rate := StrategicResources.new()
var capturable := true:
	set = set_capturable
var capture_time_sec := 5.0:
	set = set_capture_time_sec
var capture_progress := 0.0:
	set = set_capture_progress
var display_name: String:
	set = set_display_name
var radius := MIN_RADIUS:
	set = set_radius
var team_owner: Team:
	set = set_team_owner
var capture_zone_radius_ratio := 1.5
var low_lod := true:
	set = set_low_lod

var _capturing_team: Team
var _contesting_team: Team
var _team_ship_count: Dictionary[Team, int] = {}

static func _ship_to_team(ship: Ship) -> Team:
	return ship.player_owner.team if ship.player_owner != null else null

func _ready() -> void:
	super()
	#
	zone.collision_mask = Globals.Layer.SHIPS
	hitbox.collision_mask = Globals.Layer.CAMERA | Globals.Layer.SCENERY
	hitbox.collision_layer = Globals.Layer.CAMERA | Globals.Layer.SCENERY

func is_captured() -> bool:
	return team_owner != null

func is_contested() -> bool:
	return _contesting_team != null

func get_capturing_team() -> Team:
	return _capturing_team

func get_contesting_team() -> Team:
	return _contesting_team

func get_capture_ratio() -> float:
	return capture_progress / capture_time_sec

func count_capturing_ships(team: Team) -> int:
	return _team_ship_count.get(team, 0)

func set_low_lod(is_low_lod: bool) -> void:
	low_lod = is_low_lod
	low_lod_icon.visible = is_low_lod
	ui.visible = not is_low_lod
	mesh_instance.visible = not is_low_lod

func set_display_name(new_display_name: String) -> void:
	display_name = new_display_name
	label.text = display_name if is_zero_approx(resource_rate.alloy) else "%s | %.1f" % [display_name, resource_rate.alloy]

func set_capturable(is_capturable: bool) -> void:
	capturable = is_capturable
	progress_bar.visible = is_capturable
	zone_shape.disabled = not is_capturable

func set_capture_time_sec(new_capture_time_sec: float) -> void:
	capture_time_sec = maxf(new_capture_time_sec, MIN_CAPTURE_TIME_SEC)
	capture_progress = 0.0
	progress_bar.max_value = capture_time_sec

func set_capture_progress(new_capture_progress: float) -> void:
	capture_progress = clampf(new_capture_progress, 0.0, capture_time_sec)
	#
	if capture_progress == 0.0:
		_capturing_team = _contesting_team
		progress_bar.pip_color = _capturing_team.color
	elif capture_time_sec == capture_progress:
		team_owner = _capturing_team
	progress_bar.value = capture_progress

func set_radius(new_radius: float) -> void:
	radius = clampf(new_radius, MIN_RADIUS, MAX_RADIUS)
	zone_shape.shape.radius = capture_zone_radius_ratio * radius
	hitbox_shape.shape.radius = radius
	label.position.z = -radius - LABEL_OFFSET_METERS
	# NOTE: Ensure the mesh's size is one for this to work
	mesh_instance.scale = radius * Vector3.ONE
	low_lod_icon.pixel_size = Measurement.METERS_PER_PX * radius

func set_team_owner(new_team_owner: Team) -> void:
	if team_owner == new_team_owner:
		return
	if team_owner != null:
		team_owner.register_loss(self)
	if new_team_owner != null:
		new_team_owner.register_capture(self)
		progress_bar.base_color = new_team_owner.color
	team_owner = new_team_owner

func _physics_process(dt: float) -> void:
	super(dt)
	#
	if _contesting_team == null:
		return
	dt *= battle.time_scale
	capture_progress += dt if _contesting_team == _capturing_team else -dt

func _process(_dt: float) -> void:
	ui.global_rotation = Vector3.ZERO
	#low_lod = global_position.distance_to(get_viewport().get_camera_3d().global_position) > 50.0

func update_contesting_team() -> void:
	_team_ship_count.clear()
	_contesting_team = null
	#
	for team in zone.get_overlapping_bodies().map(_ship_to_team):
		_team_ship_count[team] = _team_ship_count.get(team, 0) + 1
	for team in _team_ship_count:
		_contesting_team = team if _contesting_team == null or _team_ship_count[team] > _team_ship_count[_contesting_team] else _contesting_team

func generate_from_map() -> void:
	super()
	#
	capturable = map.preset.get("capturable", true)
	capture_zone_radius_ratio = float(map.preset.get("capture_zone_radius_ratio", 1.5) )
	radius = generate_randf_range("min_radius", "max_radius", MIN_RADIUS, MAX_RADIUS)
	mesh_instance.rotation.x = generate_randf_radians("min_tilt", "max_tilt")
	display_name = map.preset.get("display_name", "").format({
		"index": index + 1,
		"roman_numeral": get_roman_numeral()
	})
	ui.position = Vector3.ZERO

func _on_area_3d_body_entered(body: Node3D) -> void:
	assert(body is Ship, "(Planet) Incorrect collision mask")
	#
	update_contesting_team()

func _on_area_3d_body_exited(body: Node3D) -> void:
	assert(body is Ship, "(Planet) Incorrect collision mask")
	#
	update_contesting_team()
