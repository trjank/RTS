extends RigidBody2D

const DEFAULT_ZOOM := Vector2(1.0, 1.0)

@export var speed_xy := 10000.0
@export var speed_z := 1.0
@export var min_z := 0.2
@export var max_z := 10.0
@export var auto_switch := true

@onready var camera_node := $Camera2D

var z := 2.0

func _on_visibility_changed()->void:
	if auto_switch and visible: camera_node.make_current()

func _ready()->void:
	visibility_changed.connect(_on_visibility_changed)

func _physics_process(dt: float)->void:
	var input_xy := Input.get_vector("left", "right", "up", "down")
	var input_z  := Input.get_axis("in", "out")
	apply_force(input_xy * speed_xy)
	z = clamp(z + input_z * speed_z * dt, min_z, max_z)
	camera_node.zoom = DEFAULT_ZOOM / z
