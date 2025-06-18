extends Battle

@export var clock: Timer
@export var clock_minutes_label: Label
@export var clock_seconds_label: Label
@export var overlay: CanvasLayer

const UI_REFRESHES_PER_SEC := 1.0

func hide_overlay()->void:
	overlay.hide()

func show_overlay()->void:
	overlay.show()

func _ready()->void:
	Orbit.set_time_scale(100)
	
	var sun := StarSystem.new()
	sun.set_radius_range(300, 500)
	sun.set_mass_range(100, 200)
	sun.load_textures_from_folder("res://images_stars")
	sun.names = ["test"]
	
	var planets := System.new()
	planets.set_radius_range(200, 300)
	planets.set_mass_range(100, 200)
	planets.load_textures_from_folder("res://images_planets_jovian")
	planets.names = ["<test planet>"]
	
	var moons := System.new()
	moons.set_radius_range(100, 200)
	moons.set_mass_range(50, 100)
	moons.load_textures_from_folder("res://images_planets_jovian")
	moons.names = ["RAHH"]

	var planets_layer := MapLayer.new()
	planets_layer.set_preset(planets)
	planets_layer.num_orbits = 10
	planets_layer.num_sectors = 3
	planets_layer.orbit_spacing = 1000
	planets_layer.start_distance = 2000
	
	var moons_layer := MapLayer.new()
	moons_layer.set_preset(moons)
	moons_layer.num_orbits = 1
	moons_layer.num_sectors = 2
	moons_layer.orbit_spacing = 300
	moons_layer.start_distance = 500

	sun.new_layer(planets_layer)
	planets.new_layer(moons_layer)
	set_map(sun)
	
	clock.timeout.connect(on_UI_refresh)
	start_countdown()
	on_UI_refresh()
	set_duration_sec(360)
	clock.start(UI_REFRESHES_PER_SEC)

func on_UI_refresh()->void:
	clock_minutes_label.text = "%d"   % get_minutes_left()
	clock_seconds_label.text = "%02d" % get_seconds_left()
