#include "unit.hpp"

Unit::Unit() {
   radar_signature.instantiate();
   radar_signature->state = ALIVE;
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
void Unit::queue_move(Ref<Command> new_command) {
   move_commands.push_back(new_command);
}
void Unit::set_target(Ref<Command> new_target) {
   target = new_target;
}
Ref<const Unit::RadarSignature> Unit::lock_on() {
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
   Ref<Command> command = move_commands.front()->get();
   if (not command->is_valid()) return move_commands.pop_front();

   Vector2 separation = command->get_position() - get_global_position();
   distance_to_target = separation.length();
   angle_to_target    = separation.angle() - get_global_rotation();
   angular_velocity   = copysign(turnrate, angle_to_target);
   time_to_turn       = angle_to_target / angular_velocity;
   stop_distance      = velocity.dot(separation.normalized());
   applying_thrust    = can_move and
                        distance_to_target > stop_distance and
                        time_to_turn <= path_arcing * time_to_move;

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
void Unit::_draw() {

}