#include <godot_cpp/core/math.hpp>
#include <godot_cpp/classes/input.hpp>
#include "mouse_commands.hpp"

#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_mouse.hpp>

using godot::MIN;
using godot::MAX;
using godot::Input;
using godot::InputEventMouse;

MouseCommands::MouseCommands() {
	waypoints.resize(MAX_LINE_WAYPOINTS);
   commands.resize(MAX_UNITS_SELECTED);
	units.resize(MAX_UNITS_SELECTED);
}
void MouseCommands::set_formation(Formation new_formation) {
   formation = new_formation;
}
void MouseCommands::order_units_to_move() {
   // do sorting here (make this later)
	for (int n = 0; n < units.size(); ++n)
      units[n]->queue_move(commands[n]);
}
Vector2 MouseCommands::get_point(float parametric_d) {
	int start_index       = MIN(int(parametric_d), waypoints.size() - 2);
	float subsegment_d    = MIN(parametric_d - start_index, 1);
	Vector2 segment_start = waypoints[start_index];
	Vector2 segment_end   = waypoints[start_index + 1];
	return segment_start.lerp(segment_end, subsegment_d);
}
void MouseCommands::begin_path_at(Vector2 start_pos) {
   waypoints.fill(start_pos);
	path_length = 0;
}
void MouseCommands::move_path_end_to(Vector2 new_pos) {
   constexpr float TOO_SMALL = 0.1;
   int end_index = waypoints.size() - 1;
	float stretch = waypoints[end_index].distance_to(new_pos);
   /*--------------------------------------------------------*/
	path_length += stretch;
	waypoints.set(end_index, new_pos);
   /*-----------------------------------*/
	if (path_length <= TOO_SMALL) return;
   /*-----------------------------------*/
   float step = 1.0 + stretch / path_length;
	for (int n = 1; n < end_index; ++n)
      waypoints.set(n, get_point(step * n));
}
void MouseCommands::snap_targets_to_line() {
	constexpr float SMALL_NUM = 0.001;
	float denom = float(units.size() - 1) + SMALL_NUM;
	float step = float(waypoints.size() - 1) / denom;
	for (int n = 0; n < units.size(); ++n)
		commands[n]->move_to(get_point(step * n));
}
void MouseCommands::_unhandled_input(const Ref<InputEvent>& event) {
	if (units.is_empty()) return;
   Input* input = Input::get_singleton();
   Ref<InputEventMouse> mouse_event = event;
	if (input->is_action_just_pressed("move"))
      begin_path_at(get_global_mouse_position());
	if (input->is_action_just_released("move"))
      order_units_to_move();
	if (input->is_action_pressed("move") and mouse_event.is_valid()) {
		move_path_end_to(get_global_mouse_position());
		snap_targets_to_line();
   }
}