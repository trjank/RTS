#include <godot_cpp/core/math.hpp>
#include "ship.hpp"

#define min_f godot::MIN<float, float>

float Ship::get_shield() {
   return shield;
}
float Ship::get_energy() {
   return energy;
}
void Ship::hit(float damage, float shield_pen) {
   float armor_pen = 1.0 - shield_pen;
   shield -= damage * shield_pen;
   //----------------------------------------------
   if (shield >= 0) return hit(damage * armor_pen);
   //----------------------------------------------
   hit(damage * armor_pen - shield);
   shield = 0.0;
}
void Ship::_physics_process(double dt) {
   Unit::_physics_process(dt);
   // TODO: update shield regen rate based on energy
	energy = min_f(energy + energy_per_sec * dt, max_energy);
   shield = min_f(shield + shield_per_sec * dt, max_shield);
}