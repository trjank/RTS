extends Node

@onready var move_markers := $/root/Main/MoveMarkers

var gravity := 1.0

var jovian_config := {
	"min_mass": 50.0,
	"max_mass": 100.0,
	"min_radius": 100.0,
	"max_radius": 300.0,
	"orbit_spacing": 500.0,
	"images": [
		"res://map/jovian_planet/blue.png",
		"res://map/jovian_planet/gray.png",
		"res://map/jovian_planet/orange.png",
		"res://map/jovian_planet/purple.png",
		"res://map/jovian_planet/red.png"
	],
	"names": [
		"Ouranos",
		"Zephyros",
		"Nyxion",
		"Typhon",
		"Hyperion",
		"Erebus",
		"Aeolus",
		"Aurion",
		"Nebulon",
		"Tempestis",
		"Cyclonea",
		"Borealis",
		"Stratos",
		"Vortexus",
		"Zephyra",
		"Stormarch",
		"Horizonis"
	]
}

var terrestrial_config := {
	"min_mass": 50.0,
	"max_mass": 100.0,
	"min_radius": 50.0,
	"max_radius": 100.0,
	"orbit_spacing": 200.0,
	"images": [
		"res://map/jovian_planet/blue.png"
	],
	"names": [
		"Terran"
	]
}
