#include "unique_part.hpp"
#include "ship.hpp"

using namespace godot;

Part* WeaponData::new_blank_part() {
   return memnew(Weapon);
}


void Weapon::turn_to(double new_angle) {

}
void Weapon::fire() {

}
void Weapon::_ship_init(const Ship& parent_ship, int part_id) {
   Ref<ShipData> ship = parent_ship.get_data();
   int mount_id = ship->get_part_at( ship->get_part_center(part_id) );
   Ref<WeaponMountData> mount_underneath = ship->get_part_data(mount_id);

   ERR_FAIL_NULL_MSG(mount_underneath,
   "<Weapon> Weapon has no mount!");

   mount = mount_underneath;
   ShipData::RotationState rotation = ship->get_part_rotation_state(mount_id);
   for (int id: ship->find_neighbors(mount_id, mount->get_mod_boundary(rotation) ) ) {
      Ref<WeaponModifierData> mod = ship->get_part_data(id);
      // if (mod.is_valid()) modifiers.combine(mod->modifiers);
   }
}