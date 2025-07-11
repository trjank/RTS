#ifndef UNIQUE_PART_DATA_HPP
#define UNIQUE_PART_DATA_HPP

#include "part_data.hpp"
#include "ship_data.hpp"
#include "defaults.hpp"

namespace godot {

class ProjectileData: public PartData {
   GDCLASS(ProjectileData, PartData)
public:
   void load_unique_data(Dictionary data) override;
   bool is_hitscan();
   Vector2 get_hitbox_size();
   void set_hitscan(bool make_hitscan);
   void set_hitbox_size(Vector2 new_hitbox_size);
protected:
   static void _bind_methods();
private:
   bool hitscan = false;
   Vector2 hitbox_size = {1.0F, 1.0F};
};


struct WeaponModifiers {
   double multiplier_range = 1.0;
   double multiplier_energy = 1.0;
   double multiplier_speed = 1.0;
   double multiplier_cooldown = 1.0;

   void combine(const WeaponModifiers& other_modifiers);
};


class WeaponModifierData: public PartData {
   GDCLASS(WeaponModifierData, PartData)
public:
   void load_unique_data(Dictionary data) override;
   double get_multiplier_range() const;
   double get_multiplier_energy() const;
   double get_multiplier_speed() const;
   double get_multiplier_cooldown() const;
   void set_multiplier_range(double new_multiplier_range);
   void set_multiplier_energy(double new_multiplier_energy);
   void set_multiplier_speed(double new_multiplier_speed);
   void set_multiplier_cooldown(double new_multiplier_cooldown);
protected:
   static void _bind_methods();
private:
   WeaponModifiers modifiers;
};


class WeaponData: public PartData {
   GDCLASS(WeaponData, PartData)
public:
   static constexpr double MIN_SEC_BETWEEN_SHOTS = 0.1;
   static constexpr double MIN_RELOAD_SEC = 0.1;

   WeaponData();
   void load_unique_data(Dictionary data) override;
   bool is_burst_weapon();
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
   void set_sec_between_shots(double new_sec_between_shots);
   void set_reload_sec(double new_reload_sec);
   // See unique_part_data.cpp for the new_blank_part function definition
   Part* new_blank_part() override;
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
   NEVER_NULL Ref<ProjectileData> projectile = get_default<ProjectileData>();

   void calculate_firerates();
};


class WeaponMountData: public WeaponModifierData {
   GDCLASS(WeaponMountData, WeaponModifierData)
public:
   bool is_compatible_with(Ref<WeaponData> weapon);
   ShipData::BoundaryFlag get_mod_boundary(ShipData::RotationState _rotation);
   double get_min_angle();
   double get_max_angle();
   int get_firing_arc_degrees();
   int get_angle_degrees();
   void set_firing_arc_degrees(double new_firing_arc_degrees);
   void set_angle_degrees(double new_angle_degrees);
   void load_unique_data(Dictionary data) override;
protected:
   static void _bind_methods();
private:
   double firing_arc_degrees = 0;
   double angle_degrees = 0;
   double min_angle = 0.0;
   double max_angle = 0.0;

   void calculate_min_max();
};

}

#endif // UNIQUE_PART_DATA_HPP