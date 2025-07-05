extends Battle

@export var countdown_timer: Timer
@export var round_timer: Timer
@export var overlay: CanvasLayer

func hide_overlay()->void:
	overlay.hide()

func show_overlay()->void:
	overlay.show()

func _ready()->void:
	started.connect(round_timer.start)
	started_countdown.connect(countdown_timer.start)
	stopped.connect(round_timer.stop)
	stopped.connect(countdown_timer.stop)
	round_timer.timeout.connect(stop)
	countdown_timer.timeout.connect(start)

	# For testing
	make_map()
	round_timer.wait_time = 360.0
	countdown_timer.wait_time = 5.0
	start_countdown()

func make_map()->void:
	Orbit.set_time_scale(100)
	
	var sun := StarSystem.new()
	sun.set_radius_range(300, 500)
	sun.set_mass_range(100, 200)
	#sun.load_textures_from_folder("res://images_stars")
	sun.names = ["Star"]
	sun.textures = [preload("res://images_stars/blue.png")]
	
	var planets := System.new()
	planets.set_radius_range(200, 300)
	planets.set_mass_range(100, 200)
	planets.alloy_density = 1
	planets.energy_density = 1
	#planets.load_textures_from_folder("res://images_planets_jovian")
	planets.names = ["Planet"]
	planets.textures = [preload("res://images_planets_jovian/blue.png")]
	
	var moons := System.new()
	moons.set_radius_range(100, 200)
	moons.set_mass_range(50, 100)
	#moons.load_textures_from_folder("res://images_planets_terrestrial")
	moons.names = ["Moon"]
	moons.textures = [preload("res://images_planets_terrestrial/unloaded_celestial.tres")]

	var planets_layer := MapLayer.new()
	planets_layer.set_submap(planets)
	planets_layer.num_orbits = 10
	planets_layer.num_sectors = 3
	planets_layer.orbit_spacing = 1000
	planets_layer.start_distance = 2000
	
	var moons_layer := MapLayer.new()
	moons_layer.set_submap(moons)
	moons_layer.num_orbits = 1
	moons_layer.num_sectors = 2
	moons_layer.orbit_spacing = 300
	moons_layer.start_distance = 500

	sun.new_layer(planets_layer)
	planets.new_layer(moons_layer)
	set_map(sun)
