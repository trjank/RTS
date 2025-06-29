#include "unique_part.hpp"
#include "ship.hpp"

using namespace godot;

Part* WeaponData::new_part() {
   return memnew(Weapon);
}


void Weapon::set_data(Ref<PartData> new_data) {
   Ref<WeaponData> weapon_cast = new_data;

   ERR_FAIL_NULL_MSG(weapon_cast,
      "<Weapon> Part data is not type WeaponData (failed to set data)");

   Part::set_data(new_data);
   weapon_data = weapon_cast;
}
void Weapon::_ship_init(const Ship& parent_ship, int part_id) {
   // for (int id: parent_ship.get_data()->find_neighbors(part_id)) {
   //    // calculate weapon adjacencies
   // }
}