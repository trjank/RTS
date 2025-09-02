
extends Panel

func _process(delta):
	if material:
		var mouse_pos = get_global_mouse_position()
		material.set_shader_parameter("mouse_pos", mouse_pos)
