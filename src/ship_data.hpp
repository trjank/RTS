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
#include <godot_cpp/classes/bit_map.hpp>
#include <godot_cpp/core/math.hpp>
#include "part_data.hpp"
#include "part.hpp"
#include "disjoint_sets.hpp"
#include "grid.hpp"

namespace godot {

class ShipData: public RefCounted {
   GDCLASS(ShipData, RefCounted)
public:
   enum BoundaryFlag: int {
      EDGE_RIGHT     = 1 << 0,
      EDGE_TOP       = 1 << 1,
      EDGE_LEFT      = 1 << 2,
      EDGE_BOTTOM    = 1 << 3,
      FULL_PERIMETER = EDGE_RIGHT | EDGE_TOP | EDGE_LEFT | EDGE_BOTTOM
   };
   enum PartError {
      OKAY,
      IS_NULL,
      OUT_OF_BOUNDS,
      INVALID_ORIENTATION,
      OVERLAP,
      MISSING_CSV_DATA
   };
   enum CSV {CODE, X, Y, ORIENTATION, NUM_COLUMNS};

   static constexpr int NUM_NULL_PARTS = 1;
   static constexpr int NULL_PART_ID = 0;
   static constexpr int MAX_NAME_LENGTH = 30;

   static Ref<ShipData> create(int grid_width = 0, int grid_height = 0);

   ShipData();
   int count_part_clusters() const;
   int count_parts() const;
   bool is_empty() const;
   bool is_connected() const;
   bool has_part(int part_id) const;
   Rect2i get_grid_rect() const;
   Rect2i get_ship_rect() const;
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
   String get_name() const;
   String get_csv() const;
   NEVER_NULL Ref<Image> get_image() const;
   Ref<ImageTexture> get_texture() const;
   PackedInt32Array get_unique_parts();
   int get_part_at(Vector2i xy) const;
   NO_ERROR_CHECK Vector2 get_part_center(int part_id) const;
   NO_ERROR_CHECK Ref<PartData> get_part_data(int part_id) const;
   NO_ERROR_CHECK Rect2i get_part_rect(int part_id) const;
   NO_ERROR_CHECK PartData::Orientation get_part_orientation(int part_id) const;
   bool rect_is_part(Rect2i rect, int part_id) const;
   void set_image(Ref<Image> new_image);
   void set_name(String new_name);
   PartError add_part(Ref<PartData> part, Rect2i rect, PartData::Orientation orientation);
   PartError add_part_node(Part* part);
   PartError add_part_csv_line(PackedStringArray data, NEVER_NULL Ref<PartManager> part_manager);
   PackedInt32Array find_neighbors(int part_id, int boundary_flags = FULL_PERIMETER) const;
   void encode_csv(const String delimeter = ",");
protected:
   static void _bind_methods();
private:
   struct PackedPart;

   int _id = -1;
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
   String name = "Unnamed";
   NEVER_NULL Ref<Image> image = get_default<Image>();
   PackedInt32Array unique_parts;
   Vector<PackedPart> parts;
   Rect2i ship_rect = {0, 0, 0, 0};
   Grid id_grid;
   DisjointSets part_clusters;
   String csv;

   void add_stats(int part_id, Ref<PartData> part);
   void expand_ship_rect(Rect2i rect);
   void place_on_grid(int part_id, Rect2i rect);
   String part_to_string(const PackedPart& part, const String DELIMETER);

   friend class ShipManager;
};


struct ShipData::PackedPart {
   PartData::Orientation orientation;
   Ref<PartData> part_data = get_default<PartData>();
   Rect2i rect = {0, 0, 0, 0};
};

}

VARIANT_ENUM_CAST(ShipData::BoundaryFlag);
VARIANT_ENUM_CAST(ShipData::PartError);

#endif // SHIP_DATA_HPP