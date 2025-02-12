#include <godot_cpp/core/math.hpp>
#include <godot_cpp/classes/input.hpp>
#include "mouse_commands.hpp"

#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_mouse.hpp>

#include <godot_cpp/variant/packed_vector2_array.hpp>

using godot::MIN;
using godot::MAX;
using godot::Input;
using godot::InputEventMouse;

void MouseCommands::order_units_to_move() {
   // do sorting here (make this later)
	for (int n = 0; n < units.size(); ++n)
      units[n]->queue_move(commands[n]);
}
Vector2 MouseCommands::get_point(float parametric_dist) {
	int start_index       = MIN(int(parametric_dist), waypoints.size() - 2);
	float subsegment_dist = MIN(parametric_dist - start_index, 1.0);
	Vector2 segment_start = waypoints[start_index];
	Vector2 segment_end   = waypoints[start_index + 1];
	return segment_start.lerp(segment_end, subsegment_dist);
}
void MouseCommands::begin_path_at(Vector2 start_pos) {
   waypoints.resize(static_cast<int>(formation));
   waypoints.fill(start_pos);
   commands = Vector<Ref<Unit::Command>>();
   commands.resize(units.size());
   /*-----------------------------------------*/
   for (int n = 0; n < commands.size(); ++n) {
      Ref<Unit::Command> blank_command;
      blank_command.instantiate();
      get_parent()->add_child(blank_command->icon);
      blank_command->move_to(start_pos);
      commands.set(n, blank_command);
   }
}
void MouseCommands::move_path_end_to(Vector2 new_pos) {
   constexpr float PATH_TOO_SMALL = 0.1;
   int end_index = waypoints.size() - 1;
	float stretch = waypoints[end_index].distance_to(new_pos);
	waypoints.set(end_index, new_pos);
   /*-----------------------------------------------------*/
	if ((path_length += stretch) <= PATH_TOO_SMALL) return;
   /*-----------------------------------------------------*/
   float step = 1.0 + stretch / path_length;
	for (int n = 1; n < end_index; ++n)
      waypoints.set(n, get_point(step * n));
}
void MouseCommands::update_commands() {
	constexpr float PREVENT_DIV_ZERO = 0.001;
   float end_index = units.size() - 1;
   float end_dist  = waypoints.size() - 1;
   float step      = end_dist / (end_index + PREVENT_DIV_ZERO);
	for (int n = 0; n < commands.size(); ++n)
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
		update_commands();
   }
}