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
const PLANET_PRESET := {
	"display_name": "PLANET_PLANET_PLANET_PLANET_PLANET",
	"min_mass": 100_000.0,
	"max_mass": 100_000.0,
	"min_radius": 500.0,
	"max_radius": 500.0,
	"min_orbit_radius": 2_000.0,
	"max_orbit_radius": 2_000.0,
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
	map.submaps = [planet1, planet2]
	start()
