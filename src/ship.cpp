#include <godot_cpp/core/math.hpp>
#include "ship.hpp"

using namespace godot;

Ship::Ship() {
   add_child(image = memnew(ResizableSprite2D));
}
int Ship::get_cost() {
   return stats->get_cost();
}
float Ship::get_energy() {
   return energy;
}
float Ship::get_shield() {
   return shield;
}
Ref<ShipData> Ship::get_data() {
   return stats;
}
void Ship::set_data(Ref<ShipData> new_data) {
   ERR_FAIL_COND_MSG(new_data.is_null(),
      "<Ship> ShipData is null (failed to set data)");

   stats    = new_data;
   hp       = stats->get_max_hp();
   shield   = stats->get_max_shield();
   energy   = stats->get_max_energy();
   turnrate = stats->get_turnrate();
   image->set_texture(stats->get_image());
}
float Ship::hit_shield(float damage) {
   shield -= damage;

   if (shield > 0) return 0.0;

   float overkill = -shield;
   shield = 0.0;
   return overkill;
}
void Ship::hit(float damage, float shield_penetration) {
   float shield_damage   = damage * shield_penetration;
   float shield_overkill = hit_shield(shield_damage);
   Unit::hit(damage - shield_damage + shield_overkill);
}
void Ship::kill() {
   Unit::kill();

   ERR_FAIL_COND( !owner || owner->get_team().is_null());
   
   owner->get_team()->register_kill(*this);
}
void Ship::fire() {
   // for (TurretMount* weapon: weapons) {
   //    weapon->fire_at(get_target());
   // }
}
void Ship::_physics_process(double dt) {
   Unit::_physics_process(dt);
   // TODO: update shield regen rate based on energy
	energy = MIN(energy + stats->get_energy_per_sec() * dt, stats->get_max_energy());
   shield = MIN(shield + stats->get_shield_per_sec() * dt, stats->get_max_shield());
   warp   = MIN(warp + stats->get_warp_per_sec() * dt, stats->get_max_warp());
}