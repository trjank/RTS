#include "unique_part_data.hpp"

using namespace godot;

Ref<PartData> PartData::create_correct_subtype(String subtype) {
   if (subtype == "weapon")
      return memnew(WeaponData);
   if (subtype == "weapon_modifier")
      return memnew(WeaponModifierData);
   if (subtype == "weapon_mount")
      return memnew(WeaponMountData);
   if (subtype == "projectile")
      return memnew(ProjectileData);
   if (subtype != "")
      WARN_PRINT_ED("<PartData> Subtype '" + subtype + "' not recognized");
   return memnew(PartData);
}


void ProjectileData::load_unique_data(Dictionary data) {
   PartData::load_unique_data(data);

   set_hitscan( data.get("hitscan", hitscan) );
   set_size( data.get("hitbox_size", hitbox_size) );
}
bool ProjectileData::is_hitscan() {
   return hitscan;
}
Vector2 ProjectileData::get_hitbox_size() {
   return hitbox_size;
}
void ProjectileData::set_hitscan(bool make_hitscan) {
   hitscan = make_hitscan;
}
void ProjectileData::set_hitbox_size(Vector2 new_hitbox_size) {
   hitbox_size = new_hitbox_size.min( {0.0F, 0.0F} );
}


void WeaponModifiers::combine(const WeaponModifiers& other_modifiers) {
   /*------------------------------------------------------|
   | Modifiers stack exponentially. If you want to impose  |
   | limits, do so here. However, we recommend you         |
   | change the size of the mods instead. This simplifies  |
   | the logic and serves as a visual cue to players.      |
   |------------------------------------------------------*/
   multiplier_range    *= other_modifiers.multiplier_range;
   multiplier_energy   *= other_modifiers.multiplier_energy;
   multiplier_speed    *= other_modifiers.multiplier_speed;
   multiplier_cooldown *= other_modifiers.multiplier_cooldown;
}


double WeaponModifierData::get_multiplier_range() const {
   return modifiers.multiplier_range;
}
double WeaponModifierData::get_multiplier_energy() const {
   return modifiers.multiplier_energy;
}
double WeaponModifierData::get_multiplier_speed() const {
   return modifiers.multiplier_speed;
}
double WeaponModifierData::get_multiplier_cooldown() const {
   return modifiers.multiplier_cooldown;
}
void WeaponModifierData::set_multiplier_range(double new_multiplier_range) {
   modifiers.multiplier_range = Math::max(new_multiplier_range, 0.0);
}
void WeaponModifierData::set_multiplier_energy(double new_multiplier_energy) {
   modifiers.multiplier_energy = Math::max(new_multiplier_energy, 0.0);
}
void WeaponModifierData::set_multiplier_speed(double new_multiplier_speed) {
   modifiers.multiplier_speed = Math::max(new_multiplier_speed, 0.0);
}
void WeaponModifierData::set_multiplier_cooldown(double new_multiplier_cooldown) {
   modifiers.multiplier_cooldown = Math::max(new_multiplier_cooldown, 0.0);
}
void WeaponModifierData::load_unique_data(Dictionary data) {
   PartData::load_unique_data(data);

   set_multiplier_range( data.get("multiplier_range", modifiers.multiplier_range) );
   set_multiplier_energy( data.get("multiplier_energy", modifiers.multiplier_energy) );
   set_multiplier_speed( data.get("multiplier_speed", modifiers.multiplier_speed) );
   set_multiplier_cooldown( data.get("multiplier_cooldown", modifiers.multiplier_cooldown) );
}


WeaponData::WeaponData() {
   behavior = PartData::UNIQUE_DISCONNECTED;
}
void WeaponData::load_unique_data(Dictionary data) {
   PartData::load_unique_data(data);

   set_shots_per_burst( data.get("shots_per_burst", shots_per_burst) );
   set_energy_per_shot( data.get("energy_per_shot", energy_per_shot) );
   set_base_range( data.get("base_range", base_range) );
   set_spread_angle( data.get("spread_angle", spread_angle) );
   set_sec_between_shots( data.get("sec_between_shots", sec_between_shots) );
   set_reload_sec( data.get("reload_sec", reload_sec) );
}
bool WeaponData::is_burst_weapon() {
   return shots_per_burst == 1;
}
int WeaponData::get_shots_per_burst() {
   return shots_per_burst;
}
double WeaponData::get_energy_per_shot() {
   return energy_per_shot;
}
double WeaponData::get_firerate() {
   return firerate;
}
double WeaponData::get_burst_firerate() {
   return burst_firerate;
}
double WeaponData::get_base_range() {
   return base_range;
}
double WeaponData::get_spread_angle() {
   return spread_angle;
}
double WeaponData::get_sec_between_shots() {
   return sec_between_shots;
}
double WeaponData::get_reload_sec() {
   return reload_sec;
}
void WeaponData::set_shots_per_burst(int new_shots_per_burst) {
   shots_per_burst = Math::max(new_shots_per_burst, 1);
   calculate_firerates();
}
void WeaponData::set_energy_per_shot(double new_energy_per_shot) {
   energy_per_shot = new_energy_per_shot;
}
void WeaponData::set_base_range(double new_base_range) {
   base_range = Math::max(new_base_range, 0.0);
}
void WeaponData::set_spread_angle(double new_spread_angle) {
   spread_angle = Math::abs(new_spread_angle);
}
void WeaponData::set_sec_between_shots(double new_sec_between_shots) {
   sec_between_shots = Math::max(new_sec_between_shots, MIN_SEC_BETWEEN_SHOTS);
   calculate_firerates();
}
void WeaponData::set_reload_sec(double new_reload_sec) {
   reload_sec = Math::max(new_reload_sec, MIN_RELOAD_SEC);
   calculate_firerates();
}
void WeaponData::calculate_firerates() {
   double burst_sec = sec_between_shots * (shots_per_burst - 1);
   double cycle_sec = burst_sec + reload_sec;
   firerate         = shots_per_burst / cycle_sec;
   burst_firerate   = shots_per_burst / burst_sec;
}


ShipData::BoundaryFlag WeaponMountData::get_mod_boundary(ShipData::RotationState _rotation) {
   return ShipData::FULL_PERIMETER;
}
bool WeaponMountData::is_compatible_with(Ref<WeaponData> weapon) {
   return weapon.is_valid() && get_size().width == weapon->get_size().width;
}
double WeaponMountData::get_min_angle() {
   return min_angle;
}
double WeaponMountData::get_max_angle() {
   return max_angle;
}
int WeaponMountData::get_firing_arc_degrees() {
   return firing_arc_degrees;
}
int WeaponMountData::get_angle_degrees() {
   return angle_degrees;
}
void WeaponMountData::set_firing_arc_degrees(double new_firing_arc_degrees) {
   firing_arc_degrees = new_firing_arc_degrees;
   calculate_min_max();
}
void WeaponMountData::set_angle_degrees(double new_angle_degrees) {
   angle_degrees = new_angle_degrees;
   calculate_min_max();
}
void WeaponMountData::load_unique_data(Dictionary data) {
   WeaponModifierData::load_unique_data(data);

   set_angle_degrees( data.get("angle_degrees", angle_degrees) );
   set_firing_arc_degrees( data.get("firing_arc_degrees", firing_arc_degrees) );
}
void WeaponMountData::calculate_min_max() {
   double angle = Math::deg_to_rad(angle_degrees);
   double arc   = Math::deg_to_rad(firing_arc_degrees);
   min_angle    = angle - 0.5 * arc;
   max_angle    = angle + 0.5 * arc;
}