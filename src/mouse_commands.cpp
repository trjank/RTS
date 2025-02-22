#include <godot_cpp/core/math.hpp>
#include "mouse_commands.hpp"

#define INVALID_N_WAYPOINTS_MSG "(MouseCommands) Too few number of waypoints to construct path"
#define MISSING_UNITS_MSG "(MouseCommands) Encountered missing units and/or too many commands"
#define INVALID_SIZE_MSG "(MouseCommands) Cursor image size must be 32x32 pixels"

using godot::MIN;

template<typename T /* UNIT OR COMMAND REF ONLY */>
Vector2 MouseCommands::MoveOrder<T>::get_center(Vector<T> objects) {
   Vector2 center = { 0, 0 };
   for (T& object: objects) {
      center += object->get_position();
   }
   center /= objects.size();
   return center;
}
template<typename T /* UNIT OR COMMAND REF ONLY */>
bool MouseCommands::MoveOrder<T>::operator()(const T& A, const T& B) const {
   /*-------------------------------------------------------*
    | Align the units and commands perpendicularly to the   |
    | direction of travel. E.g. If the units are commanded  |
    | to move horizontally, the units and commands will be  |
    | sorted vertically; units will be sent to a position   |
    | with a similar y value.                               |
    *-------------------------------------------------------*/
   float A_perp = (A->get_position() - center).cross(axis);
   float B_perp = (B->get_position() - center).cross(axis);
   return A_perp < B_perp;
}

MouseCommands::MouseCommands(): CURSOR_SIZE{32, 32}, CURSOR_CENTER{16, 16} {
   target.instantiate();
}
MouseCommands::Action MouseCommands::get_action() {
   return action;
}
MouseCommands::Formation MouseCommands::get_formation() {
   return formation;
}
void MouseCommands::set_command_icon(Ref<Texture2D> new_image) {
   move_icon_image = new_image;
}
void MouseCommands::update_target() {
   target->move_to(get_global_mouse_position());
}
void MouseCommands::clear_units() {
   units.clear();
}
void MouseCommands::select_unit(Unit* unit) {
   if (unit != nullptr and units.size() < MAX_UNITS_SELECTED)
      units.append(unit->radar_signature);
}
void MouseCommands::order_units_to_move() {
   ERR_FAIL_COND_MSG(commands.size() > units.size(), MISSING_UNITS_MSG);
   Vector2 units_center    = UnitMoveOrder::get_center(units);
   Vector2 commands_center = CommandMoveOrder::get_center(commands);
   Vector2 sort_axis       = commands_center - units_center;
   /*---------------------------------------------------------------*/
   units.sort_custom<UnitMoveOrder>(sort_axis, units_center);
   commands.sort_custom<CommandMoveOrder>(sort_axis, commands_center);
   /*---------------------------------------------------------------*/
   for (int n = 0; n < commands.size(); ++n) {
      units[n]->try_queue_move(commands[n]);
   }
   commands.clear();
}
Vector2 MouseCommands::get_point(float parametric_dist) {
   /*-------------------------------------------------------*
    | The path traced by the mouse cursor is broken up into |
    | discrete line segments, where each point comprising   |
    | the line segments is stored in the waypoints vector.  |
    | Here, we linearly interpolate between the waypoints   |
    | to return any arbitrary point along the path.         |
    |                                                       |
    | NOTE: parametric_dist = 0 marks the start of the path |
    | and parametric_dist = waypoints.size() - 1 marks the  |
    | end of the path.                                      |
    *-------------------------------------------------------*/
   int start_index       = MIN(parametric_dist, waypoints.size() - 2);
   float subsegment_dist = MIN(parametric_dist - start_index, 1.0);
   Vector2 segment_start = waypoints[start_index];
   Vector2 segment_end   = waypoints[start_index + 1];
   return segment_start.lerp(segment_end, subsegment_dist);
}
Ref<Unit::Command> MouseCommands::new_command(Vector2 pos) {
   Ref<Unit::Command> blank_command;
   blank_command.instantiate();
   add_child(blank_command->icon);
   blank_command->move_to(pos);
   blank_command->icon->set_texture(move_icon_image);
   return blank_command;
}
void MouseCommands::begin_path() {
   /*-------------------------------------------------------*
    | Condense the mouse cursor path to a single point (the |
    | position of the mouse).                               |
    |                                                       |
    | NOTE: Any units selected after the path has started   |
    | will not be given commands. Do NOT add or remove      |
    | units after the path has started, as this may cause   |
    | errors.                                               |
    *-------------------------------------------------------*/
   int n_waypoints = static_cast<int>(formation);
   ERR_FAIL_COND_MSG(n_waypoints <= 1, INVALID_N_WAYPOINTS_MSG);
   Vector2 start_pos = get_global_mouse_position();
   path_length = 0;
   waypoints.resize(n_waypoints);
   waypoints.fill(start_pos);
   commands.resize(units.size());
   for (int n = 0; n < commands.size(); ++n) {
      commands.set(n, new_command(start_pos));
   }
}
void MouseCommands::update_path() {
   /*-------------------------------------------------------*
    | Set the path's end to the mouse cursor position.      |
    | Each waypoint is then marched a small parametric      |
    | distance along the path to keep the spacing between   |
    | waypoints consistent.                                 |
    *-------------------------------------------------------*/
   constexpr float PATH_TOO_SMALL = 0.1;
   Vector2 new_end = get_global_mouse_position();
   int end_index   = waypoints.size() - 1;
   float stretch   = waypoints[end_index].distance_to(new_end);
   waypoints.set(end_index, new_end);
   /*---------------------------------------------------*/
   if ((path_length += stretch) <= PATH_TOO_SMALL) return;
   /*---------------------------------------------------*/
   float step_dist = 1.0 + stretch / path_length;
   for (int n = 1; n < end_index; ++n) {
      waypoints.set(n, get_point(step_dist * n));
   }
   update_commands();
}
void MouseCommands::update_commands() {
   /*-------------------------------------------------------*
    | Each command's position is set to equally spaced      |
    | intervals along the path, which often lie in between  |
    | line segments/waypoints.                              |
    |                                                       |
    | NOTE: There can be more or fewer commands relative to |
    | the number of path waypoints; the path waypoints only |
    | exist to define the shape of the path's line          |
    | segments, NOT to be the positions units move to.      |
    *-------------------------------------------------------*/
   constexpr float PREVENT_DIV_ZERO = 0.001;
   float end_index = units.size() - 1;
   float end_dist  = waypoints.size() - 1;
   float step_dist = end_dist / (end_index + PREVENT_DIV_ZERO);
   for (int n = 0; n < commands.size(); ++n) {
      commands[n]->move_to(get_point(step_dist * n));
   }
}
void MouseCommands::set_action_with_cursor(Action new_action, Input& input) {
   action = new_action;
   Ref<Texture2D> image = cursor_bindings[action];
   input.set_custom_mouse_cursor(image, Input::CURSOR_ARROW, CURSOR_CENTER);
}
void MouseCommands::bind_cursor_to_action(Ref<Texture2D> image, Action action) {
   ERR_FAIL_COND_MSG(image.is_valid() and image->get_size() != CURSOR_SIZE, INVALID_SIZE_MSG);
   cursor_bindings[action] = image;
}
void MouseCommands::reset_selection() {
   selection_start = get_global_mouse_position();
   call("_reset_selection_box", selection_start);
}
void MouseCommands::update_selection() {
   selection_end = get_global_mouse_position();
   call("_update_selection_box", selection_start, selection_end);
}
void MouseCommands::choose_formation(Input& input) {
   if (input.is_action_just_pressed("line formation"))
      formation = LINE;
   else if (input.is_action_just_pressed("v formation"))
      formation = V;
   else if (input.is_action_just_pressed("smooth formation"))
      formation = SMOOTH;
   else if (input.is_action_just_pressed("precise formation"))
      formation = PRECISE;
}
void MouseCommands::choose_action(Input& input) {
   if (input.is_action_just_pressed("left_click")) {
      set_action_with_cursor(SELECT, input);
      reset_selection();
   } else if (input.is_action_just_pressed("move")) {
      set_action_with_cursor(MOVE, input);
      begin_path();
   } else if (input.is_action_just_released("target"))
      set_action_with_cursor(TARGET, input);
}
void MouseCommands::maybe_end_targeting(Input& input) {
   if (not input.is_action_just_released("target")) return
   // order_units_to_move but modified
   set_action_with_cursor(NONE, input);
}
void MouseCommands::maybe_end_selection(Input& input) {
   if (not input.is_action_just_released("left_click")) return;
   call("_finish_selection");
   reset_selection();
   set_action_with_cursor(NONE, input);
}
void MouseCommands::maybe_end_move(Input& input) {
   if (not input.is_action_just_released("move")) return;
   order_units_to_move();
   set_action_with_cursor(NONE, input);
}
void MouseCommands::_process(double _dt) {
   /*-------------------------------------------------------*
    | Updates occur every frame instead of on keypress      |
    | because camera movement, which is not always picked   |
    | up by _input or _unhandled_input, changes the mouse's |
    | world position.                                       |
    *-------------------------------------------------------*/
   switch (action) {
      case MOVE: update_path(); break;
      case TARGET: update_target(); break;
      case SELECT: update_selection(); break;
      default: break;
   }
}
void MouseCommands::_unhandled_input(const Ref<InputEvent>& event) {
   if (event->is_class("InputEventMouseMotion")) return;
   Input& input = *Input::get_singleton();
   choose_formation(input);
   switch (action) {
      case NONE: choose_action(input); break;
      case MOVE: maybe_end_move(input); break;
      case TARGET: maybe_end_targeting(input); break;
      case SELECT: maybe_end_selection(input); break;
      default: break;
   }
}