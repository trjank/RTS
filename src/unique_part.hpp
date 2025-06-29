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
   void turn_to(int target);
   void fire();
   void _ship_init(const Ship& parent_ship, int part_id) override;
protected:
   static void _bind_methods();
private:
   NEVER_NULL Ref<TurretMountData> firing_restrictions = get_default<TurretMountData>();
   NEVER_NULL Ref<WeaponData> weapon_data = get_default<WeaponData>();
};

}

#endif // UNIQUE_PART_HPP