#include <algorithm>
#include <cmath>
#include "sim.hpp"

#define sq(x) (x * x)

using namespace sim;

using std::min;
using std::max;
using std::clamp;
using std::copysign;

float StaticBody::get_mass() {
	return mass;
}
void StaticBody::set_mass(float new_mass) {
	ERR_FAIL_COND(mass < 0);
	mass = new_mass;
}
Vector2 StaticBody::get_direction() {
	return Vector2::from_angle(get_rotation());
}
void StaticBody::generate_hitbox(/* image */) {}
Vector2 StaticBody::get_velocity() {
   return Vector2(0, 0);
}


float Body::get_friction() {
   return friction;
}
void Body::set_friction(float new_friction) {
	ERR_FAIL_COND(friction < 0);
   friction = new_friction;
}
float Body::get_angular_velocity() {
   return angular_velocity;
}
Vector2 Body::get_velocity() {
   return velocity;
}
void Body::set_velocity(Vector2 new_velocity) {
   velocity = new_velocity;
}
void Body::set_angular_velocity(float new_angular_vel) {
   angular_velocity = new_angular_vel;
}
void Body::set_turnrate(float new_turnrate) {
   turnrate = new_turnrate;
}
float Body::get_turnrate() {
   return turnrate;
}
void Body::apply_force(Vector2 new_force) {
   force += new_force;
}
void Body::apply_constant_force(Vector2 new_force) {
   constant_force += new_force;
}
void Body::set_constant_force(Vector2 new_force) {
   constant_force = new_force;
}
void Body::process_movement(double dt) {
   Vector2 net_force = force - friction * velocity;
   velocity += (net_force / mass) * dt;
   set_position(get_position() + velocity * dt);
   force = constant_force;
}
void Body::process_rotation(double dt) {
   set_rotation(get_rotation() + angular_velocity * dt);
}
void Body::_physics_process(double dt) {
   if (~state & CANT_MOVE) process_movement(dt);
   if (~state & CANT_FIRE) process_rotation(dt);
}



StaticBody* Turret::get_target() {
   return target;
}
void Turret::set_target(StaticBody* new_target) {
   target = new_target;
}
void Turret::set_ammo(Projectile* ammo_type) {
   ammo = ammo_type;
}
bool Turret::fire() {
   if (ammo == nullptr || state & CANT_FIRE || reload_timer < reload) return false;

   Projectile projectile = ammo->copy();
   projectile.set_position(get_global_position());
   projectile.set_rotation(get_global_rotation());
   reload_timer = 0;
   return true;
}
void Turret::_physics_process(double dt) {
   if (target == nullptr) return;

   reload_timer = min(reload_timer + dt, reload);

	if (state & CANT_TURN) return;

	Vector2 delta_x = target->get_position() - get_position();
	set_rotation(clamp(delta_x.angle(), min_angle, max_angle));
	Body::process_rotation(dt);
}


void Projectile::set_speed(float new_speed) {
   ERR_FAIL_COND(speed < 0);
   speed = new_speed;
}
StaticBody* Projectile::get_target() {
   return target;
}
void Projectile::set_target(StaticBody* new_target) {
   target = new_target;
}
float Projectile::get_speed() {
   return speed;
}
void Projectile::turn_to_dir(Vector2 dir) {
   float rot_dir = get_direction().cross(dir);
	angular_velocity = copysign(turnrate, rot_dir);
}
void Projectile::_physics_process(double dt) {
   if (target == nullptr || state & CANT_TURN) return;

   Vector2 tar_vel = target->get_velocity();
   Vector2 delta_x = target->get_position() - get_position();
	float delta_x_sq = delta_x.length_squared();
	float tar_vel_sq = tar_vel.length_squared();
	float dx_dot_vel = delta_x.dot(tar_vel);
	float discrim = sq(dx_dot_vel) + delta_x_sq * (sq(speed) - tar_vel_sq);

   // TODO: define what happens when the target cannot be reached
	bool can_reach_target = discrim < 0;

   float norm_fact = (sqrt(discrim) - dx_dot_vel) / delta_x_sq;
   turn_to_dir(tar_vel + delta_x * norm_fact);

	Body::process_rotation(dt);

	if (state & CANT_MOVE) return;
	
   velocity = speed * get_direction();
	Body::process_movement(dt);
}
Projectile Projectile::copy() {
   return *this;
}


// void ProjectileManager::add(string name, Projectile projectile) {
//    name_to_proj[name] = projectile;
// }
// void ProjectileManager::remove(string name) {
//    name_to_proj.erase(name);
// }
// void ProjectileManager::clear() {
//    name_to_proj.clear();
// }
// Projectile& ProjectileManager::get(string name) {
//    return name_to_proj[name];
// }


float Unit::get_top_speed() {
   return top_speed;
}
void Unit::calculate_top_speed() {
   top_speed = thrust / (mass * friction);
}
void Unit::set_friction(float new_friction) {
   friction = new_friction;
   calculate_top_speed();
}
void Unit::set_mass(float new_mass) {
   mass = new_mass;
   calculate_top_speed();
}
float Unit::get_thrust() {
   return thrust;
}
void Unit::set_thrust(float new_thrust) {
   thrust = new_thrust;
   calculate_top_speed();
}
StaticBody* Unit::get_target() {
   return target;
}
void Unit::set_target(StaticBody* new_target) {
   target = new_target;
}
// void Unit::add_turret(Turret new_turret) {
//    turrets.push_back(new_turret);
// }
// void Unit::remove_all_turrets() {
// 	turrets.clear();
// }
void Unit::hit(int damage, float penetration) {
   shield -= damage * penetration;
   HP -= damage * (1 - penetration) + min(shield, 0);
   shield = max(shield, 0);
}
void Unit::face_target() {
   if (target == nullptr || state & (CANT_MOVE | CANT_TURN)) return;

   Vector2 cur_pos = get_position();
   Vector2 dest = target->get_position();
   Vector2 delta_x = dest - cur_pos;
	float delta_rot = get_direction().angle_to(delta_x);
   float time_to_turn = abs(delta_rot) / turnrate;
	float time_to_move = cur_pos.distance_to(dest) / top_speed;
	float dest_dist_sq = delta_x.length_squared();
	float stop_dist_sq = velocity.dot(delta_x) / friction;

   bool is_facing_tar = time_to_turn < time_to_move * arcing;
   bool will_overshoot = dest_dist_sq <= stop_dist_sq;

   angular_velocity = copysign(turnrate, delta_rot);
   if (is_facing_tar && !will_overshoot) apply_force(thrust * get_direction());
   if (will_overshoot) {
      target = nullptr;
      angular_velocity = 0;
   }
}
Unit Unit::copy() {
   return *this;
}
void Unit::_physics_process(double dt) {
   face_target();
   Body::_physics_process(dt);
   energy = min(energy + energy_gen, max_energy);
   shield = min(shield + shield_gen, max_shield);
}