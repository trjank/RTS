#include <godot_cpp/core/math.hpp>
#include "mouse_commands.hpp"

using namespace godot;

MouseCommands::MouseCommands() {
   target.instantiate();
}
MouseCommands::Action MouseCommands::get_action() {
   return action;
}
MouseCommands::Formation MouseCommands::get_formation() {
   return formation;
}
Ref<Unit::Command> MouseCommands::new_command(Vector2 pos) {
   Ref<Unit::Command> blank_command;
   blank_command.instantiate();
   add_child(blank_command->icon);
   blank_command->move_to(pos);
   blank_command->icon->set_texture(move_icon_image);
   return blank_command;
}
void MouseCommands::set_command_icon(Ref<Texture2D> new_image) {
   move_icon_image = new_image;
}
void MouseCommands::update_target() {
   target->move_to(get_global_mouse_position());
}
void MouseCommands::select_unit(Variant unit) {
   Unit* selected = Object::cast_to<Unit>(unit);
   bool is_a_unit = selected != nullptr;
   if (is_a_unit) units.append(selected->get_radar_signature());
}
void MouseCommands::select_units(TypedArray<Node2D> selection) {
   units.clear();
   commands.clear();
   for (int n = 0; n < selection.size(); ++n) {
      select_unit(selection[n]);
   }
}
void MouseCommands::order_unit_to_move(Ref<Unit::RadarSignature> unit,
                                       Ref<Unit::Command> command) {
   if (unit->get_state() == Unit::DEAD) return;
   Unit* alive_unit = unit->as_unit();
   alive_unit->queue_move(command, !queue_move);
}
void MouseCommands::order_units_to_move() {
   ERR_FAIL_COND(commands.size() > units.size());

   Vector2 comms_center = CommandMoveOrder::get_center(commands);
   Vector2 units_center = UnitMoveOrder::get_center(units);
   Vector2 sort_axis    = comms_center - units_center;
   commands.sort_custom<CommandMoveOrder>(sort_axis, comms_center);
   units.sort_custom<UnitMoveOrder>(sort_axis, units_center);
   
   for (int n = 0; n < commands.size(); ++n) {
      order_unit_to_move(units[n], commands[n]);
   }
   commands.clear();
}
void MouseCommands::stop_unit(Ref<Unit::RadarSignature> signature) {
   ERR_FAIL_COND(signature.is_null());
   
   if ( !signature->is_valid()) return;
   Unit* alive_unit = signature->as_unit();
   alive_unit->stop_moving();
}
void MouseCommands::stop_all_units() {
   for (Ref<Unit::RadarSignature> unit: units) {
      stop_unit(unit);
   }
}
Vector2 MouseCommands::get_point(float parametric_dist) {
   float path_end_dist   = waypoints.size() - 1;
   int seg_start_index   = Math::min(parametric_dist, path_end_dist - DIST_BETWEEN_WAYPOINTS);
   float subsegment_dist = Math::min(parametric_dist - seg_start_index, DIST_BETWEEN_WAYPOINTS);
   Vector2 segment_start = waypoints[seg_start_index];
   Vector2 segment_end   = waypoints[seg_start_index + 1];
   
   return segment_start.lerp(segment_end, subsegment_dist);
}
void MouseCommands::begin_path() {
   int num_waypoints = static_cast<int>(formation);
   
   ERR_FAIL_COND(num_waypoints <= 1);
   
   Vector2 path_start = get_global_mouse_position();
   path_length = 0.0;
   waypoints.resize(num_waypoints);
   waypoints.fill(path_start);
   commands.resize(units.size());
   for (int n = 0; n < commands.size(); ++n) {
      commands.set(n, new_command(path_start));
   }
}
void MouseCommands::update_path() {
   constexpr float UNSTABLE_PATH_LENGTH = 0.1;
   int end_index   = waypoints.size() - 1;
   Vector2 old_end = waypoints[end_index];
   Vector2 new_end = get_global_mouse_position();
   float stretch   = old_end.distance_to(new_end);
   waypoints.set(end_index, new_end);
   
   if ((path_length += stretch) <= UNSTABLE_PATH_LENGTH) return;
   
   float step_dist = DIST_BETWEEN_WAYPOINTS + stretch / path_length;
   for (int n = 1; n < end_index; ++n) {
      waypoints.set(n, get_point(step_dist * n));
   }
   update_commands();
}
void MouseCommands::update_commands() {
   constexpr float PREVENT_DIVIDE_ZERO = 0.001;
   float end_index = units.size() - 1;
   float end_dist  = waypoints.size() - 1;
   float step_dist = end_dist / (end_index + PREVENT_DIVIDE_ZERO);
   for (int n = 0; n < commands.size(); ++n) {
      commands[n]->move_to(get_point(step_dist * n));
   }
}
void MouseCommands::set_action_with_cursor(Action new_action) {
   ERR_FAIL_COND(new_action < 0 || NUM_OF_ACTIONS <= new_action);
   
   action = new_action;
   Input* input = Input::get_singleton();
   Ref<Texture2D> cursor = cursor_bindings[action];
   input->set_custom_mouse_cursor(cursor, Input::CURSOR_ARROW, CURSOR_CENTER);
}
void MouseCommands::bind_cursor_to_action(Ref<Texture2D> image, Action action) {
   ERR_FAIL_COND(action < 0 || action >= NUM_OF_ACTIONS);
   ERR_FAIL_COND(image.is_valid() && image->get_size() != CURSOR_SIZE);
   
   cursor_bindings[action] = image;
}
void MouseCommands::_process(double _dt) {
   if (action != NONE) update_path();
}
void MouseCommands::_unhandled_input(const Ref<InputEvent>& event) {
   if (event->is_class("InputEventMouseMotion")) return;
   
   if (event->is_action_pressed("line formation"))
      formation = LINE;
   else if (event->is_action_pressed("v formation"))
      formation = V;
   else if (event->is_action_pressed("smooth formation"))
      formation = SMOOTH;
   else if (event->is_action_pressed("precise formation"))
      formation = PRECISE;
   
   if (event->is_action_pressed("toggle queue move"))
      queue_move = !queue_move;
   if (event->is_action_released("stop"))
      stop_all_units();
   
   if (action == MOVE && event->is_action_released("move")) {
      order_units_to_move();
      set_action_with_cursor(NONE);
   } else if (action == NONE && event->is_action_pressed("move")) {
      set_action_with_cursor(MOVE);
      begin_path();
   } else if (action == TARGET && event->is_action_released("target")) {
      order_units_to_move();
      set_action_with_cursor(NONE);
   } else if (action == NONE && event->is_action_released("target")) {
      set_action_with_cursor(TARGET);
      begin_path();
   }
}

template<typename T>
Vector2 MouseCommands::MoveOrder<T>::get_center(Vector<T> objects) {
   Vector2 sum_pos = { 0.0, 0.0 };
   for (T object: objects) {
      sum_pos += object->get_position();
   }
   return sum_pos / objects.size();
}
template<typename T>
bool MouseCommands::MoveOrder<T>::operator()(const T& A, const T& B) const {
   Vector2 A_pos = A->get_position() - center;
   Vector2 B_pos = B->get_position() - center;
   return A_pos.cross(axis) < B_pos.cross(axis);
}