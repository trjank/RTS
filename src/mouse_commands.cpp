#include <godot_cpp/core/math.hpp>
#include "mouse_commands.hpp"

#include <godot_cpp/classes/area2d.hpp>

#define max_i godot::MAX<int, int>
#define min_i godot::MIN<int, int>
#define min_f godot::MIN<float, float>

MouseCommands::MouseCommands() {
   target.instantiate();
}
void MouseCommands::update_target() {
   target->move_to(get_global_mouse_position());
}
void MouseCommands::set_formation(Formation new_formation) {
   formation = new_formation;
}
void MouseCommands::update_units(TypedArray<Node2D> unit_array) {
   // units.resize(max_i(unit_array.size(), MAX_UNITS_SELECTED));
   // for (int n = 0; n < units.size(); ++n)
   //    units.set(n, unit_array[n]->radar_signature);
}
void MouseCommands::order_units_to_move() {
   // do sorting here (make this later)
	for (int n = 0; n < units.size(); ++n)
      units[n]->queue_move(commands[n]);
}
Vector2 MouseCommands::get_point(float parametric_dist) {
	int start_index       = min_i(parametric_dist, waypoints.size() - 2);
	float subsegment_dist = min_f(parametric_dist - start_index, 1.0);
	Vector2 segment_start = waypoints[start_index];
	Vector2 segment_end   = waypoints[start_index + 1];
	return segment_start.lerp(segment_end, subsegment_dist);
}
void MouseCommands::begin_path() {
   Vector2 start_pos = get_global_mouse_position();
   waypoints.resize(static_cast<int>(formation));
   waypoints.fill(start_pos);
   commands = Vector<Ref<Unit::Command>>();
   commands.resize(units.size());
   for (int n = 0; n < commands.size(); ++n)
      commands.set(n, new_command_at(start_pos));
}
Ref<Unit::Command> MouseCommands::new_command_at(Vector2 pos) {
   Ref<Unit::Command> blank_command;
   blank_command.instantiate();
   add_child(blank_command->icon);
   blank_command->move_to(pos);
   return blank_command;
}
void MouseCommands::update_path() {
   constexpr float PATH_TOO_SMALL = 0.1;
   Vector2 new_end = get_global_mouse_position();
   int end_index   = waypoints.size() - 1;
	float stretch   = waypoints[end_index].distance_to(new_end);
	waypoints.set(end_index, new_end);
   //-----------------------------------------------------
	if ((path_length += stretch) <= PATH_TOO_SMALL) return;
   //-----------------------------------------------------
   float step_dist = 1.0 + stretch / path_length;
	for (int n = 1; n < end_index; ++n)
      waypoints.set(n, get_point(step_dist * n));
   update_commands();
}
void MouseCommands::update_commands() {
	constexpr float PREVENT_DIV_ZERO = 0.001;
   float end_index = units.size() - 1;
   float end_dist  = waypoints.size() - 1;
   float step_dist = end_dist / (end_index + PREVENT_DIV_ZERO);
	for (int n = 0; n < commands.size(); ++n)
		commands[n]->move_to(get_point(step_dist * n));
}