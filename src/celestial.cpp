#include <godot_cpp/core/math.hpp>
#include "celestial.hpp"

using godot::MAX;
using godot::CLAMP;

double Celestial::get_time_scale() {
   return time_scale;
}
double Celestial::get_gravity_scale() {
   return gravity_scale;
}
void Celestial::set_gravity_scale(double new_gravity_scale) {
   gravity_scale = G * CLAMP(new_gravity_scale, MIN_GRAVITY_SCALE, MAX_GRAVITY_SCALE);
}
void Celestial::set_time_scale(double new_time_scale) {
   time_scale = CLAMP(new_time_scale, MIN_TIME_SCALE, MAX_TIME_SCALE);
}

double Celestial::get_mass() {
   return mass;
}
float Celestial::get_speed() {
   /*-------------------------------------------------------*
    | NOTE: Orbital speed is calculated on demand instead   |
    | of precalculated because gravity_scale can change at  |
    | any time, which would force ALL celestials to         |
    | recalculate it.                                       |
    *-------------------------------------------------------*/
   return sqrt(gravity_scale * central_celestial_mass / orbit_radius);
}
float Celestial::get_orbit_radius() {
   return orbit_radius;
}
void Celestial::set_orbit_radius(float new_radius) {
   orbit_radius = MAX(new_radius, MIN_ORBIT_RADIUS);
   set_position(new_radius * UNIT_RADIAL);
}
void Celestial::orbit(Celestial& celestial) {
   reparent(&celestial);
   central_celestial_mass = celestial.mass;
}
void Celestial::_physics_process(double dt) {
   rotate(get_speed() * dt * time_scale);
}