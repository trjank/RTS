#include "fleet.hpp"

Ref<Ship::Data> Fleet::get_ship(int slot) {
   // ERR_FAIL_COND_MSG(slot < 0 || FLEET_SIZE <= slot,
   //                   "(Player::get_ship) 'slot' is out of range");
   return ships[slot];
}