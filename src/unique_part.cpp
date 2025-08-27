#include "unique_part.hpp"
#include "ship.hpp"

using namespace godot;

Part* WeaponData::new_blank_part() {
   return memnew(Weapon);
}


bool Weapon::can_fire_at(Ref<Target> target) const {
   Vector2 position = get_global_position();
   double projectile_speed;
   double projectile_lifetime;
   Target::Prediction prediction = target->predict_lazy_from(position, projectile_speed);
   return prediction.time_to_intersect <= projectile_lifetime;
}
bool Weapon::can_turn_to(double angle) const {
   return false;
}
void Weapon::fire() {

}
Part::InitStatus Weapon::_ship_init(const Ship &parent_ship, int part_id) {
   Ref<ShipData> ship = parent_ship.get_data();
   int mount_id = ship->get_part_at( ship->get_part_center(part_id) );
   Ref<WeaponMountData> mount_underneath = ship->get_part_data(mount_id);

   if (mount_underneath.is_null()) return FAILURE_NO_MOUNT;

   mount = mount_underneath;
   modifiers.combine( mount->get_modifiers() );

   for (int id: ship->find_neighbors(mount_id, ShipData::FULL_PERIMETER) ) {
      modshare( ship->get_part_data(id) );
   }
   return OKAY_KEEP_PART;
}
void Weapon::modshare(Ref<WeaponModifierData> modifier) {
   /*------------------------------------------------------|
   | Modifiers are applied based on the number of grid     |
   | squares, not number of parts. This means diagonally   |
   | placed mods are less effective.                       |
   |------------------------------------------------------*/
   if (modifier.is_valid()) modifiers.combine( modifier->get_modifiers() );
}