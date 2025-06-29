#include "fleet.hpp"
using namespace godot;

Fleet::Fleet() {
  
   UtilityFunctions::print("something happening");
   slots.resize(NUM_SHIP_TYPES);
   Vector<Ref<ShipData>> ships;
   Vector<Ref<ShipData>> capships;
   Vector<Ref<ShipData>> turrets;

   slots.set(CAPITAL_SHIP, Vector<Ref<ShipData>>());
   slots.set(SHIP, Vector<Ref<ShipData>>());
   slots.set(TURRET, Vector<Ref<ShipData>>());
   UtilityFunctions::print(slots.size());
   set_num_slots(CAPITAL_SHIP, 1);
   set_num_slots(SHIP, 5);
   set_num_slots(TURRET, 5); 
   UtilityFunctions::print("something happened");
}
int Fleet::get_num_slots(ShipType type) {
   return slots.get(type).size();
}
Ref<ShipData> Fleet::get_slot(ShipType type, int slot) {

   return slots.get(type).get(slot);
}
String Fleet::get_name() {
   return name;
}
void Fleet::set_num_slots(ShipType type, int new_num_slots) {
   Vector<Ref<ShipData>> temp = slots.get(type);
   temp.resize(new_num_slots);
   slots.set(type,temp);

}
void Fleet::set_slot(ShipType type, int slot, Ref<ShipData> new_ship) {
    UtilityFunctions::print("setting slot..");
    UtilityFunctions::print(slots.size());

   Vector<Ref<ShipData>> temp = slots.get(type);
   temp.set(slot, new_ship);
   slots.set(type, temp);
   UtilityFunctions::print(slots.get(type).size());
}
void Fleet::set_name(String new_name) {
   ERR_FAIL_COND_MSG(new_name.length() < MIN_NAME_LENGTH,
      "<Fleet> Fleet name is too short!");

   name = new_name;
}

void Fleet::resize(){
   slots.resize(3);
}


void FleetManager::set_fleet_folder(String user_path) {
   UtilityFunctions::print("<FleetManager> Setting fleet directory to '" + user_path + "'");

   /*------------------------------------------------------*
   | Fleets are deleted when their directories are         |
   | deleted. We need to ensure that any deletion is       |
   | safely contained within the user:// folder, as we     |
   | don't want to accidentally delete personal files.     |
   *------------------------------------------------------*/
   ERR_FAIL_COND_MSG( !user_path.begins_with("user://"),
      "<FleetManager> Fleet folder must be in user://");
   ERR_FAIL_COND_MSG(user_path.contains(".."),
      "<FleetManager> Remove /../ from fleet folder path");

   fleet_folder = DirAccess::open(user_path);
}
bool FleetManager::fleet_exists(String fleet_name) {
   return fleet_folder.is_valid() && fleet_folder->dir_exists(fleet_name);
}


String FleetManager::get_ship_local_path(Ref<Fleet> fleet, Fleet::ShipType type, int slot) {
   return String::num_int64(type) + "_" + String::num_int64(slot) + "_" + fleet->get_name();
}
void FleetManager::save_fleet(Ref<Fleet> fleet) {
   String fleet_name = fleet->get_name();
   
   if(!fleet_exists(fleet_name)){
   fleet_folder->make_dir(fleet_name);
   }
   
   save_fleet_type(fleet, Fleet::ShipType::CAPITAL_SHIP);
   save_fleet_type(fleet, Fleet::ShipType::SHIP);
   save_fleet_type(fleet, Fleet::ShipType::TURRET);
}


void FleetManager::save_fleet_type(Ref<Fleet> fleet, Fleet::ShipType type) {
   for (int slot = 0; slot < fleet->get_num_slots(type); ++slot) {
      save_fleet_slot(fleet, type, slot);
   }
}
void FleetManager::save_fleet_slot(Ref<Fleet> fleet, Fleet::ShipType type, int slot) {
   String path = fleet_folder->get_current_dir(true)+"/"+fleet->get_name()+"/"+get_ship_local_path(fleet, type, slot);
   Ref<ShipData> ship = fleet->get_slot(type, slot);

   UtilityFunctions::print("<FleetManager>: Saving to '"+path);
   save_ship_image(ship, path+".png");
   save_ship_csv(ship, path+".csv");
}
Ref<Fleet> FleetManager::load_fleet(String name) {
   if ( !fleet_exists(name)) return nullptr;

   Ref<Fleet> fleet = memnew(Fleet);
   fleet->set_name(name);
   load_fleet_type(fleet, Fleet::ShipType::CAPITAL_SHIP);
   load_fleet_type(fleet, Fleet::ShipType::SHIP);
   load_fleet_type(fleet, Fleet::ShipType::TURRET);
   return fleet;
}
void FleetManager::load_fleet_type(Ref<Fleet> fleet, Fleet::ShipType type) {
   for (int slot = 0; slot < fleet->get_num_slots(type); ++slot) {
      load_fleet_slot(fleet, type, slot);
   }
}
void FleetManager::load_fleet_slot(Ref<Fleet> fleet, Fleet::ShipType type, int slot) {
   String path = get_ship_local_path(fleet, type, slot);
   Ref<ShipData> ship = load_ship_csv(path + ".csv");
   // ship->set_texture_path(path + ".png");
   fleet->set_slot(type, slot, ship);
}

Error FleetManager::delete_fleet(Ref<Fleet> fleet) {
   if (fleet.is_null()) return Error::FAILED;

   delete_fleet_type(fleet, Fleet::ShipType::CAPITAL_SHIP);
   delete_fleet_type(fleet, Fleet::ShipType::SHIP);
   delete_fleet_type(fleet, Fleet::ShipType::TURRET);

   /*------------------------------------------------------*
   | DirAccess will only delete directories that are       |
   | completely empty. If there are files other than the   |
   | ones necessary to store the fleet, the fleet may      |
   | remain.                                               |
   *------------------------------------------------------*/
   return fleet_folder->remove(fleet->get_name());
}
void FleetManager::delete_fleet_type(Ref<Fleet> fleet, Fleet::ShipType type) {
   for (int slot = 0; slot < fleet->get_num_slots(type); ++slot) {
      delete_fleet_slot(fleet, type, slot);
   }
}
void FleetManager::delete_fleet_slot(Ref<Fleet> fleet, Fleet::ShipType type, int slot) {
   String path = get_ship_local_path(fleet, type, slot);
   fleet_folder->remove(path + ".csv");
   fleet_folder->remove(path + ".png");
}