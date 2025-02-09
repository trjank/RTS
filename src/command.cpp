#include "command.hpp"

Command::Command() {
   icon = memnew(Sprite2D);
}
Command::~Command() {
   icon->queue_free();
}
void Command::invalidate() {
   valid = false;
}
bool Command::is_valid() {
   return valid and (prey.is_null() or prey->state != Unit::DEAD);
}
Vector2 Command::get_position() {
   return icon->get_global_position();
}
bool Command::is_controlled_by(Unit* caller) {
   return predator == caller;
}
void Command::move_to(Vector2 new_position) {
   icon->set_global_position(new_position);
}
void Command::ram() {
   move_to(prey->position);
}
void Command::kite(float min_distance, float max_distance) {
   bool too_close = predator->distance_to_target < min_distance;
   bool too_far   = predator->distance_to_target > max_distance;
   predator->can_move = too_close or too_far;
   if (too_close) flee(max_distance);
   else if (too_far) ram();
}
void Command::flee(float safe_distance) {
   Vector2 pred_pos = predator->get_global_position();
   Vector2 radial   = pred_pos - prey->position;
   Vector2 safe_pos = pred_pos - safe_distance * radial.normalized();
   move_to(safe_pos);
}
void Command::track() {
   Vector2 pred_pos    = predator->get_global_position();
   Vector2 radial      = pred_pos - prey->position;
   float v_r           = prey->velocity.dot(radial);
   float pred_speed_sq = predator->velocity.length_squared();
   float prey_speed_sq = prey->velocity.length_squared();
   float d_speed_sq    = pred_speed_sq - prey_speed_sq;
   float discriminant  = v_r * v_r + d_speed_sq * radial.length_squared();

   if (discriminant < 0) return ram(); // Target is unreachable

   float time_intersect = (v_r + sqrt(discriminant)) / d_speed_sq;
   Vector2 intersection = prey->position + time_intersect * prey->velocity;
   move_to(intersection);
}