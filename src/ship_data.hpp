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

namespace godot {

class ShipData: public RefCounted {
   GDCLASS(ShipData, RefCounted)
public:
   enum BoundaryFlag: int {
      EDGE_TOP = 1,
      EDGE_BOTTOM = 2,
      EDGE_LEFT = 4,
      EDGE_RIGHT = 8,
      EDGES_TOP_BOTTOM = EDGE_TOP | EDGE_BOTTOM,
      EDGES_LEFT_RIGHT = EDGE_LEFT | EDGE_RIGHT,
      FULL_PERIMETER = EDGE_TOP | EDGE_BOTTOM | EDGE_LEFT | EDGE_RIGHT
   };
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
   enum PartError {OKAY, OVERLAP, OUT_OF_BOUNDS, IS_NULL};

   static constexpr int NUM_NULL_PARTS = 1;
   static constexpr int NULL_PART_ID = 0;
   static constexpr int MAX_NAME_LENGTH = 30;

   static Vector2i get_grid_padding();
   static Ref<ShipData> assemble(Vector2i grid_size, TypedArray<Node> parts);

   ShipData();
   int count_parts() const;
   bool is_empty() const;
   bool is_connected() const;
   bool has_part(int part_id) const;
   int get_cost() const;
   Vector2i get_size() const;
   Vector2i get_size_px() const;
   double get_max_warp() const;
   double get_max_hp() const;
   double get_max_shield() const;
   double get_max_energy() const;
   double get_warp_per_sec() const;
   double get_shield_per_sec() const;
   double get_energy_per_sec() const;
   double get_thrust() const;
   double get_turnrate() const;
   Vector2 get_center_of_mass() const;
   Ref<Image> get_image() const;
   PackedInt32Array get_unique_parts();
   int get_part_at(Vector2 location) const;
   RotationState get_part_rotation_state(int part_id) const;
   Ref<PartData> get_part_data(int part_id) const;
   Vector2 get_part_center(int part_id) const;
   Vector2 get_part_center_px(int part_id) const;
   Rect2i get_part_region(int part_id) const;
   void set_image(Ref<Image> new_image);
   PartError add_part(Ref<PartData> part, Vector2 center, RotationState rotation_state);
   PartError add_part_node(Part* part);
   PackedInt32Array find_neighbors(int part_id, int boundary_flags) const;
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
   String name = "<unnamed>";
   Ref<Image> image;
   Vector<Ref<PartData>> parts;
   PackedInt32Array unique_parts;
   Vector<Rect2i> part_regions;
   Vector<Vector2> part_centers;
   Vector<RotationState> part_rotation_states;
   Rect2i grid_region;
   /*------------------------------------------------------|
   | PackedInt32Grid and DisjointSets are both custom data |
   | structures. See their respective header files for     |
   | more information.                                     |
   |------------------------------------------------------*/
   PackedInt32Grid grid;
   DisjointSets part_clusters;

   void add_stats(Ref<PartData> part, Vector2 center);
   Vector2i get_grid_size(Vector2i size, RotationState rotation_state);
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

VARIANT_ENUM_CAST(ShipData::BoundaryFlag);
VARIANT_ENUM_CAST(ShipData::RotationState);
VARIANT_ENUM_CAST(ShipData::PartError);

#endif // SHIP_DATA_HPP