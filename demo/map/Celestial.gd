extends Node2D

static var time_to_capture := 5.0

const ORBIT_COLOR     := Color(1.0, 1.0, 1.0, 0.3)
const ORBIT_THICKNESS := 1.0
const ORBIT_QUALITY   := 100

var angular_velocity := 10.0
var gravity          := 0.0
var orbit_radius     := 0.0
var mass             := 0.0
var radius           := 0.0
var n_capturing      := 0
var capturable       := false

var config: Dictionary

@export var name_label: Label
@export var indicators: Control
@export var image: Sprite2D
@export var image_container: Node2D
@export var sphere_shader: ShaderMaterial

func _ready():
	position = Vector2.LEFT
	radius   = randf_range(config.min_radius, config.max_radius)
	mass     = randf_range(config.min_mass, config.max_mass)
	##########################################################
	var diameter := 2.0 * radius
	var new_size := Vector2(diameter, diameter)
	##########################################################
	image.texture = load(config.images.pick_random())
	image.scale = new_size / image.texture.get_size()
	image.material = sphere_shader.duplicate()
	indicators.position.y = -radius
	name_label.text = config.names.pick_random()

func _physics_process(delta):
	var speed := sqrt(gravity / orbit_radius)
	var dir   := position.normalized()
	var mat2  := Transform2D(image.rotation, Vector2.ZERO)
	image.rotation += angular_velocity * delta
	image.material.set_shader_parameter("transform", mat2)
	image_container.rotation = Vector2.UP.angle_to(dir)
	position = orbit_radius * dir.rotated(speed * delta)

func _process(_delta):
	queue_redraw()
	
func _draw():
	if not selected: return
	draw_arc(
		-position, orbit_radius,
		0, TAU, ORBIT_QUALITY,
		ORBIT_COLOR, ORBIT_THICKNESS, true)
	# ADD MORE HERE AS NECESSARY

# CLEAN THIS SPAGHETTI CODE UP PLZ
var selected := false
func on_select():
	selected = true
func on_deselect():
	selected = false
func get_bounding_box() -> Rect2:
	return global_transform * image.get_rect()
var bounding_box: Rect2: get = get_bounding_box
