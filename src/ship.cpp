#include "ship.hpp"

using namespace godot;

Ship::Ship() {
   add_child(image = memnew(ResizableSprite2D));
}
bool Ship::is_stunlocked() {
   return energy < 0;
}
void Ship::fire() {
   emit_signal("fire");
}
void Ship::kill() {
   Unit::kill();
   if (owner) owner->get_team()->register_kill( *this);
}
Player* Ship::get_owner() {
   return owner;
}
int Ship::get_cost() {
   return data->get_cost();
}
double Ship::get_energy() {
   return energy;
}
double Ship::get_shield() {
   return shield;
}
Ref<ShipData> Ship::get_data() {
   return data;
}
void Ship::set_owner(Player* new_owner) {
   owner = new_owner;
}
void Ship::set_data(Ref<ShipData> new_data) {
   ERR_FAIL_NULL_MSG(new_data,
      "<Ship> Ship data is null (failed to set data)");
   
   if (new_data == data) return;

   image->set_texture(data->get_image());
   data     = new_data;
   hp       = data->get_max_hp();
   shield   = data->get_max_shield();
   energy   = data->get_max_energy();
   thrust   = data->get_thrust();
   turnrate = data->get_turnrate();

   for (Part* unique_part: unique_parts) {
      unique_part->queue_free();
   }
   unique_parts.clear();
   for (int part_id: data->get_unique_parts()) {
      create_unique_part(part_id)->_ship_init( *this, part_id);
   }
}
void Ship::copy_data_from(const Ship* other_ship) {
   ERR_FAIL_NULL_MSG(other_ship,
      "<Ship> Other ship is null (failed to copy data)");
   
   set_data(other_ship->data);
   for (int n = 0; n < unique_parts.size(); ++n) {
      unique_parts[n]->copy_unique_data_from( *other_ship->unique_parts[n] );
   }
}
double Ship::hit_shield(double damage) {
   shield -= damage;
   double overkill_damage = -Math::min(shield, 0.0);
   shield = Math::max(shield, 0.0);
   return overkill_damage;
}
void Ship::hit(double damage, double shield_penetration) {
   double shield_damage   = damage * shield_penetration;
   double shield_overkill = hit_shield(shield_damage);
   Unit::hit(damage - shield_damage + shield_overkill);
}
Part* Ship::create_unique_part(int part_id) {
   Ref<PartData> part_data = data->get_part_data(part_id);
   Part* unique_part = part_data->new_part();

   add_child(unique_part);
   unique_parts.push_back(unique_part);
   unique_part->set_data(part_data);
   unique_part->set_position( data->get_part_center_px(part_id) );
   return unique_part;
}
void Ship::calculate_reserve_ratios() {
   /*------------------------------------------------------|
   | Negative energy is allowed for stunlock. Instead of   |
   | immediately draining warp and shield, stunlock drains |
   | both over time in proportion to the energy deficit.   |
   |------------------------------------------------------*/
   ratio_reserve_energy  = Math::max(energy / data->get_max_energy(), -STUNLOCK_DRAIN);
   ratio_recharge_warp   = Math::pow(ratio_reserve_energy, WARP_RECHARGE_DROPOFF);
   ratio_recharge_shield = Math::pow(ratio_reserve_energy, SHIELD_RECHARGE_DROPOFF);
}
void Ship::_physics_process(double dt) {
   Unit::_physics_process(dt);

   calculate_reserve_ratios();
   double warp_gain   = dt * data->get_warp_per_sec() * ratio_recharge_warp;
   double shield_gain = dt * data->get_shield_per_sec() * ratio_recharge_shield;
   double energy_gain = dt * data->get_energy_per_sec();
   double min_energy  = -STUNLOCK_ENERGY_LIMIT * data->get_max_energy();

   energy_gain -= WARP_ENERGY_USE * warp_gain + SHIELD_ENERGY_USE * shield_gain;

   warp   = Math::clamp(warp + warp_gain, 0.0, data->get_max_warp());
   shield = Math::clamp(shield + shield_gain, 0.0, data->get_max_shield());
   energy = Math::clamp(energy + energy_gain, min_energy, data->get_max_energy());
}