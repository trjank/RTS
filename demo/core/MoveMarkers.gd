extends Node2D

const LINE_FORMATION     := 2
const V_FORMATION        := 3
const SMOOTH_FORMATION   := 10
const PRECISE_FORMATION  := 30
const MIN_LINE_WAYPOINTS := 2
const MAX_LINE_WAYPOINTS := 30
const MAX_N_SELECTED     := 10

var n_line_waypoints : int = V_FORMATION : set = set_mode
var line_waypoints   : Array[Vector2]
var line_length      : float = 0
var targets          : Array[LockIndicator] = []
var units            : Array = []

func set_mode(n_waypoints: int):
	n_line_waypoints = clampi(n_waypoints, MIN_LINE_WAYPOINTS, MAX_LINE_WAYPOINTS)

func _ready():
	line_waypoints.resize(MAX_LINE_WAYPOINTS)
	targets.resize(MAX_N_SELECTED)

func begin_line(start_pos: Vector2):
	line_length = 0
	line_waypoints.fill(start_pos)

func create_targets():
	for n in range(units.size()):
		var new_target := LockIndicator.new()
		targets[n] = new_target
		add_child(new_target)
	snap_targets_to_line()

func push_targets():
	for n in range(units.size()):
		units[n].move_cmds.push(targets[n])

# Linearly interpolates between the line segments
# Line start is when parametric_d = 0
# Line end is when parametric_d = n_line_waypoints - 1
func get_point_on_line(parametric_d: float) -> Vector2:
	var start         := mini(int(parametric_d), n_line_waypoints - 2)
	var subsegment_d  := minf(parametric_d - start, 1)
	var segment_start := line_waypoints[start]
	var segment_end   := line_waypoints[start + 1]
	return lerp(segment_start, segment_end, subsegment_d)

# Stretches the line out so it ends at new_pos
func change_line_end(new_pos: Vector2):
	var change := line_waypoints[n_line_waypoints - 1].distance_to(new_pos)
	var step   := 1.0 + change / line_length
	line_length += change
	line_waypoints[n_line_waypoints - 1] = new_pos
	# Initially, the targets are all clustered in one spot
	# This can cause random and unwanted positioning
	# In these cases, we only update the last waypoint
	if is_nan(change) or is_inf(change): return
	for n in range(1, n_line_waypoints - 1):
		var new_parametric_d := step * n
		line_waypoints[n] = get_point_on_line(new_parametric_d)

func snap_targets_to_line():
	var n_targets := units.size()
	var SMALL_NUM := 0.001
	var denom     := float(n_targets - 1) + SMALL_NUM
	var step      := float(n_line_waypoints - 1) / denom
	for n in range(n_targets):
		var parametric_d := step * n
		targets[n].position = get_point_on_line(parametric_d)

func _unhandled_input(event):
	if units.is_empty(): return
	if Input.is_action_just_pressed("move"):
		begin_line(get_global_mouse_position())
		create_targets()
	if Input.is_action_just_released("move"):
		push_targets()
	if Input.is_action_pressed("move") and event is InputEventMouseMotion:
		change_line_end(get_global_mouse_position())
		snap_targets_to_line()
