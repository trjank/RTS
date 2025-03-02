#include <godot_cpp/core/math.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include "unit.hpp"

#define WARP_VISUAL_PATH "res://battle/WarpPathVisual.tscn"
#define ABS godot::Math::abs

using godot::ResourceLoader;
using godot::PackedScene;
using godot::CLAMP;

Unit::Unit() {
   radar_signature.instantiate();
   radar_signature->unit = this;
   radar_signature->state = ALIVE;
   applying_thrust = false;
   can_move = true;
   set_linear_damp(0.0);
   set_angular_damp(0.0);
}
Unit::~Unit() {
   radar_signature->unit = nullptr;
   radar_signature->state = DEAD;
}
float Unit::get_HP() {
   return HP;
}
void Unit::kill() {
   queue_free();
}
void Unit::stop_moving() {
   commands.clear();
}
void Unit::stop_targeting() {
   target.unref();
}
void Unit::queue_move(Ref<Unit::Command> new_command, bool clear_queue) {
   if (clear_queue) commands.clear();
   else if (commands.size() >= MAX_N_COMMANDS) return;
   can_warp = false;
   commands.push_back(new_command);
}
void Unit::set_target(Ref<Unit::Command> new_target) {
   target = new_target;
}
Vector2 Unit::get_forward_direction() {
   return -get_transform().columns[1];
}
void Unit::cloak() {
   radar_signature->state = CLOAKED;
}
void Unit::decloak() {
   radar_signature->state = ALIVE;
}
void Unit::update_radar_signature() {
   if (radar_signature->state == CLOAKED) return;
   radar_signature->HP = HP;
   radar_signature->velocity = get_linear_velocity();
   radar_signature->position = get_global_position();
}
void Unit::hit(float damage) {
   if ((HP -= damage) <= 0) kill();
}
Ref<Unit::Command> Unit::get_current_command() {
   return commands.front()->get();
}
int Unit::get_num_commands() {
   return commands.size();
}
void Unit::move_to_target() {
   if (commands.is_empty()) return;
   /*------------------------------------------------------------------------*/
   Ref<Command> command = get_current_command();
   if ( !command->is_valid()) return commands.pop_front();
   /*------------------------------------------------------------------------*/
   Vector2 separation = command->get_position() - get_global_position();
   distance_to_target = separation.length();
   angle_to_target    = get_forward_direction().angle_to(separation);
   stop_distance      = get_linear_velocity().dot(separation.normalized());
   speed              = get_linear_velocity().length();
   float time_to_move = distance_to_target / speed;
   float time_to_turn = ABS(angle_to_target) / turnrate;
   applying_thrust    = can_move && time_to_turn <= path_arcing * time_to_move;
   can_warp           = get_num_commands() == 1 && distance_to_target <= warp;
   /*------------------------------------------------------------------------*/
   if (command->is_controlled_by(this)) order_attack(command);
   if (distance_to_target <= stop_distance) commands.pop_front();
}
void Unit::order_attack(Ref<Command> command) {
   // do stuff here
}
void Unit::try_to_warp(PhysicsDirectBodyState2D* state) {
   if ( !can_warp) return;
   /*-----------------------------------------*/
   // NOTE FOR LATER: if WARP_VISUAL_PATH is invalid, this code will segfault
   // FIX THIS SOMETIME IN THE NEAR FUTURE
   Ref<Command> command = get_current_command();
   Ref<PackedScene> warp_visual = ResourceLoader::get_singleton()->load(WARP_VISUAL_PATH);
   Node* warp_path = warp_visual->instantiate();
   get_parent()->add_child(warp_path);
   warp_path->call("set_start", get_global_position());
   warp_path->call("set_end", command->get_position());
   /*------------------------------------------------*/
   warp -= distance_to_target;
   set_global_position(command->get_position());
   rotate(angle_to_target);
   commands.pop_front();
   state->set_linear_velocity({ 0.0, 0.0 });
}
void Unit::_physics_process(double dt) {
   move_to_target();
   update_radar_signature();
}
void Unit::_integrate_forces(PhysicsDirectBodyState2D* state) {
   state->apply_central_force(-drag * get_linear_velocity());
   /*----------------------------------------------------------------------*/
   if (commands.is_empty()) return state->set_angular_velocity(0.0);
   /*----------------------------------------------------------------------*/
   float turn_direction = CLAMP(TURN_JERKINESS * angle_to_target, -1.0, 1.0);
   state->set_angular_velocity(turnrate * turn_direction);
   if (applying_thrust) state->apply_central_force(thrust * get_forward_direction());
   try_to_warp(state);
}
void Unit::_process(double _dt) {
   queue_redraw();
}
void Unit::_draw() {
   draw_arc({ 0.0, 0.0 }, warp, 0.0, Math_TAU, 100, warp_color, 1.0, true);
   if (commands.is_empty()) return;
   Ref<Command> command = get_current_command();
   Vector2 path_start = { 0.0, 0.0 };
   Vector2 path_end = to_local(command->get_position());
   draw_line(path_start, path_end, path_color, 1.0, true);
}



float Unit::RadarSignature::get_HP() {
   return HP;
}
Unit::State Unit::RadarSignature::get_state() {
   return state;
}
Vector2 Unit::RadarSignature::get_position() {
   return position;
}
Vector2 Unit::RadarSignature::get_velocity() {
   return velocity;
}
void Unit::RadarSignature::try_stop_moving() {
   if (state != DEAD) unit->stop_moving();
}
void Unit::RadarSignature::try_queue_move(Ref<Command> command, bool clear_queue) {
   if (state != DEAD) unit->queue_move(command, clear_queue);
}
void Unit::RadarSignature::try_set_target(Ref<Command> command) {
   if (state != DEAD) unit->set_target(command);
}



Unit::Command::Command() {
   icon = memnew(Sprite2D);
   icon->set_z_index(1);
   valid = true;
}
Unit::Command::~Command() {
   icon->queue_free();
}
Vector2 Unit::Command::get_position() {
   return icon->get_global_position();
}
void Unit::Command::invalidate() {
   valid = false;
}
bool Unit::Command::is_valid() {
   return valid && (prey.is_null() || prey->state != DEAD);
}
bool Unit::Command::is_controlled_by(Unit* caller) {
   return predator == caller;
}
void Unit::Command::move_to(Vector2 new_position) {
   icon->set_global_position(new_position);
}
void Unit::Command::ram() {
   move_to(prey->get_position());
}
void Unit::Command::track() {
   Vector2 pred_pos    = predator->get_global_position();
   Vector2 radial      = pred_pos - prey->position;
   float v_r           = prey->velocity.dot(radial);
   float pred_speed_sq = predator->get_linear_velocity().length_squared();
   float prey_speed_sq = prey->velocity.length_squared();
   float d_speed_sq    = pred_speed_sq - prey_speed_sq;
   float discriminant  = v_r * v_r + d_speed_sq * radial.length_squared();
   /*-------------------------------------------------------------------*/
   if (discriminant < 0) return ram(); // Target is unreachable
   /*-------------------------------------------------------------------*/
   float time_intersect = (v_r + sqrt(discriminant)) / d_speed_sq;
   Vector2 intersection = prey->position + time_intersect * prey->velocity;
   move_to(intersection);
}
void Unit::Command::flee(float safe_distance) {
   Vector2 pred_pos = predator->get_global_position();
   Vector2 radial   = pred_pos - prey->position;
   Vector2 safe_pos = pred_pos - safe_distance * radial.normalized();
   move_to(safe_pos);
}
void Unit::Command::kite(float min_distance, float max_distance) {
   bool too_close = predator->distance_to_target < min_distance;
   bool too_far   = predator->distance_to_target > max_distance;
   predator->can_move = too_close || too_far;
   if (too_close) flee(max_distance);
   else if (too_far) ram();
}
