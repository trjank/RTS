class_name MainMenu extends Battle

const STAR_PRESET := {
	"display_name": "STAR",
	"min_mass": 100.0,
	"max_mass": 100.0,
	"min_radius": 5.0,
	"max_radius": 5.0
}
const BLACK_HOLE_PRESET := {
	"display_name": "BLACK HOLE",
	"min_mass": 100_000.0,
	"max_mass": 100_000.0,
	"min_radius": 1_000.0,
	"max_radius": 1_000.0
}
const JOVIAN_PLANET_PRESET := {
	"display_name": "JOVIAN PLANET",
	"min_mass": 1_000.0,
	"max_mass": 1_000.0,
	"min_radius": 4.0,
	"max_radius": 4.0,
	"min_orbit_radius": 20.0,
	"max_orbit_radius": 20.0,
	"min_orbit_offset": 0.0,
	"max_orbit_offset": 0.0
}
const TERRESTRIAL_PLANET_PRESET := {
	"display_name": "TERRESTRIAL PLANET",
	"min_mass": 1_000.0,
	"max_mass": 1_000.0,
	"min_radius": 5.0,
	"max_radius": 5.0,
	"min_orbit_radius": 20.0,
	"max_orbit_radius": 20.0,
	"min_orbit_offset": 0.0,
	"max_orbit_offset": 0.0
}
const MOON_PRESET := {
	"display_name": "MOON",
	"min_mass": 1_000.0,
	"max_mass": 1_000.0,
	"min_radius": 3.0,
	"max_radius": 3.0,
	"min_orbit_radius": 20.0,
	"max_orbit_radius": 20.0,
	"min_orbit_offset": 0.0,
	"max_orbit_offset": 0.0
}

func _on_play_button_pressed() -> void:
	globals.main.state = Main.State.BATTLE

func _on_design_button_pressed() -> void:
	globals.main.state = Main.State.DESIGN

func _on_fleets_button_pressed() -> void:
	globals.main.state = Main.State.FLEET

func _on_settings_button_pressed() -> void:
	globals.main.state = Main.State.SETTINGS

func _ready() -> void:
	super._ready()
	map = Map.new("Star")
	map.preset = STAR_PRESET

	var planet1 := Map.new("JovianPlanet")
	planet1.preset = JOVIAN_PLANET_PRESET.duplicate()
	var planet2 := Map.new("JovianPlanet")
	planet2.preset = JOVIAN_PLANET_PRESET.duplicate()
	planet2.preset.min_orbit_offset = PI
	planet2.preset.max_orbit_offset = PI

	var planet3 := Map.new("TerrestrialPlanet")
	planet3.preset = TERRESTRIAL_PLANET_PRESET.duplicate()
	planet3.preset.min_orbit_offset = 0.5 * PI
	planet3.preset.max_orbit_offset = 0.5 * PI
	var planet4 := Map.new("TerrestrialPlanet")
	planet4.preset = TERRESTRIAL_PLANET_PRESET.duplicate()
	planet4.preset.min_orbit_offset = 1.5 * PI
	planet4.preset.max_orbit_offset = 1.5 * PI

	var moon1 := Map.new("Moon")
	moon1.preset = MOON_PRESET.duplicate()
	moon1.preset.min_orbit_offset = 0.25 * PI
	moon1.preset.max_orbit_offset = 0.25 * PI
	var moon2 := Map.new("Moon")
	moon2.preset = MOON_PRESET.duplicate()
	moon2.preset.min_orbit_offset = 1.25 * PI
	moon2.preset.max_orbit_offset = 1.25 * PI

	map.submaps = [planet1, planet2, planet3, planet4, moon1, moon2]
	start()
