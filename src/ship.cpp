#include "ship.hpp"

using namespace godot;

Ship* Ship::create_from(Ref<ShipData> ship_data) {
   if (ship_data.is_null()) return nullptr;
   
   Ship* ship = memnew(Ship);
   ship->data = ship_data;
   ship->create_image();

   for (int part_id: ship_data->get_unique_parts() ) {
      ship->create_unique_part(part_id)->_ship_init( *ship, part_id);
   }
   return ship;
}
bool Ship::is_stunlocked() const {
   return energy < 0;
}
bool Ship::is_owned_by(Ref<Player> player) const {
   return owner == player;
}
void Ship::fire() {
   emit_signal("fire");
}
int Ship::get_cost() const {
   return data->get_cost();
}
double Ship::get_energy() const {
   return energy;
}
double Ship::get_shield() const {
   return shield;
}
double Ship::get_ratio_reserve_energy() const {
   return ratio_reserve_energy;
}
double Ship::get_ratio_recharge_warp() const {
   return ratio_recharge_warp;
}
double Ship::get_ratio_recharge_shield() const {
   return ratio_recharge_shield;
}
Ref<ShipData> Ship::get_data() const {
   return data;
}
Ref<Player> Ship::get_owner() const {
   return owner;
}
void Ship::set_owner(Ref<Player> new_owner) {
   ERR_FAIL_NULL_MSG(new_owner,
   "<Ship> New owner is null (failed to set owner)");

   owner = new_owner;
}
void Ship::reset_stats() {
   hp         = data->get_max_hp();
   shield     = data->get_max_shield();
   energy     = data->get_max_energy();
   thrust     = data->get_thrust();
   turnrate   = data->get_turnrate();
   min_energy = data->get_max_energy() * RATIO_MIN_ENERGY;
}
void Ship::kill() {
   owner->register_loss( *this);
   Unit::kill();
}
double Ship::hit_shield(double damage) {
   if ( (shield -= damage) >= 0) return 0.0;

   double overkill_damage = -shield;
   shield = 0.0;
   return overkill_damage;
}
void Ship::hit(double damage, double shield_penetration) {
   double shield_damage   = damage * shield_penetration;
   double shield_overkill = hit_shield(shield_damage);
   Unit::hit(damage - shield_damage + shield_overkill);
}
Ship* Ship::clone() const {
   /*------------------------------------------------------|
   | It may be expensive to keep recalculating adjacency   |
   | data for each ship. Direct copying may be cheaper,    |
   | but it ignores any updates to PartData.               |
   |------------------------------------------------------*/
   return Object::cast_to<Ship>( duplicate(Node::DUPLICATE_SIGNALS) );
}
void Ship::_physics_process(double dt) {
   Unit::_physics_process(dt);

   calculate_reserve_ratios();
   double warp_gain   = dt * data->get_warp_per_sec() * ratio_recharge_warp;
   double shield_gain = dt * data->get_shield_per_sec() * ratio_recharge_shield;
   double energy_gain = dt * data->get_energy_per_sec();

   energy_gain -= warp_gain * WARP_ENERGY_USE + shield_gain * SHIELD_ENERGY_USE;

   warp   = Math::clamp(warp + warp_gain, 0.0, data->get_max_warp());
   shield = Math::clamp(shield + shield_gain, 0.0, data->get_max_shield());
   energy = Math::clamp(energy + energy_gain, min_energy, data->get_max_energy());
}
Part* Ship::create_unique_part(int part_id) {
   /*------------------------------------------------------|
   | Only unique parts become their own nodes. For team    |
   | games, make sure to minimize the node count for       |
   | performance. Static parts are far cheaper.            |
   |------------------------------------------------------*/
   Part* unique_part = Part::create_from( data->get_part_data(part_id) );
   add_child(unique_part);
   unique_part->set_position( data->get_part_center_px(part_id) );
   return unique_part;
}
void Ship::create_image() {
   ResizableSprite2D* image = memnew(ResizableSprite2D);

   add_child(image);
   image->set_texture( data->get_image() );
   image->resize( data->get_size_px() );
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