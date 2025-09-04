extends Battle

@export var countdown_timer: Timer
@export var round_timer: Timer
@onready var state_manager = $"../StateManager"
@onready var menubutton = %MenuButton 
@onready var designbutton = %DesignButton
#@onready var blur = %blur
var client: Player
var part_manager := JSONPartManager.new()

func create_warp_trail(from: Vector2, to: Vector2)->void:
	var trail := preload("res://battle/WarpPath.tscn").instantiate()
	add_child(trail)
	trail.set_point_position(0, from)
	trail.set_point_position(1, to)

func _on_spawned_ship(ship: Ship)->void:
	# Here is where you assemble the UI for the ship
	ship.warped.connect(create_warp_trail)
	ship.set_path_width(50)
	ship.set_path_texture(preload("res://icons/unit_path.png"))

func connect_timers()->void:
	started.connect(round_timer.start)
	started_countdown.connect(countdown_timer.start)
	stopped.connect(round_timer.stop)
	stopped.connect(countdown_timer.stop)
	round_timer.timeout.connect(stop)
	countdown_timer.timeout.connect(start)

func _ready()->void:
	part_manager.load_json()
	connect_timers()
	# For testing
	make_map()
	#round_timer.wait_time = 360.0
	#countdown_timer.wait_time = 5.0
	client = connect_player("truejank", Color.ORANGE)
	start()

func _on_started()->void:
	return
	#var capital_ship_data := ship_manager.load_ship_csv(64, 64, "user://capital_ship.csv")
	#var capital_ship := spawn_ship(client, capital_ship_data, Vector2.ZERO)
	##print(capital_ship_data.get_center_of_mass())
	##print(capital_ship_data.get_ship_region())
	##print(capital_ship_data.count_parts())
	#capital_ship.position = Vector2(-2000, 0)
	#
	#for n in range(10):
		#var ship := spawn_ship(client, capital_ship_data, Vector2.ZERO)
		#ship.set_position(n * Vector2(500, 0))

func make_map()->void:
	Star.set_black_hole_shader(preload("res://shaders/black_hole.tres"))
	System.set_default_texture(preload("res://images_planets_terrestrial/unloaded_celestial.tres"))
	Orbit.set_time_scale(100)
	
	var sun := StarSystem.new()
	sun.set_radius_range(750, 1000)
	sun.set_mass_range(10000, 20000)
	sun.names = ["Star"]
	sun.textures = [preload("res://images_stars/blue.png")]
	
	var planets := System.new()
	planets.set_radius_range(500, 750)
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
	planets_layer.orbit_spacing = 3000
	planets_layer.start_distance = 5000
	
	var moons_layer := MapLayer.new()
	moons_layer.set_submap(moons)
	moons_layer.num_orbits = 1
	moons_layer.num_sectors = 2
	moons_layer.orbit_spacing = 500
	moons_layer.start_distance = 1000

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
	state_manager.set_state(state_manager.State.DESIGN)

func menu_button_pressed():
	state_manager.set_state(state_manager.State.MAIN_MENU)
