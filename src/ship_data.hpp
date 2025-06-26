#ifndef SHIP_DATA_HPP
#define SHIP_DATA_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/variant/packed_string_array.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include <godot_cpp/classes/time.hpp>
#include "part_data.hpp"
#include "part.hpp"
#include "disjoint_sets.hpp"
#include "packed_int32_grid.hpp"

#define CPU_IMAGE_GENERATION true
#define CHECK_FOR_PART_OVERLAP true

namespace godot {

class ShipData: public RefCounted {
   GDCLASS(ShipData, RefCounted)
public:
   enum PartError {OKAY, OVERLAP, OUT_OF_BOUNDS, IS_NULL};
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
   static constexpr int NUM_NULL_PARTS = 1;
   static constexpr int NULL_PART_ID = 0;
   static constexpr int MAX_NAME_LENGTH = 30;
   static constexpr int NUM_ROTATION_INCREMENTS = 4;
   static constexpr double PI_2 = 0.5 * Math_PI;

   static Vector2i get_grid_padding();
   static Ref<ShipData> assemble(Vector2i grid_size, TypedArray<Node> parts);

   int count_parts();
   bool is_empty();
   bool is_connected();
   PartError get_error();
   int get_cost();
   Vector2i get_size();
   Vector2i get_size_px();
   double get_max_warp();
   double get_max_hp();
   double get_max_shield();
   double get_max_energy();
   double get_warp_per_sec();
   double get_shield_per_sec();
   double get_energy_per_sec();
   double get_thrust();
   double get_turnrate();
   Vector2 get_ship_bounds_x();
   Vector2 get_ship_bounds_y();
   Vector2 get_center_of_mass();
   Ref<PartData> get_part_data(int part_id);
   Ref<Image> get_image();
   void set_image(Ref<Image> new_image);
   bool has_part(int part_id);
   int add_part(Ref<PartData> part, Vector2 center, RotationState rotation_state);
   int add_part_node(Part* part);
   Ref<PartData> collision_check(Vector2 point);
   PackedInt32Array find_neighbors(int part_id, PartData::BoundaryFlag flags);
protected:
   static void _bind_methods();
private:
   PartError error;
   int cost = 0;
   double mass = 0.0;
   double warp_per_sec = 0.0;
   double shield_per_sec = 0.0;
   double energy_per_sec = 0.0;
   double max_hp = 0.0;
   double max_warp = 0.0;
   double max_shield = 0.0;
   double max_energy = 0.0;
   double thrust = 0.0;
   double turnrate = 0.0;
   Vector2 mass_offset = {0.0f, 0.0f};
   Vector2 ship_bounds_x = {-100000.0f,100000.0f};
   Vector2 ship_bounds_y = {-100000.0f,100000.0f};
   String name = "<unnamed>";
   Ref<Image> image;
   Vector<Ref<PartData>> parts = {nullptr};
   Vector<Rect2i> part_regions = {{0, 0, 0, 0}};
   PackedVector2Array part_centers = {{0.0f, 0.0f}};
   PackedInt32Array rotation_states = {ROT_0_DEG};
   Rect2i grid_region = {0, 0, 0, 0};
   /*------------------------------------------------------*
   | PackedInt32Grid and DisjointSets are both custom data |
   | structures. PackedInt32Grid allows for fast lookup to |
   | parts while maintaining compatibility with compute    |
   | shaders. DisjointSets can quickly determine if the    |
   | parts are connected.                                  |
   *------------------------------------------------------*/
   PackedInt32Grid grid;
   DisjointSets part_clusters;
   void set_bounds(Vector2 bounds);
   void add_stats(Ref<PartData> part, Vector2 center);
   RotationState encode_rotation(double radians, bool flipped);

   friend class ShipManager;
};

class ShipManager: public RefCounted {
   GDCLASS(ShipManager, RefCounted)
public:
   enum PropertyOrder: int {CODE, X, Y, ROTATION_STATE, NUM_PROPERTIES};
   const PackedStringArray CSV_HEADER = {"code", "x", "y", "rotation_state"};
   static constexpr int NULL_PART_ATLAS_ID = 0;

   ShipManager();
   void save_ship_image(Ref<ShipData> ship, String path);
   void save_ship_csv(Ref<ShipData> ship, String path);
   Ref<ImageTexture> load_ship_image(String path);
   Ref<ShipData> load_ship_csv(String path);
protected:
   static void _bind_methods();
private:
   Ref<PartManager> part_manager;

   void load_part_into_ship(Ref<ShipData> ship, PackedStringArray csv_line);
   PackedStringArray to_csv_line(Ref<ShipData> ship, int part_id);
};

}

VARIANT_ENUM_CAST(ShipData::PartError);
VARIANT_ENUM_CAST(ShipData::RotationState);

#endif // SHIP_DATA_HPP