#include "unit.hpp"

Unit::Unit() {
   radar_signature.instantiate();
   radar_signature->state = ALIVE;
   radar_signature->unit = this;
}
Unit::~Unit() {
   radar_signature->state = DEAD;
   radar_signature->unit = nullptr;
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
void Unit::move_to_target() {
   // Get the current move command (if possible)
   if (move_commands.is_empty()) return;
   Ref<Command> command = move_commands.front()->get();
   if (not command->is_valid()) return move_commands.pop_front();
   command->execute_from(*this);
   Vector2 separation = command->get_position() - get_global_position();
   distance_to_target = separation.length();
   // Turn to face the target (if possible)
   if (not can_turn) return;
   angle_to_target = separation.angle() - get_global_rotation();
   angular_velocity = copysign(turnrate, angle_to_target);
   time_to_turn = angle_to_target / angular_velocity;
}
void Unit::_process(double _dt) {
   // queue_redraw();
}
void Unit::_draw() {
   // const Color PATH_COLOR = {1.0, 1.0, 1.0};
   // constexpr float PATH_WIDTH = 1.0;
   // Vector2 line_start = get_position();
   // for (Ref<Waypoint> waypoint: move_commands) {
   //    Vector2 line_end = waypoint->get_global_position();
   //    draw_line(line_start, line_end, PATH_COLOR, PATH_WIDTH);
   //    line_start = line_end;
   // }
}
void Unit::_physics_process(double dt) {
   move_to_target();
   radar_signature->velocity = velocity;
   applying_thrust = time_to_turn <= path_arcing * time_to_move;
   Vector2 facing;
   Vector2 net_force = force;
   if (can_move and applying_thrust) net_force += thrust * facing;
   velocity += net_force * (dt / mass);
   set_position(get_position() + velocity * dt);
   rotate(angular_velocity * dt);
}