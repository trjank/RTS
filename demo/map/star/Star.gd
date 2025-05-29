class_name Star extends Sprite2D

enum { STAR, BLACK_HOLE }
const STAR_SHADER := preload("res://map/star/star_plasma.tres")
const BLACK_HOLE_SHADER := preload("res://map/star/black_hole_distortion.tres")

static var gravity := 1.0
static var star_stability := 1.0
static var min_radius := 250.0
static var max_radius := 300.0
static var star_images: Array = [preload("res://map/star/star_images/blue.png")]
static var black_hole_images: Array = [preload("res://map/star/star_images/neutron.png")]

var radius := 0.0
var mass := 10.0
var kind := STAR

func generate_as_star():
	kind = STAR
	material = STAR_SHADER
	texture = star_images.pick_random()

func generate_as_black_hole():
	kind = BLACK_HOLE
	material = BLACK_HOLE_SHADER
	texture = black_hole_images.pick_random()

func _ready():
	var r_schwarzschild := star_stability * gravity * mass
	var is_black_hole := r_schwarzschild <= radius
	radius = randf_range(min_radius, max_radius)
	var diameter := 2.0 * radius
	generate_as_black_hole() if is_black_hole else generate_as_star()
	scale = Vector2(diameter, diameter) / texture.get_size() 
