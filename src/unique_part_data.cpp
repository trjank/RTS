#include "unique_part_data.hpp"

using namespace godot;

ProjectileData::ProjectileData() {
   exposed_to_design_mode = SHOW_PROJECTILES_IN_DESIGN_MODE;
}
void ProjectileData::load_unique_data(Dictionary data) {
   PartData::load_unique_data(data);
   bool instahit = data.get("hitscan", hitscan);
   Vector2 size  = data.get("hitbox_size", hitbox_size);
   set_hitscan(instahit);
   set_size(size);
}
Part* ProjectileData::new_part() {
   WARN_PRINT_ED("<ProjectileData> Use new_projectile instead of new_part");
   return nullptr;
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


WeaponData::WeaponData() {
   unique = true;
}
void WeaponData::load_unique_data(Dictionary data) {
   PartData::load_unique_data(data);
   int shots        = data.get("shots_per_burst", shots_per_burst);
   double energy    = data.get("energy_per_shot", energy_per_shot);
   double range     = data.get("base_range", base_range);
   double spread    = data.get("spread_angle", spread_angle);
   double sec_shots = data.get("sec_between_shots", sec_between_shots);
   double reload    = data.get("reload_sec", reload_sec);
   set_shots_per_burst(shots);
   set_energy_per_shot(energy);
   set_base_range(range);
   set_spread_angle(spread);
   set_sec_between_shots(sec_shots);
   set_reload_sec(reload);
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
   bool div_by_zero = shots_per_burst == 1;
   firerate         = shots_per_burst / (burst_sec + reload_sec);
   burst_firerate   = div_by_zero ? firerate : (shots_per_burst / burst_sec);
}


void TurretMountData::load_unique_data(Dictionary data) {
   PartData::load_unique_data(data);
   double angle = data.get("firing_arc_degrees", firing_arc_degrees);
   double arc   = data.get("angle_degrees", angle_degrees);
   set_firing_arc_degrees(arc);
   set_angle_degrees(angle);
}
bool TurretMountData::is_compatible_with(Ref<WeaponData> weapon) {
   return weapon.is_valid() && get_size() == weapon->get_size();
}
double TurretMountData::get_min_angle() {
   return min_angle;
}
double TurretMountData::get_max_angle() {
   return max_angle;
}
int TurretMountData::get_firing_arc_degrees() {
   return firing_arc_degrees;
}
int TurretMountData::get_angle_degrees() {
   return angle_degrees;
}
void TurretMountData::set_firing_arc_degrees(int new_firing_arc_degrees) {
   firing_arc_degrees = new_firing_arc_degrees;
   calculate_min_max();
}
void TurretMountData::set_angle_degrees(int new_angle_degrees) {
   angle_degrees = new_angle_degrees;
   calculate_min_max();
}
void TurretMountData::calculate_min_max() {
   double angle = Math::deg_to_rad(static_cast<float>(angle_degrees));
   double arc   = Math::deg_to_rad(static_cast<float>(firing_arc_degrees));
   min_angle = angle - 0.5 * arc;
   max_angle = angle + 0.5 * arc;
}


Ref<PartData> PartData::create_correct_subtype(String subtype) {
   if (subtype == "weapon")
      return memnew(WeaponData);
   if (subtype == "turret_mount")
      return memnew(TurretMountData);
   if (subtype == "projectile")
      return memnew(ProjectileData);
   if (subtype != "")
      WARN_PRINT_ED("Part subtype '" + subtype + "' not recognized");
   return memnew(PartData);
}