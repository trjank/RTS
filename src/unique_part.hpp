#ifndef UNIQUE_PART_HPP
#define UNIQUE_PART_HPP

#include <godot_cpp/variant/color.hpp>
#include "part.hpp"
#include "unique_part_data.hpp"
#include "projectile.hpp"

namespace godot {

class Weapon: public Part {
   GDCLASS(Weapon, Part)
public:
   void turn_to(double new_angle);
   void fire();
   void _ship_init(const Ship& parent_ship, int part_id) override;
protected:
   static void _bind_methods();
private:
   WeaponModifiers modifiers;
   NEVER_NULL Ref<WeaponMountData> mount = get_default<WeaponMountData>();
   NEVER_NULL Ref<WeaponData> weapon_data = get_default<WeaponData>();
};

}

#endif // UNIQUE_PART_HPP