extends Unit

var HP 				 : float = 10
var max_HP           : float = 100
var shield           : float = 0
var max_shield       : float = 100
var shield_per_sec   : float = 0
var energy           : float = 0
var max_energy       : float = 100
var energy_per_sec   : float = 10
var shield_threshold : float = 1
var n_locks          : int   = 0



var apply_thrust := false

var arcing := 0.1
var top_speed : = thrust / (mass * friction)
var move_cmds := MovementQueue.new()

@export var hp_bar: ProgressBar
@export var shield_bar: ProgressBar
@export var energy_bar: ProgressBar

var bounding_box: Rect2: get = get_bounding_box
var selected := false
func get_bounding_box() -> Rect2:
	
	return global_transform * $Image.get_rect()

func on_select():
	selected = true
	globals.move_markers.units.append(self)

func on_deselect():
	selected = false
	globals.move_markers.units.erase(self)

func kill():
	queue_free()

func lock_on():
	n_locks += 1
	if n_locks == 1:
		$LockIndicator.visible = true

func release_lock():
	n_locks -= 1
	if n_locks == 0:
		$LockIndicator.visible = false

func hit(damage: float, shield_pen: float = 0):
	var shield_overkill
	shield -= damage * shield_pen
	shield_overkill = -min(shield, 0)
	shield = max(shield, 0)
	HP -= damage * (1 - shield_pen) + shield_overkill
	if HP < 0: kill()

func move_to_target():
	if move_cmds.is_empty(): return

	
	var tgt := move_cmds.peek()
	if tgt == null: return
	
	# var facing       := Vector2.UP.rotated(rotation)
	# var cur_pos      := get_position()
	# var dest         := target.get_position()
	# var delta_pos    := dest - cur_pos
	# var dest_dist    := delta_pos.length()
	# var delta_rot    := facing.angle_to(delta_pos)
	# var time_to_turn := absf(delta_rot) / turnrate
	# var time_to_move := dest_dist / top_speed
	# var stop_dist    := velocity.dot(delta_pos.normalized()) / friction

	# angular_velocity = turnrate * sign(delta_rot) 
	# if dest_dist <= stop_dist:
	# 	# We are in reach of the target
	# 	angular_velocity = 0
	# 	move_cmds.pop().queue_free()
	# 	apply_thrust = false
	# else:
	# 	apply_thrust = time_to_turn <= time_to_move * arcing

# func _physics_process(delta):
# 	#U_physics_process(delta)
# 	return
	# apply_central_force(-friction * linear_velocity)
	# if apply_thrust:
	# 	var facing := Vector2.UP.rotated(rotation)
	# 	apply_central_force(thrust * facing)
	
	# move_to_target()
	# energy += energy_per_sec * delta
	# energy = min(energy, max_energy)
	#if energy_does_not_allow_it: return
	#shield += shield_per_sec * delta
	#shield = min(shield, max_shield)

func _process(_delta):
	move_to_target()
	#_physics_process(_delta)
	#set_physics_process(_physics_process(_delta))
	#hp_bar.value = HP
	#shield_bar.value = shield
	#energy_bar.value = energy
	queue_redraw()

static var LINE_COLOR := Color(1, 1, 1, .2)
static var LINE_THICKNESS := 2

func _draw():
	draw_set_transform_matrix(global_transform.affine_inverse())
	var start := global_position
	var end: Vector2

	if selected:
		draw_arc(position, 100,0,2*PI,10 ,Color.GREEN)
	#BUG: if you spam stop and move, sometimes it can crack
	# i think its because you might be able to do a stop command while this draw function is happening 
	if not move_cmds.is_empty() and move_cmds.peek()==null:
		move_cmds.__queue.pop_front()
		return

	for target in move_cmds.__queue:
		end = target.global_position
		draw_line(start, end, LINE_COLOR, LINE_THICKNESS)
		start = end
		#add_child(target)

func _unhandled_input(_event):
	if not (selected and Input.is_action_just_released("stop")): return
	apply_thrust=false
	angular_velocity=0
	while not move_cmds.is_empty():
		move_cmds.pop().queue_free()
	
