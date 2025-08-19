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
   enum Detection: int {UNIFIED = 1, BALANCED = 4, INDEPENDENT = 16};

   /*------------------------------------------------------|
   | Grid padding serves two purposes:                     |
   |                                                       |
   | 1. We can avoid error handling at the grid boundary,  |
   |    which simplifies searches for neighboring parts.   |
   | 2. We can use outline shaders on the padded image,    |
   |    since the borders are guaranteed to be empty.      |
   |------------------------------------------------------*/
   static constexpr int GRID_PADDING = 1;
   static constexpr int NUM_NULL_PARTS = 1;
   static constexpr int NULL_PART_ID = 0;
   static constexpr int MAX_NAME_LENGTH = 30;

   static Ref<ShipData> create(int grid_width = 0, int grid_height = 0);
   static RotationState encode_rotation(double radians, bool flipped);

   ShipData();
   int count_parts() const;
   bool is_empty() const;
   bool is_connected() const;
   bool has_part(int part_id) const;
   Rect2i get_grid_region() const;
   Rect2i get_ship_region() const;
   Rect2i get_rect() const;
   int get_cost() const;
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
   Ref<ImageTexture> get_texture() const;
   PackedInt32Array get_unique_parts();
   int get_part_at(Vector2i location) const;
   RotationState get_part_rotation_state(int part_id) const;
   Ref<PartData> get_part_data(int part_id) const;
   Vector2 get_part_center(int part_id) const;
   Rect2i get_part_region(int part_id) const;
   void set_image(Ref<Image> new_image);
   PartError add_part(Ref<PartData> part, Vector2 center, RotationState rotation_state);
   PartError add_part_node(Part* part);
   NO_ERROR_CHECK PackedInt32Array find_neighbors(int part_id, int boundary_flags = FULL_PERIMETER) const;
protected:
   static void _bind_methods();
private:
   Detection default_detection = BALANCED;
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
   Vector2 mass_offset = {0.0, 0.0};
   Vector2 center_of_mass = {0.0, 0.0};
   String name = "<unnamed>";
   NEVER_NULL Ref<Image> image = get_default<Image>();
   Vector<Ref<PartData>> parts = {nullptr};
   PackedInt32Array unique_parts;
   Vector<Rect2i> part_regions = { {0, 0, 0, 0} };
   Vector<Vector2> part_centers = { {0.0, 0.0} };
   Vector<RotationState> part_rotation_states = {ROT_0_DEG};
   Rect2i grid_region = {0, 0, 0, 0};
   Rect2i ship_region = {0, 0, 0, 0};
   /*------------------------------------------------------|
   | PackedInt32Grid and DisjointSets are both custom data |
   | structures. See their respective header files for     |
   | more information.                                     |
   |------------------------------------------------------*/
   PackedInt32Grid grid;
   DisjointSets part_clusters;

   void add_stats(Ref<PartData> part);
   void place_on_grid(int part_id, Rect2i rect);
   Vector2i transform_size(Vector2i size, RotationState rotation_state);
   NO_ERROR_CHECK void draw_part(Ref<Image> image, Rect2i rect, RotationState rotation_state);

   friend class ShipManager;
};

class ShipManager: public RefCounted {
   GDCLASS(ShipManager, RefCounted)
public:
   enum PropertyOrder: int {CODE, X, Y, ROTATION_STATE, NUM_PROPERTIES};
   const PackedStringArray CSV_HEADER = {"code", "x", "y", "rotation_state"};
   static constexpr int NULL_PART_ATLAS_ID = 0;

   ShipManager();
   void set_part_manager(Ref<PartManager> new_part_manager);
   void save_ship_image(Ref<ShipData> ship, String path);
   void save_ship_csv(Ref<ShipData> ship, String path);
   String save_ship_string(Ref<ShipData>ship);
   Ref<ImageTexture> load_ship_image(String path);
   Ref<ShipData> load_ship_csv(int width, int height, String path);
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
VARIANT_ENUM_CAST(ShipData::Detection);

#endif // SHIP_DATA_HPP