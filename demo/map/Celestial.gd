extends Node2D

const ORBIT_COLOR := Color(1.0, 1.0, 1.0, 0.3)
const ORBIT_THICKNESS := 0.5
const N_ORBIT_LINE_SEGMENTS := 100

static var time_to_capture := 5.0

var angular_velocity := 3.0
var orbit_radius := 0.0
var gravity := 0.0
var mass := 0.0
var radius := 0.0
var n_capturing := 0
var capturable := false
var selected := false
var upright_text := true
var config: Dictionary
@export var name_label: Label
@export var indicators: Control
@export var image: Sprite2D
@export var celestial_body: Node2D
@export var sphere_shader: ShaderMaterial

func get_speed()->float:
	return sqrt(gravity / orbit_radius)

func _draw():
	draw_arc(Vector2.ZERO, orbit_radius,
		0, TAU, N_ORBIT_LINE_SEGMENTS,
		ORBIT_COLOR, ORBIT_THICKNESS, true)

func _ready():
	position = Vector2.LEFT
	radius   = randf_range(config.min_radius, config.max_radius)
	mass     = randf_range(config.min_mass, config.max_mass)
	#-------------------------------------------------------
	var diameter := 2.0 * radius
	var new_size := Vector2(diameter, diameter)
	#-------------------------------------------------------
	image.texture = load(config.images.pick_random())
	image.scale = new_size / image.texture.get_size()
	image.material = sphere_shader.duplicate()
	indicators.position.y = -radius
	indicators.pivot_offset.y = radius
	name_label.text = config.names.pick_random()

func _physics_process(dt):
	rotate(get_speed() * dt)
	image.rotate(angular_velocity * dt)
	var inv_rot := Transform2D(image.rotation, Vector2.ZERO)
	image.material.set_shader_parameter("inv_rot", inv_rot)
	celestial_body.position = orbit_radius * Vector2.UP
	if upright_text:
		indicators.rotation = -rotation
