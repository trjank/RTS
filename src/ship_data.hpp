#ifndef SHIP_DATA_HPP
#define SHIP_DATA_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/variant/packed_string_array.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include "part_data.hpp"
#include "part.hpp"
#include "disjoint_sets.hpp"
#include "packed_int32_grid.hpp"

namespace godot {

constexpr int NUM_NULL_PARTS = 1;
constexpr int NULL_PART_ID = 0;

class ShipData: public RefCounted {
   GDCLASS(ShipData, RefCounted)
public:
   enum State { EMPTY, VALID, PARTS_DISCONNECTED, PART_OVERLAP };
   enum RotationState: int {
      ROT_0_DEG = 0,
      ROT_90_DEG = 1,
      ROT_180_DEG = 2,
      ROT_270_DEG = 3,
      FLIPPED_ROT_0_DEG = 4,
      FLIPPED_ROT_90_DEG = 5,
      FLIPPED_ROT_180_DEG = 6,
      FLIPPED_ROT_270_DEG = 7
   };
   static constexpr int MAX_NAME_LENGTH = 30;
   int count_parts();
   State get_state();
   int get_cost();
   Vector2i get_size();
   Vector2i get_size_px();
   float get_max_warp();
   float get_max_hp();
   float get_max_shield();
   float get_max_energy();
   const PackedByteArray get_index_buffer();
   const PackedByteArray get_rotation_buffer();
   const PackedByteArray get_position_buffer();
   void clear_all_data();
   void assemble_from(Vector<Part*>);
protected:
   static void _bind_methods();
private:
   State state = EMPTY;
   int cost = 0;
   float mass = 0.0;
   float warp_per_sec = 0.0;
   float shield_per_sec = 0.0;
   float max_warp = 0.0;
   float max_hp = 0.0;
   float max_shield = 0.0;
   float max_energy = 0.0;
   Vector2 mass_offset;
   Vector2 center_of_mass;
   String name = "<unnamed>";
   Vector<Part*> turrets;
   PackedInt32Grid index_grid;
   PackedInt32Array rotation_states;
   PackedVector2Array centers;
   PackedStringArray codes;
   DisjointSets part_clusters;
   String get_part_code(int part_id);
   void check_for_adjacent_part(int part_id, Vector2i xy);
   void check_for_adjacent_parts(int part_id, Rect2i rect);
   void update_adjacency_stats(int receiving_part, int giving_part);
   void add_part_to_grid(Ref<PartData> part, Vector2 center, RotationState rotation_state);
   void add_part_to_grid(Part* part);
   RotationState encode_rotation(double radians, bool flipped);
   friend class ShipManager;
};

class ShipManager: public RefCounted {
   GDCLASS(ShipManager, RefCounted)
public:
   static constexpr int MAX_NUM_HOTBAR_SLOTS = 10;
   static constexpr int MAX_NUM_TURRET_SLOTS = 3;
   const PackedStringArray CSV_COLUMNS = {
      "code", "x", "y", "rotation_state"
   };
   ShipManager();
   Ref<PartManager> get_part_manager();
   int get_num_hotbar_slots();
   int get_num_turret_slots();
   Ref<ShipData> get_capital_ship();
   Ref<ShipData> get_hotbar_slot(int slot);
   Ref<ShipData> get_turret_slot(int slot);
   void set_num_hotbar_slots(int slots);
   void set_num_turret_slots(int slots);
   void set_capital_ship(Ref<ShipData> ship);
   void set_hotbar_slot(int slot, Ref<ShipData> ship);
   void set_turret_slot(int slot, Ref<ShipData> turret);
   void save_ship(Ref<ShipData> ship, String path);
   Ref<ShipData> load_ship(String csv_path);
protected:
   static void _bind_methods();
private:
   Ref<PartManager> part_manager;
   Ref<ShipData> capital_ship = nullptr;
   Vector<Ref<ShipData>> hotbar;
   Vector<Ref<ShipData>> turrets;
   void load_part_into_ship(Ref<ShipData> ship, PackedStringArray csv_line);
   PackedStringArray to_csv_line(Ref<ShipData> ship, int part_id);
};

}

#endif // SHIP_DATA_HPP