#ifndef UNIQUE_PART_HPP
#define UNIQUE_PART_HPP

#include "part.hpp"
#include "unique_part_data.hpp"
#include "projectile.hpp"

namespace godot {

class Weapon: public Part {
   GDCLASS(Weapon, Part)
public:
   void set_data(Ref<PartData> new_data) override;
   void fire();
protected:
   static void _bind_methods();
private:
   Ref<WeaponData> weapon_data = get_default<WeaponData>();
};

class TurretMount: public Part {
   GDCLASS(TurretMount, Part)
public:
   const Weapon* get_weapon();
   const Weapon* new_weapon(Ref<WeaponData> weapon_type);
   void set_data(Ref<PartData> new_data) override;
   void turn_to();
   void fire();
protected:
   static void _bind_methods();
private:
   Weapon* weapon = nullptr;
   Ref<TurretMountData> mount_data = get_default<TurretMountData>();
};

}

#endif // UNIQUE_PART_HPP