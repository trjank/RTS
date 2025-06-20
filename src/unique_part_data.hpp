#ifndef UNIQUE_PART_DATA_HPP
#define UNIQUE_PART_DATA_HPP

#include "part_data.hpp"

#define SHOW_PROJECTILES_IN_DESIGN_MODE false

namespace godot {

class ProjectileData: public PartData {
   GDCLASS(ProjectileData, PartData)
public:
   Part* new_part() override;
   bool exposed_to_design_mode() override;
   void load_unique(Dictionary data) override;
   bool is_hitscan();
   Vector2 get_hitbox_size();
   void set_hitscan(bool make_hitscan);
   void set_hitbox_size(Vector2 new_hitbox_size);
private:
   bool hitscan = false;
   Vector2 hitbox_size = {1.0F, 1.0F};
};

class WeaponData: public PartData {
   GDCLASS(WeaponData, PartData)
public:
   static constexpr double MIN_SEC_BETWEEN_SHOTS = 0.1;
   static constexpr double MIN_RELOAD_SEC = 0.1;
   bool flatten_with_ship() override;
   void load_unique(Dictionary data) override;
   Part* new_part() override;
   int get_shots_per_burst();
   double get_energy_per_shot();
   double get_firerate();
   double get_burst_firerate();
   double get_base_range();
   double get_spread_angle();
   double get_sec_between_shots();
   double get_reload_sec();
   void set_shots_per_burst(int new_shots_per_burst);
   void set_energy_per_shot(double new_energy_per_shot);
   void set_base_range(double new_base_range);
   void set_spread_angle(double new_spread_angle);
   double set_sec_between_shots(double new_sec_between_shots);
   double set_reload_sec(double new_reload_sec);
protected:
   static void _bind_methods();
private:
   int shots_per_burst = 1;
   double energy_per_shot = 0.0;
   double firerate = 1.0;
   double burst_firerate = 1.0;
   double base_range = 0.0;
   double spread_angle = 0.0;
   double sec_between_shots = 0.0;
   double reload_sec = 1.0;
   Ref<ProjectileData> projectile;

   void calculate_firerates();
};

class TurretMountData: public PartData {
   GDCLASS(TurretMountData, PartData)
public:
   void load_unique(Dictionary data) override;
   Part* new_part() override;
   bool is_compatible_with(Ref<WeaponData> weapon);
   double get_min_angle();
   double get_max_angle();
   int get_firing_arc_degrees();
   int get_angle_degrees();
   void set_firing_arc_degrees(int new_firing_arc_degrees);
   void set_angle_degrees(int new_angle_degrees);
protected:
   static void _bind_methods();
private:
   int firing_arc_degrees = 0;
   int angle_degrees = 0;
   double min_angle = 0.0;
   double max_angle = 0.0;

   void calculate_min_max();
};

}

#endif // UNIQUE_PART_DATA_HPP