#include "part_data.hpp"

using namespace godot;

bool PartData::is_unique() {
   return unique;
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
Vector2i PartData::get_size() {
   return size;
}
Vector2i PartData::get_size_px() {
   return PX_PER_GRID_SQUARE * size;
}
String PartData::get_code() {
   return code;
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
Ref<CompressedTexture2D> PartData::get_texture() {
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
void PartData::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
}
void PartData::set_tab(String new_tab) {
   tab = new_tab;
}
void PartData::set_desc(String new_desc) {
   desc = new_desc.substr(0, MAX_DESC_LENGTH);
}
void PartData::set_texture_path(String resource_path) {
   resource_path = "res://part_images/" + resource_path;
   texture = ResourceLoader::get_singleton()->load(resource_path);
   if (texture.is_valid() && texture->get_size() != get_size_px())
      WARN_PRINT_ED("Incorrect image size: " + resource_path);
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
void PartManager::load_csv(String path) {
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::READ);
   ERR_FAIL_COND(file->get_csv_line() != CSV_COLUMNS);
   parts.clear();
   while ( !file->eof_reached()) {
      load_part(file->get_csv_line());
   }
   file->close();
}
void PartManager::save_csv(String path) {
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::WRITE);
   file->store_csv_line(CSV_COLUMNS);
   for (Ref<PartData> part: parts) {
      file->store_csv_line(to_csv_line(part));
   }
   file->close();
}
PackedStringArray PartManager::to_csv_line(Ref<PartData> part) {
   return {
      part->code, part->name, part->tab,
      String::num_int64(part->cost),
      String::num(part->hp),
      String::num_int64(part->size.width),
      String::num_int64(part->size.height),
      part->texture_path, part->desc
   };
}
void PartManager::load_json(String path) {
   String raw_text = FileAccess::get_file_as_string(path);
   unique_data = JSON::parse_string(raw_text);
}
void PartManager::save_json(String path) {
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::WRITE);
   file->store_string(JSON::stringify(unique_data));
}
void PartManager::load_part(PackedStringArray data) {
   if (data == PackedStringArray{""}) return;
   ERR_FAIL_COND(data.size() != CSV_COLUMNS.size());

   Ref<PartData> part = new_part(data[0]);

   ERR_FAIL_COND(part.is_null());

   int32_t width = data[6].to_int();
   int32_t height = data[7].to_int();
   part->set_name(data[1]);
   part->set_tab(data[2]);
   part->set_cost(data[3].to_int());
   part->set_hp(data[4].to_float());
   part->set_mass(data[5].to_float());
   part->set_size( {width, height} );
   part->set_texture_path(data[8]);
   part->set_desc(data[9]);
}
void PartManager::copy_defaults(String path, String default_path) {
   if ( !FileAccess::file_exists(path))
      DirAccess::open("res://")->copy(default_path, path);
}
void PartManager::remove_part(Ref<PartData> part) {
   ERR_FAIL_COND( !code_to_id.has(part->code));

   // Swap with the last element to avoid shifting the entire vector down
   int largest_id = parts.size() - 1;
   Ref<PartData> last_part = lookup_id(largest_id);
   code_to_id[last_part->code] = part->atlas_id;
   last_part->atlas_id = part->atlas_id;
   parts.set(part->atlas_id, last_part);
   parts.remove_at(largest_id);

   unique_data.erase(part->code);
   code_to_id.erase(part->code);
}
Ref<PartData> PartManager::new_part(String code) {
   if (code.length() != CODE_LENGTH || code_to_id.has(code)) return nullptr;

   Ref<PartData> part;
   part.instantiate();
   part->code = code;
   part->atlas_id = parts.size();
   parts.push_back(part);
   code_to_id[code] = part->atlas_id;
   return part;
}
Dictionary PartManager::get_unique(String code) {
   return unique_data.get(code, Dictionary{});
}
void PartManager::set_unique(String code, Dictionary new_data) {
   unique_data[code] = new_data;
}
void PartManager::new_atlas(String save_path) {
   WARN_PRINT_ED("Atlas generation is CPU-based and may take several seconds");
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
   atlas = Image::create(size.x, size.y, true, IMAGE_FORMAT);
}
void PartManager::draw_part_on_atlas(Ref<PartData> part) {
   const Vector2i TOP_LEFT_CORNER = {0, 0};
   Vector2i size_px = part->get_size_px();
   Vector2& offset  = atlas_offsets[part->atlas_id];
   Ref<Image> image = part->texture->get_image();
   image->convert(IMAGE_FORMAT);
   atlas->blit_rect(image, {TOP_LEFT_CORNER, size_px}, offset);

   // We need the part's offset to be the center, not the top left corner
   // This is done for the ship image assembly compute shader
   offset += 0.5 * size_px;

}
void PartManager::populate_atlas() {
   ERR_FAIL_COND(atlas_offsets.size() != parts.size());

   for (Ref<PartData> part: parts) {
      draw_part_on_atlas(part);
   }
}
const PackedByteArray PartManager::get_offsets_buffer() {
   return atlas_offsets.to_byte_array();
}