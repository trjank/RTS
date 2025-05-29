#include <godot_cpp/core/math.hpp>
#include "celestial.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                     celestial.cpp                     |
|                                                       |
*------------------------------------------------------*/

using godot::Math::max;
using godot::Math::clamp;

double Orbit::time_scale = 1.0;
double Orbit::gravity_scale = 1.0;

double Orbit::get_time_scale() {
   return time_scale;
}
double Orbit::get_gravity_scale() {
   return gravity_scale;
}
void Orbit::set_time_scale(double new_time_scale) {
   time_scale = clamp(new_time_scale, MIN_TIME_SCALE, MAX_TIME_SCALE);
}
void Orbit::set_gravity_scale(double new_gravity_scale) {
   gravity_scale = clamp(new_gravity_scale, MIN_GRAVITY_SCALE, MAX_GRAVITY_SCALE);
}

double Orbit::get_angular_velocity() {
   if ( !orbiting) return 0.0;
   double new_G = gravity_scale * G;
   return sqrt(new_G * orbiting->get_mass() / distance);
}
double Orbit::get_distance() {
   return distance;
}
void Orbit::set_distance(double new_distance) {
   distance = max(new_distance, MIN_DISTANCE);
   set_position(new_distance * unit_radial);
   queue_redraw();
}
void Orbit::orbit(Celestial* celestial) {
   ERR_FAIL_COND( !celestial);
   reparent(celestial);
   orbiting = celestial;
}
void Orbit::_physics_process(double dt) {
   rotate(get_angular_velocity() * time_scale * dt);
}
void Orbit::_draw() {
   constexpr int NUM_SEGMENTS = 100;
   constexpr double THICKNESS = 1.0;
   draw_arc({ 0.0, 0.0 }, distance, 0.0, Math_TAU, NUM_SEGMENTS, COLOR, THICKNESS, true);
}



Celestial::Celestial() {
   Area2D* capture_zone = memnew(Area2D);
   CollisionShape2D* shape = memnew(CollisionShape2D);
   hitbox.instantiate();
   add_child(capture_zone);
   shape->set_shape(hitbox);
}
bool Celestial::can_capture() {
   return true;
}
double Celestial::get_mass() {
   return mass;
}
double Celestial::get_radius() {
   return radius;
}
double Celestial::get_angular_velocity() {
   return angular_velocity;
}
double Celestial::get_alloy_per_sec() {
   return 0.0;
}
double Celestial::get_energy_per_sec() {
   return 0.0;
}
void Celestial::set_angular_velocity(float new_angular_velocity) {
   angular_velocity = new_angular_velocity;
}
void Celestial::set_radius(double new_radius) {
   radius = max(new_radius, 0.0);
   hitbox->set_radius(radius);
}
void Celestial::_physics_process(double dt) {
   rotate(angular_velocity * Orbit::get_time_scale() * dt);
}