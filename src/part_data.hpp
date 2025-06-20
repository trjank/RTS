#ifndef PART_DATA_HPP
#define PART_DATA_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_string_array.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/compressed_texture2d.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/dir_access.hpp>
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/json.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/geometry2d.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/classes/node.hpp>
#include "part_data.hpp"

#define PART_IMAGES_FOLDER "res://part_images/"

namespace godot {

class Part;

class PartData: public RefCounted {
   GDCLASS(PartData, RefCounted)
public:
   static constexpr int MIN_WIDTH = 1;
   static constexpr int MIN_HEIGHT = 1;
   static constexpr int PX_PER_GRID_SQUARE = 32;
   static constexpr int MAX_NAME_LENGTH = 50;
   static constexpr int MAX_DESC_LENGTH = 400;
   static constexpr int NUM_CSV_HEADER = 10;

   static Ref<PartData> create_correct_subtype(String subtype);

   virtual bool exposed_to_design_mode();
   virtual bool flatten_with_ship();
   virtual void load_unique(Dictionary data);
   virtual Part* new_part();
   int get_atlas_id();
   int get_cost();
   double get_hp();
   double get_mass();
   double get_shield();
   double get_shield_per_sec();
   double get_warp();
   double get_warp_per_sec();
   double get_torque();
   double get_thrust();
   Vector2i get_size();
   Vector2i get_size_px();
   String get_code();
   String get_name();
   String get_tab();
   String get_desc();
   Ref<Texture2D> get_texture();
   void set_cost(int new_cost);
   void set_hp(double new_hp);
   void set_mass(double new_mass);
   void set_size(Vector2i new_size);
   void set_name(String new_name);
   void set_tab(String new_tab);
   void set_desc(String new_desc);
   void set_texture_path(String local_path);
protected:
   static void _bind_methods();

   double shield = 0.0;
   double shield_per_sec = 0.0;
   double warp = 0.0;
   double warp_per_sec = 0.0;
   double torque = 0.0;
   double thrust = 0.0;
private:
   int atlas_id = -1;
   int cost = 0;
   double hp = 0.0;
   double mass = 0.0;
   Vector2i size = {MIN_WIDTH, MIN_HEIGHT};
   String code = "NULL";
   String name = "<unnamed>";
   String tab = "<no tab>";
   String texture_path = "missing.png";
   String desc = "<no description>";
   Ref<Texture2D> texture;

   friend class PartManager;
};

class PartManager: public RefCounted {
   GDCLASS(PartManager, RefCounted)
public:
   static constexpr Image::Format IMAGE_FORMAT = Image::FORMAT_RGBA8;
   static constexpr int CODE_LENGTH = 4;
   enum PropertyOrder: int {
      CODE, NAME, TAB, COST, HP, MASS, WIDTH, HEIGHT, PATH, DESC, NUM_PROPERTIES
   };
   const PackedStringArray CSV_HEADER = {
      "code", "name", "tab", "cost", "hp", "mass", "width", "height", "path", "desc"
   };

   int count_parts();
   const PackedVector2Array get_atlas_offsets();
   Dictionary get_unique(String code);
   void set_unique(String code, Dictionary new_data);
   void load_csv(String path);
   void save_csv(String path);
   void load_unique_data(String path);
   void save_unique_data(String path);
   void new_atlas(String save_path);
   void remove_part(Ref<PartData> part);
   Ref<PartData> new_part(String code, String subtype = "");
   Ref<PartData> lookup_id(int atlas_id);
   Ref<PartData> lookup_code(String code);
protected:
   static void _bind_methods();
private:
   PackedVector2Array atlas_offsets;
   Ref<Image> atlas;
   Dictionary unique_data;
   Dictionary code_to_id;
   Vector<Ref<PartData>> parts;

   void create_atlas();
   void draw_part_on_atlas(Ref<PartData> part);
   void populate_atlas();
   void load_part(PackedStringArray data);
   PackedStringArray to_csv_line(Ref<PartData> part);
};

}

#endif // PART_DATA_HPP