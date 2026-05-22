class_name Planet extends Scenery

const UI_OFFSET := 300.0
const MIN_RADIUS := 0.0
const FALLBACK_TEXTURE := preload("res://icons/texture_not_found.png")

const MOON_SHADER := preload("res://map/procedural_generation/moon/moon.tres")

@export var always_upright: Node3D
@export var label: Label3D
@export var sprite: Sprite3D
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

func get_diameter() -> float:
	return 2 * radius

func set_radius(new_radius: float) -> void:
	radius = maxf(new_radius, MIN_RADIUS)
	zone_shape.shape.radius = radius
	#sprite.size = get_diameter() * Vector2.ONE
	always_upright.position.y = -radius - UI_OFFSET

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

func generate_moon() -> void:
	sprite.material_overlay = MOON_SHADER
	sprite.set_instance_shader_parameter("color", Color(randf(), randf(), randf() ) )
	sprite.set_instance_shader_parameter("random_offset_crater", Vector2(randf(), randf() ) )
	sprite.set_instance_shader_parameter("random_offset_fault", Vector2(randf(), randf() ) )
	sprite.set_instance_shader_parameter("random_offset_shade", Vector2(randf(), randf() ) )

func _ready() -> void:
	super._ready()
	var min_radius := float(_map.preset.get("min_radius", MIN_RADIUS) )
	var max_radius := float(_map.preset.get("min_radius", BIG_NUMBER_NOT_INF) )
	var textures := _map.preset.get("textures", [] ) as Array
	radius = _rng.randf_range(min_radius, max_radius)
	display_name = _map.preset.get("display_name", "")
	if textures.is_empty():
		sprite.texture = FALLBACK_TEXTURE
	else:
		var i := _rng.randi_range(0, textures.size() - 1)
		sprite.texture = textures[i] as Texture2D
	generate_moon()
