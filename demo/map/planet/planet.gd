class_name Planet extends Scenery

const UI_OFFSET := 1.0
const MIN_RADIUS := 0.0

@export var always_upright: Node3D
@export var offset: Node3D
@export var label: Label3D
@export var mesh_instance: MeshInstance3D
@export var zone: Area3D
@export var zone_shape: CollisionShape3D

var capturable := true:
	set = set_capturable
var alloy_per_sec := 0.0
var energy_per_sec := 0.0
var capture_progress := 0.0
var team_owner: Team
var display_name: String:
	set = set_display_name
var radius := MIN_RADIUS:
	set = set_radius

func set_radius(new_radius: float) -> void:
	radius = maxf(new_radius, MIN_RADIUS)
	zone_shape.shape.radius = radius
	offset.position.z = -radius - UI_OFFSET
	# NOTE: Ensure the mesh's size is one for this to work
	mesh_instance.scale = radius * Vector3.ONE

func set_display_name(new_display_name: String) -> void:
	display_name = new_display_name
	label.text = display_name

func set_capturable(is_capturable: bool) -> void:
	capturable = is_capturable
	always_upright.visible = is_capturable
	zone_shape.disabled = is_capturable

func _process(_dt: float) -> void:
	super._process(_dt)
	always_upright.global_rotation = Vector3.ZERO

func _ready() -> void:
	super._ready()
	var min_radius := float(_map.preset.get("min_radius", MIN_RADIUS) )
	var max_radius := float(_map.preset.get("min_radius", BIG_NUMBER_NOT_INF) )
	radius = _rng.randf_range(min_radius, max_radius)
	display_name = _map.preset.get("display_name", "")
	always_upright.position = Vector3.ZERO
