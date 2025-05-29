#ifndef PART_DATA_HPP
#define PART_DATA_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/variant/packed_string_array.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include "part_data.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                     part_data.hpp                     |
|                                                       |
*------------------------------------------------------*/

using godot::Ref;
using godot::RefCounted;
using godot::String;
using godot::Vector;
using godot::Vector2i;
using godot::PackedStringArray;
using godot::ImageTexture;
using godot::Image;
using godot::TypedArray;

class PartData: public RefCounted {
   GDCLASS(PartData, RefCounted)
public:
   static constexpr int MAX_NAME_LENGTH = 20;

   int get_ID();
   int get_cost();
   double get_HP();
   Vector2i get_size();
   String get_name();
   String get_tab();
   Ref<ImageTexture> get_texture();
   void set_cost(int new_cost);
   void set_HP(double new_HP);
   void set_size(Vector2i new_size);
   void set_name(String new_name);
   void set_tab(String new_tab);
   void set_texture_path(String resource_path);
protected:
   static void _bind_methods();
private:
   int ID = -1;
   int cost = 0;
   double HP = 0.0;
   Vector2i size = { 1, 1 };
   String name = "Unnamed";
   String tab = "Unset";
   String texture_path = "";
   Ref<ImageTexture> texture;
   friend class PartManager;
};

class PartManager: public RefCounted {
   GDCLASS(PartManager, RefCounted)
public:
   int count_parts();
   TypedArray<PartData> get_parts();
   Ref<PartData> new_part();
   void save();
   void load();
protected:
   static void _bind_methods();
private:
   enum ColumnIndex { ID, NAME, TAB, COST, HP, WIDTH, HEIGHT, PATH };
   const PackedStringArray csv_columns = { "ID", "name", "tab", "cost", "HP", "width", "height", "path" };
   String csv_path = "user://parts.csv";
   TypedArray<PartData> parts;

   static PackedStringArray to_csv_line(Ref<PartData> part);

   void load_part(PackedStringArray data);
};

#endif // PART_DATA_HPP