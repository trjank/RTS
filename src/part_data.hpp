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
#include "part_data.hpp"

namespace godot {

class PartData: public RefCounted {
   GDCLASS(PartData, RefCounted)
public:
   static constexpr int PX_PER_SQUARE = 32;
   static constexpr int MAX_NAME_LENGTH = 50;
   static constexpr int MAX_DESC_LENGTH = 400;
   static constexpr int NUM_CSV_COLUMNS = 10;
   int get_cost();
   double get_hp();
   double get_weight();
   Vector2i get_size();
   Vector2i get_size_px();
   String get_code();
   String get_name();
   String get_tab();
   String get_desc();
   Ref<CompressedTexture2D> get_texture();
   void set_cost(int new_cost);
   void set_hp(double new_hp);
   void set_weight(double new_weight);
   void set_size(Vector2i new_size);
   void set_name(String new_name);
   void set_tab(String new_tab);
   void set_desc(String new_desc);
   void set_texture_path(String resource_path);
   // virtual void add_stats_to_ship(/* ShipData* ship_data*/);
protected:
   static void _bind_methods();
private:
   int atlas_id = -1;
   int cost = 0;
   double hp = 0.0;
   double weight = 0.0;
   Vector2i size = {1, 1};
   String code = "";
   String name = "Unnamed";
   String tab = "Unset";
   String texture_path = "";
   String desc = "<no description>";
   Ref<CompressedTexture2D> texture;
   friend class PartManager;
};

class PartManager: public RefCounted {
   GDCLASS(PartManager, RefCounted)
public:
   static constexpr int CODE_LENGTH = 4;
   const PackedStringArray CSV_COLUMNS = {
      "code", "name", "tab", "cost", "hp", "weight", "width", "height", "path", "desc"
   };
   int count_parts();
   void load_csv(String path);
   void save_csv(String path);
   void load_json(String path);
   void save_json(String path);
   void copy_defaults(String path, String default_path);
   void new_atlas(String save_path);
   void remove_part(Ref<PartData> part);
   Ref<PartData> new_part(String code);
   Ref<PartData> lookup_id(int atlas_id);
   Ref<PartData> lookup_code(String code);
   Dictionary get_unique(String code);
   void set_unique(String code, Dictionary new_data);
protected:
   static void _bind_methods();
private:
   PackedVector2Array atlas_offsets;
   Ref<Image> atlas;
   Dictionary unique_data;
   Dictionary code_to_id;
   Vector<Ref<PartData>> parts;
   void create_atlas();
   void populate_atlas();
   void load_part(PackedStringArray data);
   PackedStringArray to_csv_line(Ref<PartData> part);
};

}

#endif // PART_DATA_HPP