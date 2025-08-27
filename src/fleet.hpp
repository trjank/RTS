#ifndef FLEET_HPP
#define FLEET_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/dir_access.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "ship_data.hpp"

namespace godot {

class Fleet: public RefCounted {
   GDCLASS(Fleet, RefCounted)
public:
   enum ShipType: int {CAPITAL_SHIP, SHIP, TURRET, NUM_SHIP_TYPES};
   static constexpr int MIN_NAME_LENGTH = 1;
   Fleet();
   int get_num_slots(ShipType type);
   Ref<ShipData> get_slot(ShipType type, int slot);
   String get_name();
   void set_num_slots(ShipType type, int new_num_slots);
   void set_slot(ShipType type, int slot, Ref<ShipData> new_ship);
   void set_name(String new_name);
   void resize();
protected:
   static void _bind_methods();
private:
   String name = "Starter Fleet";
   Vector<Vector<Ref<ShipData>>> slots;
};

class FleetManager: public ShipManager {
   GDCLASS(FleetManager, ShipManager)
public:
   bool fleet_exists(String fleet_name);
   void set_fleet_folder(String user_path = "user://fleets");
   void save_fleet(Ref<Fleet> fleet);
   void save_fleet_type(Ref<Fleet> fleet, Fleet::ShipType type);
   void save_fleet_slot(Ref<Fleet> fleet, Fleet::ShipType type, int slot);
   Ref<Fleet> load_fleet(String name);
   void load_fleet_type(Ref<Fleet> fleet, Fleet::ShipType type);
   void load_fleet_slot(Ref<Fleet> fleet, Fleet::ShipType type, int slot);
   Error delete_fleet(Ref<Fleet> fleet);
   void delete_fleet_type(Ref<Fleet> fleet, Fleet::ShipType type);
   void delete_fleet_slot(Ref<Fleet> fleet, Fleet::ShipType type, int slot);
protected:
   static void _bind_methods();
private:
   Ref<DirAccess> fleet_folder;

   String get_ship_local_path(Ref<Fleet> fleet, Fleet::ShipType type, int slot);
};

}

VARIANT_ENUM_CAST(Fleet::ShipType);

#endif // FLEET_HPP