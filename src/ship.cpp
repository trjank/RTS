#include <godot_cpp/core/math.hpp>
#include "ship.hpp"

using namespace godot;

int Ship::get_cost() {
   return cost;
}
float Ship::get_energy() {
   return energy;
}
float Ship::get_shield() {
   return shield;
}
float Ship::hit_shield(float damage) {
   shield -= damage;
   if (shield >= 0) return 0.0;
   float overkill = -shield;
   shield = 0.0;
   return overkill;
}
void Ship::hit(float damage, float shield_penetration) {
   float shield_damage = damage * shield_penetration;
   float shield_overkill = hit_shield(shield_damage);
   Unit::hit(damage - shield_damage + shield_overkill);
}
void Ship::kill() {
   Unit::kill();

   // ERR_FAIL_COND( !owner || owner->get_team().is_null());
   
   // owner->get_team()->register_kill(*this);
}
void Ship::_physics_process(double dt) {
   Unit::_physics_process(dt);
   // TODO: update shield regen rate based on energy
	energy = MIN(energy + energy_per_sec * dt, max_energy);
   shield = MIN(shield + shield_per_sec * dt, max_shield);
   warp = MIN(warp + warp_per_sec * dt, max_warp);
}