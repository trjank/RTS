extends Node

const BLACK_HOLE_PRESET := {
	"display_name": "LEVEL_ONE",
	"min_mass": 100_000.0,
	"max_mass": 100_000.0,
	"min_radius": 1_000.0,
	"max_radius": 1_000.0,
	"textures": [preload("res://images_stars/neutron.png") ]
}
const PLANET_LEVEL_1 := {
	"display_name": "PLANET_1",
	"min_mass": 100_000.0,
	"max_mass": 100_000.0,
	"min_radius": 500.0,
	"max_radius": 500.0,
	"min_orbit_radius": 2_000.0,
	"max_orbit_radius": 2_000.0,
	"min_orbit_offset": 0.0,
	"max_orbit_offset": 0.0,
	"textures": [preload("res://images_planets_jovian/red.png"), preload("res://images_planets_jovian/orange.png")]
}

const PLANET_LEVEL_2 := {
	"display_name": "PLANET_2",
	"min_mass": 100_000.0,
	"max_mass": 100_000.0,
	"min_radius": 200.0,
	"max_radius": 00.0,
	"min_orbit_radius": 2_000.0,
	"max_orbit_radius": 2_000.0,
	"min_orbit_offset": 0.0,
	"max_orbit_offset": 0.0,
	"textures": [preload("res://images_planets_jovian/blue.png"), preload("res://images_planets_jovian/purple.png")]
}

func _on_main_menu_pressed():
	globals.main.state = Main.State.MAIN_MENU
	pass # Replace with function body.

func _on_level_1_pressed():

	var map = Map.new("Star")
	map.preset = BLACK_HOLE_PRESET
	var planet1 := Map.new("Planet")
	planet1.preset = PLANET_LEVEL_1.duplicate()
	var planet2 := Map.new("Planet")
	planet2.preset = PLANET_LEVEL_1.duplicate()
	planet2.preset.min_orbit_offset = PI
	planet2.preset.max_orbit_offset = PI
	var submaps :Array[Map]= [planet1, planet2]
	map.submaps = submaps
	globals.main.nodes[Main.State.BATTLE].set_map(map)
	globals.main.nodes[Main.State.BATTLE].generate_map()
	globals.main.state = Main.State.BATTLE
	pass # Replace with function body.

func _on_level_2_pressed():
	var map = Map.new("Star")
	map.preset = BLACK_HOLE_PRESET
	var planet1 := Map.new("Planet")
	planet1.preset = PLANET_LEVEL_2.duplicate()
	var planet2 := Map.new("Planet")
	planet2.preset = PLANET_LEVEL_2.duplicate()
	planet2.preset.min_orbit_offset = PI
	planet2.preset.max_orbit_offset = PI
	var submaps :Array[Map]= [planet1, planet2]
	map.submaps = submaps
	globals.main.nodes[Main.State.BATTLE].set_map(map)
	globals.main.nodes[Main.State.BATTLE].generate_map()
	globals.main.state = Main.State.BATTLE
	pass # Replace with function body.
