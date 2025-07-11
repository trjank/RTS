extends Battle

@export var countdown_timer: Timer
@export var round_timer: Timer
@export var overlay: CanvasLayer
@onready var statemanager = $"../state_manager"
@onready var menubutton = %MenuButton 
@onready var designbutton = %DesignButton

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
	start()

func make_map()->void:
	System.set_default_texture(preload("res://images_planets_terrestrial/unloaded_celestial.tres"))
	Orbit.set_time_scale(100)
	
	var sun := StarSystem.new()
	sun.set_radius_range(300, 500)
	sun.set_mass_range(100, 200)
	sun.names = ["Star"]
	sun.textures = [preload("res://images_stars/blue.png")]
	
	var planets := System.new()
	planets.set_radius_range(200, 300)
	planets.set_mass_range(100, 200)
	planets.alloy_density = 1
	planets.energy_density = 1
	planets.names = ["Planet"]
	planets.textures = [preload("res://images_planets_jovian/blue.png")]
	
	var moons := System.new()
	moons.set_radius_range(100, 200)
	moons.set_mass_range(50, 100)
	moons.names = ["Moon"]

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
	
	#clock.timeout.connect(on_UI_refresh)
	start_countdown()
	#on_UI_refresh()
	#set_duration_sec(360)
	#clock.start(UI_REFRESHES_PER_SEC)
	designbutton.pressed.connect(design_button_pressed)
	menubutton.pressed.connect(menu_button_pressed)
#
#func on_UI_refresh()->void:
	#clock_minutes_label.text = "%d"   % get_minutes_left()
	#clock_seconds_label.text = "%02d" % get_seconds_left()

func design_button_pressed():
	statemanager.change_state(statemanager.DESIGN)

func menu_button_pressed():
	statemanager.change_state(statemanager.BACKGROUND)
	statemanager.change_ui_state(statemanager.MAIN_MENU)
	
