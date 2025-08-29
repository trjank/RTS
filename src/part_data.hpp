#ifndef PART_DATA_HPP
#define PART_DATA_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_string_array.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/json.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/geometry2d.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/templates/hash_map.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include "part_data.hpp"

namespace godot {

class Part;

class PartData: public RefCounted {
   GDCLASS(PartData, RefCounted)
public:
   enum Orientation: int {
      ROT_0_DEG,
      ROT_90_DEG,
      ROT_180_DEG,
      ROT_270_DEG,
      FLIPPED_ROT_0_DEG,
      FLIPPED_ROT_90_DEG,
      FLIPPED_ROT_180_DEG,
      FLIPPED_ROT_270_DEG
   };

   static constexpr Image::Format IMAGE_FORMAT = Image::FORMAT_RGBA8;
   static constexpr int MIN_WIDTH = 1;
   static constexpr int MIN_HEIGHT = 1;
   static constexpr int PX_PER_GRID_SQUARE = 32;
   static constexpr int MAX_NAME_LENGTH = 50;
   static constexpr int MAX_DESCRIPTION_LENGTH = 400;

   static bool is_flipped(Orientation orientation);
   static Orientation get_rotation(Orientation orientation);
   static Orientation to_orientation(int quarter_turns, bool flipped);
   static Ref<PartData> create_subtype(String subtype);

   bool is_unique() const;
   bool is_connected() const;
   virtual bool is_valid_orientation(Orientation _orientation) const;
   int get_atlas_id() const;
   int get_cost() const;
   double get_hp() const;
   double get_mass() const;
   double get_warp() const;
   double get_shield() const;
   double get_energy() const;
   double get_warp_per_sec() const;
   double get_shield_per_sec() const;
   double get_energy_per_sec() const;
   double get_thrust() const;
   double get_turning_momentum() const;
   Vector2i get_size() const;
   Vector2i get_size_px() const;
   String get_code() const;
   String get_name() const;
   String get_tab() const;
   String get_description() const;
   Ref<Image> get_image() const;
   Ref<Texture2D> get_texture() const;
   void set_cost(int new_cost);
   void set_hp(double new_hp);
   void set_mass(double new_mass);
   void set_width(int new_width);
   void set_height(int new_height);
   void set_size(Vector2i new_size);
   void set_name(String new_name);
   void set_tab(String new_tab);
   void set_description(String new_desc);
   void set_image(Ref<Image> new_image);
   void set_image_path(String local_path);
   // See part.cpp for the new_blank_part function definition
   virtual Part* new_blank_part();
protected:
   static void _bind_methods();

   bool unique = false;
   bool connected = true;
   double warp = 0.0;
   double shield = 0.0;
   double energy = 0.0;
   double warp_per_sec = 0.0;
   double shield_per_sec = 0.0;
   double energy_per_sec = 0.0;
   double thrust = 0.0;
   double turning_momentum = 0.0;
private:
   int atlas_id = -1;
   int cost = 0;
   double hp = 0.0;
   double mass = 0.0;
   Vector2i size = {MIN_WIDTH, MIN_HEIGHT};
   String code = "NULL";
   String name = "<unnamed>";
   String tab = "<no tab>";
   String description = "<no description>";
   Ref<Image> image;

   friend class PartManager;
};


class PartManager: public RefCounted {
   GDCLASS(PartManager, RefCounted)
public:
   static constexpr int MAX_CODE_LENGTH = 10;

   PartManager();
   int count_parts() const;
   const PackedVector2Array get_atlas_offsets();
   void new_atlas(String save_path);
   void clear_parts();
   Ref<PartData> new_part(String code, String subtype = "PartData");
   Ref<PartData> lookup_id(int atlas_id) const;
   Ref<PartData> lookup_code(String code) const;
protected:
   static void _bind_methods();
private:
   PackedVector2Array atlas_offsets;
   Ref<Image> atlas;
   HashMap<String, int> code_to_id;
   Vector<Ref<PartData>> parts;

   void create_atlas();
   void draw_part_on_atlas(Ref<PartData> part);
   void populate_atlas();
};

}

VARIANT_ENUM_CAST(PartData::Orientation);

#endif // PART_DATA_HPP