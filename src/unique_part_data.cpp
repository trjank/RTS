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
   hitbox_size = new_hitbox_size.min( {0.0, 0.0} );
}


void WeaponModifiers::combine(const WeaponModifiers& other_modifiers) {
   combine_flat(other_modifiers);
   combine_multipliers(other_modifiers);
}
void WeaponModifiers::combine_flat(const WeaponModifiers& other_modifiers) {
   flat_range  += other_modifiers.flat_range;
   flat_energy += other_modifiers.flat_energy;
   flat_speed  += other_modifiers.flat_speed;
}
void WeaponModifiers::combine_multipliers(const WeaponModifiers& other_modifiers) {
   multiplier_range    *= other_modifiers.multiplier_range;
   multiplier_energy   *= other_modifiers.multiplier_energy;
   multiplier_speed    *= other_modifiers.multiplier_speed;
   multiplier_cooldown *= other_modifiers.multiplier_cooldown;
}


const WeaponModifiers& WeaponModifierData::get_modifiers() const {
   return modifiers;
}
double WeaponModifierData::get_flat_range() const {
   return modifiers.flat_range;
}
double WeaponModifierData::get_flat_energy() const {
   return modifiers.flat_energy;
}
double WeaponModifierData::get_flat_speed() const {
   return modifiers.flat_speed;
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
void WeaponModifierData::set_flat_range(double new_flat_range) {
   modifiers.flat_range = Math::max(new_flat_range, MIN_FLAT);
}
void WeaponModifierData::set_flat_energy(double new_flat_energy) {
   modifiers.flat_energy = Math::max(new_flat_energy, MIN_FLAT);
}
void WeaponModifierData::set_flat_speed(double new_flat_speed) {
   modifiers.flat_speed = Math::max(new_flat_speed, MIN_FLAT);
}
void WeaponModifierData::set_multiplier_range(double new_multiplier_range) {
   modifiers.multiplier_range = Math::max(new_multiplier_range, MIN_MULTIPLIER);
}
void WeaponModifierData::set_multiplier_energy(double new_multiplier_energy) {
   modifiers.multiplier_energy = Math::max(new_multiplier_energy, MIN_MULTIPLIER);
}
void WeaponModifierData::set_multiplier_speed(double new_multiplier_speed) {
   modifiers.multiplier_speed = Math::max(new_multiplier_speed, MIN_MULTIPLIER);
}
void WeaponModifierData::set_multiplier_cooldown(double new_multiplier_cooldown) {
   modifiers.multiplier_cooldown = Math::max(new_multiplier_cooldown, MIN_MULTIPLIER);
}
void WeaponModifierData::load_unique_data(Dictionary data) {
   PartData::load_unique_data(data);

   set_multiplier_range( data.get("flag_range", modifiers.flat_range) );
   set_multiplier_energy( data.get("flat_energy", modifiers.flat_energy) );
   set_multiplier_speed( data.get("flat_speed", modifiers.flat_speed) );
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
   set_effective_range( data.get("effective_range", effective_range) );
   set_spread_angle( data.get("spread_angle", spread_angle) );
   set_sec_between_shots( data.get("sec_between_shots", sec_between_shots) );
   set_reload_sec( data.get("reload_sec", reload_sec) );
}
bool WeaponData::is_burst_weapon() const {
   return shots_per_burst == 1;
}
int WeaponData::get_shots_per_burst() const {
   return shots_per_burst;
}
double WeaponData::get_energy_per_shot() const {
   return energy_per_shot;
}
double WeaponData::get_firerate() const {
   return firerate;
}
double WeaponData::get_burst_firerate() const {
   return burst_firerate;
}
double WeaponData::get_effective_range() const {
   return effective_range;
}
double WeaponData::get_spread_angle() const {
   return spread_angle;
}
double WeaponData::get_sec_between_shots() const {
   return sec_between_shots;
}
double WeaponData::get_reload_sec() const {
   return reload_sec;
}
void WeaponData::set_shots_per_burst(int new_shots_per_burst) {
   shots_per_burst = Math::max(new_shots_per_burst, 1);
   calculate_firerates();
}
void WeaponData::set_energy_per_shot(double new_energy_per_shot) {
   energy_per_shot = new_energy_per_shot;
}
void WeaponData::set_effective_range(double new_effective_range) {
   effective_range = Math::max(new_effective_range, 0.0);
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

   // Ignore burst_firerate for non-burst weapons
   firerate       = shots_per_burst / cycle_sec;
   burst_firerate = shots_per_burst / burst_sec;
}


double WeaponMountData::get_min_angle() const {
   return min_angle;
}
double WeaponMountData::get_max_angle() const {
   return max_angle;
}
int WeaponMountData::get_firing_arc_degrees() const {
   return firing_arc_degrees;
}
int WeaponMountData::get_angle_degrees() const {
   return angle_degrees;
}
void WeaponMountData::set_firing_arc_degrees(double new_firing_arc_degrees) {
   firing_arc_degrees = new_firing_arc_degrees;
   calculate_min_max_angles();
}
void WeaponMountData::set_angle_degrees(double new_angle_degrees) {
   angle_degrees = new_angle_degrees;
   calculate_min_max_angles();
}
void WeaponMountData::load_unique_data(Dictionary data) {
   WeaponModifierData::load_unique_data(data);

   set_angle_degrees( data.get("angle_degrees", angle_degrees) );
   set_firing_arc_degrees( data.get("firing_arc_degrees", firing_arc_degrees) );
}
void WeaponMountData::calculate_min_max_angles() {
   double arc   = Math::deg_to_rad(firing_arc_degrees);
   double angle = Math::deg_to_rad(angle_degrees);

   min_angle = angle - 0.5 * arc;
   max_angle = angle + 0.5 * arc;
}