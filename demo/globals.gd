extends Node



var partScale = 32
var parts := {
	"1x1LightBlock": {
		"size": Vector2(1,1),
		"offset": Vector2(0,0),
		"img": "res://part_images/armor_heavy_1x1.png"
	},
	"1x2LightBlock": {
		"size": Vector2(1,2),
		"offset": Vector2(0,.5),
		"img": "res://part_images/armor_heavy_triangular_1x2.png"
	},
	"2x2LightBlock": {
		"size": Vector2(2,2),
		"offset": Vector2(-.5,-.5),
		"img": "res://part_images/armor_heavy_2x2.png"
	},
	"3x3LightBlock": {
		"size": Vector2(3,3),
		"offset": Vector2(0,0),
		"img": "res://images/icon.svg"
	}
}


var gravity := 1.0

var defaultFleetName = "default"
var defaultFleetID = 0

# var jovian_config := {
# 	"min_mass": 50.0,
# 	"max_mass": 100.0,
# 	"min_radius": 100.0,
# 	"max_radius": 300.0,
# 	"orbit_spacing": 500.0,
# 	"images": [
# 		"res://map/jovian_planet/blue.png",
# 		"res://map/jovian_planet/gray.png",
# 		"res://map/jovian_planet/orange.png",
# 		"res://map/jovian_planet/purple.png",
# 		"res://map/jovian_planet/red.png"
# 	],
# 	"names": [
# 		"Ouranos",
# 		"Zephyros",
# 		"Nyxion",
# 		"Typhon",
# 		"Hyperion",
# 		"Erebus",
# 		"Aeolus",
# 		"Aurion",
# 		"Nebulon",
# 		"Tempestis",
# 		"Cyclonea",
# 		"Borealis",
# 		"Stratos",
# 		"Vortexus",
# 		"Zephyra",
# 		"Stormarch",
# 		"Horizonis"
# 	]
# }

# var terrestrial_config := {
# 	"min_mass": 50.0,
# 	"max_mass": 100.0,
# 	"min_radius": 50.0,
# 	"max_radius": 100.0,
# 	"orbit_spacing": 200.0,
# 	"images": [
# 		"res://map/jovian_planet/blue.png"
# 	],
# 	"names": [
# 		"Terran"
# 	]
# }
