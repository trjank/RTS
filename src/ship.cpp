#include "ship.hpp"

using namespace godot;

Ship* Ship::create_from(Ref<ShipData> ship_data) {
   if (ship_data.is_null()) return nullptr;
   
   Ship* ship = memnew(Ship);

   Vector2 image_offset = ship_data->get_grid_region().get_center() - ship_data->get_center_of_mass();

   ship->data = ship_data;
   ship->create_hitbox();
   ship->set_texture( ship_data->get_texture() );
   ship->resize_image( ship_data->get_grid_region().size * PartData::PX_PER_GRID_SQUARE);
   ship->set_image_offset(image_offset * PartData::PX_PER_GRID_SQUARE);

   for (int part_id: ship_data->get_unique_parts()) {
      ship->create_unique_part(part_id);
   }
   return ship;
}
Ship::Ship() {
   detection->set_shape_circle(1000.0);
   add_child(detection, false, INTERNAL_MODE_FRONT);
}
Ship* Ship::clone() const {
   return Object::cast_to<Ship>( duplicate(Node::DUPLICATE_SIGNALS) );
}
bool Ship::is_stunlocked() const {
   return energy < 0;
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
double Ship::get_share_min_energy() const {
   return share_min_energy;
}
Ref<ShipData> Ship::get_data() const {
   return data;
}
void Ship::set_kill_credit(Ref<Unit::RadarSignature> unit) {
   kill_credit = unit;
}
void Ship::set_share_min_energy(double new_share_min_energy) {
   share_min_energy = Math::max(0.0, new_share_min_energy);
}
// void Ship::target(Ref<Target> new_target) {
//    manual_target = new_target;
// }
void Ship::reset_stats() {
   hp         = data->get_max_hp();
   shield     = data->get_max_shield();
   energy     = data->get_max_energy();
   thrust     = data->get_thrust();
   turnrate   = data->get_turnrate();
   min_energy = data->get_max_energy() * RATIO_MIN_ENERGY;
}
void Ship::kill() {
   Unit::kill();

   get_player_owner()->register_loss( *this);

   if (kill_credit.is_valid()) kill_credit->unwrap()->get_player_owner()->register_kill( *this);
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
bool Ship::transfer_energy(double amount_energy, Ref<Unit::RadarSignature> ship) {
   if ( (energy -= amount_energy) > share_min_energy) return true;

   energy = share_min_energy;
   return false;
}
void Ship::transfer_energy_radius(double energy_per_ship, double range) {
   for (const Ref<Unit::RadarSignature> unit: detection->get_units()) {
      if ( !transfer_energy(energy_per_ship, unit)) break;
   }
}
void Ship::update_detection() {
   detection->update_detection();
}
void Ship::_draw() {
   // // Draw energy transfer circle

   // if ( !selected) return;

   // // Ref<ConvexPolygonShape2D> arc = detection->get_shape();
   // // draw_colored_polygon(arc->get_points(), {1.0, 1.0, 1.0, 0.5} );
   // draw_circle( {0.0, 0.0}, short_range, {1.0, 1.0, 1.0, 0.5} );
}
void Ship::_physics_process(double dt) {
   Unit::_physics_process(dt);

   calculate_reserve_ratios();

   // Warp and shield regen weaken as energy diminishes
   double warp_gain   = dt * data->get_warp_per_sec() * ratio_recharge_warp;
   double shield_gain = dt * data->get_shield_per_sec() * ratio_recharge_shield;
   double energy_gain = dt * data->get_energy_per_sec() - warp_gain * WARP_ENERGY_USE + shield_gain * SHIELD_ENERGY_USE;

   // Warp and shield cannot be negative (only energy can be negative)
   // warp   = Math::clamp(warp + warp_gain, 0.0, data->get_max_warp());
   shield = Math::clamp(shield + shield_gain, 0.0, data->get_max_shield());
   energy = Math::clamp(energy + energy_gain, min_energy, data->get_max_energy());
}
void Ship::create_unique_part(int part_id) {
   Part* unique_part       = Part::create_from( data->get_part_data(part_id) );
   Part::InitStatus status = unique_part->_ship_init( *this, part_id);

   if (unlikely(status != Part::OKAY_KEEP_PART)) return unique_part->queue_free();

   Vector2 position = data->get_part_center(part_id) - data->get_center_of_mass();

   add_child(unique_part);
   unique_part->set_position(position * PartData::PX_PER_GRID_SQUARE);
}
void Ship::create_hitbox() {
   CollisionShape2D* collision_shape = memnew(CollisionShape2D);

   Vector2i ship_size = data->get_ship_region().size;

   add_child(collision_shape);
   hitbox->set_size(ship_size * PartData::PX_PER_GRID_SQUARE);
   collision_shape->set_shape(hitbox);
}
void Ship::calculate_reserve_ratios() {
   ratio_reserve_energy  = Math::max(energy / data->get_max_energy(), -STUNLOCK_DRAIN);
   ratio_recharge_warp   = Math::pow(ratio_reserve_energy, WARP_RECHARGE_DROPOFF);
   ratio_recharge_shield = Math::pow(ratio_reserve_energy, SHIELD_RECHARGE_DROPOFF);
}