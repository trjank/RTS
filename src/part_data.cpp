#include <godot_cpp/core/math.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/array.hpp>
#include "part_data.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                     part_data.cpp                     |
|                                                       |
*------------------------------------------------------*/

using godot::Math::min;
using godot::Array;
using godot::FileAccess;

int PartData::get_ID() {
   return ID;
}
int PartData::get_cost() {
   return cost;
}
double PartData::get_HP() {
   return HP;
}
Vector2i PartData::get_size() {
   return size;
}
String PartData::get_name() {
   return name;
}
String PartData::get_tab() {
   return tab;
}
Ref<ImageTexture> PartData::get_texture() {
   return texture;
}
void PartData::set_cost(int new_cost) {
   cost = min(0, new_cost);
}
void PartData::set_HP(double new_HP) {
   HP = min(0.0, new_HP);
}
void PartData::set_size(Vector2i new_size) {
   size = new_size.max({ 1, 1 });
}
void PartData::set_name(String new_name) {
   ERR_FAIL_COND(new_name.length() > MAX_NAME_LENGTH);
   name = new_name;
}
void PartData::set_tab(String new_tab) {
   ERR_FAIL_COND(new_tab.length() > MAX_NAME_LENGTH);
   tab = new_tab;
}
void PartData::set_texture_path(String resource_path) {
   texture_path = "res://" + resource_path;
   // REMEMBER TO DEAL WITH FILE NOT FOUND ERROR
   Ref<Image> image = Image::load_from_file(texture_path);
   texture = ImageTexture::create_from_image(image);
}



int PartManager::count_parts() {
   return parts.size();
}
TypedArray<PartData> PartManager::get_parts() {
   return parts;
}
Ref<PartData> PartManager::new_part() {
   Ref<PartData> part;
   part.instantiate();
   part->ID = parts.size();
   parts.push_back(part);
   return part;
}
void PartManager::save() {
   Ref<FileAccess> csv = FileAccess::open(csv_path, FileAccess::WRITE);
   csv->store_csv_line(csv_columns);
   for (int ID = 0; ID < parts.size(); ++ID) {
      Ref<PartData> part = parts[ID];
      ERR_FAIL_COND(part.is_null());
      csv->store_csv_line(to_csv_line(part));
   }
   csv->close();
}
void PartManager::load() {
   Ref<FileAccess> csv = FileAccess::open(csv_path, FileAccess::READ);
   ERR_FAIL_COND(csv->get_csv_line() != csv_columns);
   parts.clear();
   while ( !csv->eof_reached()) {
      load_part(csv->get_csv_line());
   }
   csv->close();
}
void PartManager::load_part(PackedStringArray data) {
   const PackedStringArray empty_line = { "" };
   if (data == empty_line) return;
   ERR_FAIL_COND(data.size() != csv_columns.size());
   
   Ref<PartData> part = new_part();
   part->ID = data[ID].to_int();
   part->set_name(data[NAME]);
   part->set_tab(data[TAB]);
   part->set_cost(data[COST].to_int());
   part->set_HP(data[HP].to_float());
   part->set_size({
      static_cast<int32_t>(data[WIDTH].to_int()),
      static_cast<int32_t>(data[HEIGHT].to_int())
   });
   part->set_texture_path(data[PATH]);
}
PackedStringArray PartManager::to_csv_line(Ref<PartData> part) {
   return {
      String::num_int64(part->ID),
      part->name,
      part->tab,
      String::num_int64(part->cost),
      String::num(part->HP),
      String::num_int64(part->size.width),
      String::num_int64(part->size.height),
      part->texture_path
   };
}