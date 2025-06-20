#include "unique_part.hpp"

using namespace godot;

Part* WeaponData::new_part() {
   return memnew(Weapon);
}
Part* TurretMountData::new_part() {
   return memnew(TurretMount);
}


void Weapon::set_data(Ref<PartData> new_data) {
   Ref<WeaponData> weapon_cast = new_data;

   ERR_FAIL_COND_MSG(weapon_cast.is_null(), "Weapon requires type WeaponData");

   Part::set_data(new_data);
   weapon_data = weapon_cast;
}


const Weapon* TurretMount::get_weapon() {
   return weapon;
}
const Weapon* TurretMount::new_weapon(Ref<WeaponData> weapon_type) {
   if (weapon) weapon->queue_free();
   add_child(weapon = memnew(Weapon));
   weapon->set_data(weapon_type);
   return weapon;
}
void TurretMount::set_data(Ref<PartData> new_data) {
   Ref<TurretMountData> mount_cast = new_data;

   ERR_FAIL_COND_MSG(mount_cast.is_null(), "TurretMount requires type TurretMountData");

   Part::set_data(new_data);
   mount_data = mount_cast;
}