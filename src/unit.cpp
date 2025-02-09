#include "unit.hpp"

Unit::Unit() {
   radar_signature.instantiate();
   radar_signature->state = ALIVE;
   applying_thrust = false;
   can_move = true;
}
Unit::~Unit() {
   radar_signature->state = DEAD;
}
void Unit::kill() {
   queue_free();
}
void Unit::stop_moving() {
   move_commands.clear();
}
void Unit::stop_targeting() {
   target.unref();
}
void Unit::queue_move(Ref<Unit::Command> new_command) {
   move_commands.push_back(new_command);
}
void Unit::set_target(Ref<Unit::Command> new_target) {
   target = new_target;
}
Ref<Unit::RadarSignature> Unit::lock_on() {
   return radar_signature;
}
Vector2 Unit::get_forward_direction() {
   constexpr int Y_BASIS_VECTOR = 1;
   return get_transform().columns[Y_BASIS_VECTOR];
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
   radar_signature->velocity = velocity;
   radar_signature->position = get_global_position();
}
void Unit::hit(float damage) {
   HP -= damage;
   if (HP <= 0) kill();
}
void Unit::move_to_target() {
   if (move_commands.is_empty()) return;
   Ref<Unit::Command> command = move_commands.front()->get();
   if (not command->is_valid()) return move_commands.pop_front();
   /*--------------------------------------------------------------*/
   Vector2 separation = command->get_position() - get_global_position();
   distance_to_target = separation.length();
   angle_to_target    = separation.angle() - get_global_rotation();
   angular_velocity   = copysign(turnrate, angle_to_target);
   time_to_turn       = angle_to_target / angular_velocity;
   stop_distance      = velocity.dot(separation.normalized());
   applying_thrust    = can_move and
                        distance_to_target > stop_distance and
                        time_to_turn <= path_arcing * time_to_move;
   /*--------------------------------------------------------------*/
   if (command->is_controlled_by(this)) order_attack(command);
}
void Unit::_physics_process(double dt) {
   update_radar_signature();
   move_to_target();
   Vector2 net_force = force;
   if (applying_thrust) net_force += thrust * get_forward_direction();
   velocity += net_force * (dt / mass);
   set_position(get_position() + velocity * dt);
   rotate(angular_velocity * dt);
}
void Unit::_process(double _dt) {
   queue_redraw();
}
void Unit::_draw() {}



Unit::Command::Command() {
   icon = memnew(Sprite2D);
}
Unit::Command::~Command() {
   icon->queue_free();
}
void Unit::Command::invalidate() {
   valid = false;
}
bool Unit::Command::is_valid() {
   return valid and (prey.is_null() or prey->state != Unit::DEAD);
}
Vector2 Unit::Command::get_position() {
   return icon->get_global_position();
}
bool Unit::Command::is_controlled_by(Unit* caller) {
   return predator == caller;
}
void Unit::Command::move_to(Vector2 new_position) {
   icon->set_global_position(new_position);
}
void Unit::Command::ram() {
   move_to(prey->position);
}
void Unit::Command::kite(float min_distance, float max_distance) {
   bool too_close = predator->distance_to_target < min_distance;
   bool too_far   = predator->distance_to_target > max_distance;
   predator->can_move = too_close or too_far;
   if (too_close) flee(max_distance);
   else if (too_far) ram();
}
void Unit::Command::flee(float safe_distance) {
   Vector2 pred_pos = predator->get_global_position();
   Vector2 radial   = pred_pos - prey->position;
   Vector2 safe_pos = pred_pos - safe_distance * radial.normalized();
   move_to(safe_pos);
}
void Unit::Command::track() {
   Vector2 pred_pos    = predator->get_global_position();
   Vector2 radial      = pred_pos - prey->position;
   float v_r           = prey->velocity.dot(radial);
   float pred_speed_sq = predator->velocity.length_squared();
   float prey_speed_sq = prey->velocity.length_squared();
   float d_speed_sq    = pred_speed_sq - prey_speed_sq;
   float discriminant  = v_r * v_r + d_speed_sq * radial.length_squared();
   /*-----------------------------------------------------------*/
   if (discriminant < 0) return ram(); // Target is unreachable
   /*-----------------------------------------------------------*/
   float time_intersect = (v_r + sqrt(discriminant)) / d_speed_sq;
   Vector2 intersection = prey->position + time_intersect * prey->velocity;
   move_to(intersection);
}