class_name ResourceCounter extends GridContainer

@export var alloy_label: Label
@export var crystals_label: Label
@export var military_science_label: Label
@export var time_label: Label

var resources := StrategicResources.NONE
var time_sec := 0

func _ready() -> void:
	update()

func set_resources(new_resources: StrategicResources) -> void:
	resources = new_resources if new_resources != null else resources
	update()

func update_time() -> void:
	time_label.text = "%dm %02ds" % [int(time_sec / 60.0), time_sec % 60]

func update_resources() -> void:
	alloy_label.text = StrategicResources.to_str(resources.alloy)
	crystals_label.text = StrategicResources.to_str(resources.crystals)
	military_science_label.text = StrategicResources.to_str(resources.military_science)

func update() -> void:
	if not is_node_ready():
		return
	update_resources()
	update_time()
