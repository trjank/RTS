#include "part_data.hpp"

using namespace godot;

PartData::Behavior PartData::get_behavior() {
   return behavior;
}
bool PartData::can_rotate() {
   return rotate_enabled;
}
void PartData::load_unique_data(Dictionary data) {
   if (data.is_empty()) return;

   WARN_PRINT_ONCE_ED("<PartData> Changes under load_unique_data are temporary");
   warp             = data.get("warp", warp);
   shield           = data.get("shield", shield);
   energy           = data.get("energy", energy);
   warp_per_sec     = data.get("warp_per_sec", warp_per_sec);
   shield_per_sec   = data.get("shield_per_sec", shield_per_sec);
   energy_per_sec   = data.get("energy_per_sec", energy_per_sec);
   thrust           = data.get("thrust", thrust);
   turning_momentum = data.get("turning_momentum", turning_momentum);
}
int PartData::get_atlas_id() {
   return atlas_id;
}
int PartData::get_cost() {
   return cost;
}
double PartData::get_hp() {
   return hp;
}
double PartData::get_mass() {
   return mass;
}
double PartData::get_warp() {
   return warp;
}
double PartData::get_shield() {
   return shield;
}
double PartData::get_energy() {
   return energy;
}
double PartData::get_warp_per_sec() {
   return warp_per_sec;
}
double PartData::get_shield_per_sec() {
   return shield_per_sec;
}
double PartData::get_energy_per_sec() {
   return shield_per_sec;
}
double PartData::get_turning_momentum() {
   return turning_momentum;
}
double PartData::get_thrust() {
   return thrust;
}
Vector2i PartData::get_size() {
   return size;
}
Vector2i PartData::get_size_px() {
   return PX_PER_GRID_SQUARE * size;
}
String PartData::get_code() {
   return code;
}
String PartData::get_subtype() {
   return subtype;
}
String PartData::get_name() {
   return name;
}
String PartData::get_tab() {
   return tab;
}
String PartData::get_desc() {
   return desc;
}
Ref<Image> PartData::get_image() {
   return image;
}
Ref<Texture2D> PartData::get_texture() {
   return texture;
}
void PartData::set_cost(int new_cost) {
   cost = Math::max(0, new_cost);
}
void PartData::set_hp(double new_hp) {
   hp = Math::max(0.0, new_hp);
}
void PartData::set_mass(double new_mass) {
   mass = Math::max(0.0, new_mass);
}
void PartData::set_size(Vector2i new_size) {
   size = new_size.max( {MIN_WIDTH, MIN_HEIGHT} );
}
void PartData::set_subtype(String new_subtype) {
   subtype = new_subtype;
}
void PartData::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
}
void PartData::set_tab(String new_tab) {
   tab = new_tab;
}
void PartData::set_desc(String new_desc) {
   desc = new_desc.substr(0, MAX_DESC_LENGTH);
}
void PartData::set_image_path(String path) {
   Ref<Texture2D> new_texture = ResourceLoader::get_singleton()->load(path);

   ERR_FAIL_NULL_MSG(new_texture,
      "<PartData> Failed to load image '" + path + "'");
   ERR_FAIL_COND_MSG(new_texture->get_size() != get_size_px(),
      "<PartData> Texture '" + path + "' has incorrect size (failed to set texture)");

   image_path = path;
   image = new_texture->get_image();
   image->convert(IMAGE_FORMAT);
   texture = new_texture;
}


int PartManager::count_parts() {
   return parts.size();
}
Ref<PartData> PartManager::lookup_id(int atlas_id) {
   return parts[atlas_id];
}
Ref<PartData> PartManager::lookup_code(String code) {
   return parts[code_to_id[code]];
}
const PackedVector2Array PartManager::get_atlas_offsets() {
   return atlas_offsets;
}
Dictionary PartManager::get_unique_data(String code) {
   return unique_data.get(code, Dictionary{});
}
String PartManager::get_parts_folder_path() {
   return parts_folder_path;
}
void PartManager::set_unique_data(String code, Dictionary new_data) {
   unique_data[code] = new_data;
}
void PartManager::set_parts_folder_path(String new_parts_folder_path) {
   parts_folder_path = new_parts_folder_path;
}
void PartManager::load_csv(String path) {
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::READ);

   ERR_FAIL_COND(file->get_csv_line() != CSV_HEADER);

   parts.clear();
   while ( !file->eof_reached()) {
      load_part(file->get_csv_line());
   }
}
void PartManager::save_csv(String path) {
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::WRITE);
   file->store_csv_line(CSV_HEADER);
   for (Ref<PartData> part: parts) {
      file->store_csv_line(to_csv_line(part));
   }
}
PackedStringArray PartManager::to_csv_line(Ref<PartData> part) {
   PackedStringArray line;
   line.resize(NUM_PROPERTIES);
   line[CODE]    = part->code;
   line[SUBTYPE] = part->subtype;
   line[NAME]    = part->name;
   line[TAB]     = part->tab;
   line[COST]    = String::num_int64(part->cost);
   line[HP]      = String::num(part->hp);
   line[MASS]    = String::num(part->mass);
   line[WIDTH]   = String::num_int64(part->size.width);
   line[HEIGHT]  = String::num_int64(part->size.height);
   line[PATH]    = part->image_path;
   line[DESC]    = part->desc;
   return line;
}
void PartManager::load_unique_data(String path) {
   ERR_FAIL_COND_MSG( !path.ends_with(".json"),
      "<PartManager> Unique data '" + path + "' must be a .json file (failed to load)");

   String raw_text = FileAccess::get_file_as_string(path);
   unique_data = JSON::parse_string(raw_text);
   Array codes = unique_data.keys();
   for (int n = 0; n < codes.size(); ++n) {
      String code = codes[n];
      lookup_code(code)->load_unique_data(unique_data[code]);
   }
}
void PartManager::save_unique_data(String path) {
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::WRITE);
   file->store_string(JSON::stringify(unique_data));
}
void PartManager::load_part(PackedStringArray data) {
   if (data == PackedStringArray{""}) return;

   ERR_FAIL_COND_MSG(data.size() != NUM_PROPERTIES,
      "<PartManager> Part csv columns differ from header (failed to load part)");

   Ref<PartData> part = new_part(data[CODE], data[SUBTYPE]);

   int32_t width  = data[WIDTH].to_int();
   int32_t height = data[HEIGHT].to_int();
   part->set_name(data[NAME]);
   part->set_subtype(data[SUBTYPE]);
   part->set_tab(data[TAB]);
   part->set_cost(data[COST].to_int());
   part->set_hp(data[HP].to_float());
   part->set_mass(data[MASS].to_float());
   part->set_size( {width, height} );
   part->set_image_path(parts_folder_path + data[PATH]);
   part->set_desc(data[DESC]);
}
void PartManager::remove_part(Ref<PartData> part) {
   ERR_FAIL_COND_MSG( !code_to_id.has(part->code),
      "<PartManager> Part with code '" + part->code + "' not found (failed to remove)");

   /*------------------------------------------------------*
   | Swap with the last element and delete from the back.  |
   | This prevents us from shifting the entire vector      |
   | down, which would require us to fix more atlas ids.   |
   *------------------------------------------------------*/
   int largest_id = parts.size() - 1;
   Ref<PartData> last_part = lookup_id(largest_id);
   code_to_id[last_part->code] = part->atlas_id;
   last_part->atlas_id = part->atlas_id;
   parts.set(part->atlas_id, last_part);
   parts.remove_at(largest_id);

   unique_data.erase(part->code);
   code_to_id.erase(part->code);
}
Ref<PartData> PartManager::new_part(String code, String subtype) {
   if (code.length() != CODE_LENGTH || code_to_id.has(code)) return nullptr;

   Ref<PartData> part = PartData::create_correct_subtype(subtype);
   part->code = code;
   part->atlas_id = parts.size();
   parts.push_back(part);
   code_to_id[code] = part->atlas_id;
   return part;
}
void PartManager::new_atlas(String save_path) {
   WARN_PRINT_ONCE_ED("<PartManager> Atlas generation is CPU-based and may take several seconds");
   create_atlas();
   populate_atlas();
   atlas->save_png(save_path);
}
void PartManager::create_atlas() {
   PackedVector2Array part_sizes;
   for (Ref<PartData> part: parts) {
      part_sizes.push_back(part->get_size_px());
   }
   Dictionary atlas_data = Geometry2D::get_singleton()->make_atlas(part_sizes);
   Vector2i size = atlas_data["size"];
   atlas_offsets = atlas_data["points"];
   atlas = Image::create(size.x, size.y, true, PartData::IMAGE_FORMAT);
}
void PartManager::draw_part_on_atlas(Ref<PartData> part) {
   Vector2i size_px = part->get_size_px();
   Vector2& offset  = atlas_offsets[part->atlas_id];
   atlas->blit_rect(part->image, {{0, 0}, size_px}, offset);
}
void PartManager::populate_atlas() {
   ERR_FAIL_COND(atlas_offsets.size() != parts.size());

   for (Ref<PartData> part: parts) {
      draw_part_on_atlas(part);
   }
}