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
   return valid;
}
Vector2 Command::get_position() {
   return icon->get_global_position();
}
void Command::move_to(Vector2 new_position) {
   icon->set_global_position(new_position);
}
void Command::ram(Unit& prey) {
   move_to(prey.get_position());
}
void Command::kite(Unit& predator, Unit& prey, float distance) {

}
void Command::flee(Unit& predator, Unit& prey, float safe_distance) {
   Vector2 pred_pos = predator.get_global_position();
   Vector2 prey_pos = target_lock->position;
   Vector2 r        = pred_pos - prey_pos;
   Vector2 safe_pos = pred_pos - safe_distance * r.normalized();
   move_to(safe_pos);
}
void Command::track(Unit& predator, Unit& prey) {
   Vector2 pred_pos    = predator.get_global_position();
   Vector2 prey_pos    = target_lock->position;
   Vector2 r           = pred_pos - prey_pos;
   float v_r           = target_lock->velocity.dot(r);
   float pred_speed_sq = predator.velocity.length_squared();
   float prey_speed_sq = target_lock->velocity.length_squared();
   float d_speed_sq    = pred_speed_sq - prey_speed_sq;
   float discriminant  = v_r * v_r + d_speed_sq * r.length_squared();
   /*-------------------------------------------------------*/
   bool cant_reach_target = discriminant <= 0.0;
   if (cant_reach_target) return ram(prey);
   /*-------------------------------------------------------*/
   float t_intersect = (v_r + sqrt(discriminant)) / d_speed_sq;
   Vector2 intersection = prey_pos + target_lock->velocity * t_intersect;
   move_to(intersection);
}