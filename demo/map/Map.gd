extends Node2D

const CELESTIAL_T := preload("res://map/Celestial.tscn")
const BACKGROUND_SIZE := Vector2i(2048, 2048)

var central_star := Star.new()
var map_seed := 1
var n_terrestrial_planets := 5
var n_jovian_planets := 10
var min_orbit_radius := 500.0
var frost_line_width := 500.0

var backgrounds: Array = [ # Image paths -->
	preload("res://map/backgrounds/dark/preset_1.png"),
	preload("res://map/backgrounds/light/preset_1.png") ]

@onready var __background_image := $Background/BackgroundImage

func generate_cluster(orbit_radius: float, center: Node2D, n_celestials: float, config: Dictionary) -> float:
	var orbit_spacing: float = config.orbit_spacing
	for n in range(n_celestials):
		var celestial := CELESTIAL_T.instantiate()
		celestial.orbit_radius = orbit_radius
		celestial.gravity = globals.gravity * center.mass
		celestial.config = config
		orbit_radius += orbit_spacing
		add_child(celestial)
	return orbit_radius

func generate():
	seed(map_seed)
	add_child(central_star)
	__background_image.texture = backgrounds.pick_random()
	var orbit_radius := min_orbit_radius
	orbit_radius = generate_cluster(orbit_radius, central_star, n_terrestrial_planets, globals.terrestrial_config)
	orbit_radius = generate_cluster(orbit_radius + frost_line_width, central_star, n_jovian_planets, globals.jovian_config)

func _ready():
	generate()
