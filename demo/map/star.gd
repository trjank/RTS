class_name Star extends Planet

const INSTABILITY := Scenery.GRAVITATIONAL_CONSTANT
const STAR_SHADER = null
const BLACK_HOLE_SHADER := preload("res://shaders/black_hole.tres")

func _ready() -> void:
	super._ready()
	capturable = false

func set_mass(new_mass: float) -> void:
	super.set_mass(new_mass)
	update_shader()

func set_radius(new_radius: float) -> void:
	super.set_radius(new_radius)
	update_shader()

func is_black_hole() -> bool:
	var schwarzschild_radius := INSTABILITY * mass
	return radius <= schwarzschild_radius

func update_shader() -> void:
	sprite.material_overlay = BLACK_HOLE_SHADER if is_black_hole() else STAR_SHADER
