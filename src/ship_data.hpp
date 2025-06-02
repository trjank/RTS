#ifndef SHIP_DATA_HPP
#define SHIP_DATA_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/packed_string_array.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include "part_data.hpp"
#include "part.hpp"

namespace godot {

class ShipData: public RefCounted {
   GDCLASS(ShipData, RefCounted)
public:
   static constexpr int MAX_NAME_LENGTH = 30;
   enum State { OKAY, MISSING_DATA, PART_OVERLAP };
   // static inline String CSV_COLUMNS = "ID,x,y";

   static Ref<ShipData> load(String csv_path);

   void save(String csv_path);
   State get_state();
   int get_cost();
   float get_max_warp();
   float get_max_HP();
   float get_max_shield();
   float get_max_energy();
protected:
   static void _bind_methods();
private:
   State state = OKAY;
   int cost = 0;
   float max_warp = 0.0;
   float max_HP = 0.0;
   float max_shield = 0.0;
   float max_energy = 0.0;
   String name = "";
   const Vector<Part*> parts;
   static PackedStringArray to_csv_line(Part* part);
};

}

class ShipManager;

#endif // SHIP_DATA_HPP