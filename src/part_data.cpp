#include "part_data.hpp"

using namespace godot;

Ref<PartData> PartData::create_subtype(String subtype) {
   return ClassDB::instantiate(subtype);
}
Vector2 PartData::to_world_vec(Vector2i vector) {
   vector *= PX_PER_GRID_SQUARE;
   return static_cast<Vector2>(vector);
}
Vector2i PartData::to_grid_vec(Vector2 vector) {
   vector /= PX_PER_GRID_SQUARE;
   return static_cast<Vector2i>(vector);
}
Rect2 PartData::to_world_rect(Rect2i rect) {
   return Rect2(to_world_vec(rect.position), to_world_vec(rect.size));
}
Rect2i PartData::to_grid_rect(Rect2 rect) {
   return Rect2i(to_grid_vec(rect.position), to_grid_vec(rect.size));
}
bool PartData::is_valid_orientation(Rotation _rotation, bool _flipped) const {
   return true;
}
bool PartData::is_unique() const {
   return unique;
}
bool PartData::is_connected() const {
   return connected;
}
int PartData::get_atlas_id() const {
   return atlas_id;
}
int PartData::get_cost() const {
   return cost;
}
double PartData::get_hp() const {
   return hp;
}
double PartData::get_mass() const {
   return mass;
}
double PartData::get_warp() const {
   return warp;
}
double PartData::get_shield() const {
   return shield;
}
double PartData::get_energy() const {
   return energy;
}
double PartData::get_warp_per_sec() const {
   return warp_per_sec;
}
double PartData::get_shield_per_sec() const {
   return shield_per_sec;
}
double PartData::get_energy_per_sec() const {
   return shield_per_sec;
}
double PartData::get_turning_momentum() const {
   return turning_momentum;
}
double PartData::get_thrust() const {
   return thrust;
}
Vector2i PartData::get_size() const {
   return size;
}
String PartData::get_code() const {
   return code;
}
String PartData::get_name() const {
   return name;
}
String PartData::get_tab() const {
   return tab;
}
String PartData::get_description() const {
   return description;
}
Ref<Image> PartData::get_image() const {
   return image;
}
Ref<Texture2D> PartData::get_texture() const {
   return ImageTexture::create_from_image(image);
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
void PartData::set_width(int new_width) {
   size.width = Math::max(new_width, MIN_WIDTH);
}
void PartData::set_height(int new_height) {
   size.height = Math::max(new_height, MIN_HEIGHT);
}
void PartData::set_size(Vector2i new_size) {
   set_width(new_size.width);
   set_height(new_size.height);
}
void PartData::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
}
void PartData::set_tab(String new_tab) {
   tab = new_tab;
}
void PartData::set_description(String new_description) {
   description = new_description.substr(0, MAX_DESCRIPTION_LENGTH);
}
void PartData::set_image(Ref<Image> new_image) {
   ERR_FAIL_NULL(new_image);
   ERR_FAIL_COND(new_image->get_size() != to_world_vec(size));

   image = new_image;
   image->convert(IMAGE_FORMAT);
}
void PartData::set_image_path(String path) {
   Ref<Texture2D> new_texture = ResourceLoader::get_singleton()->load(path);

   ERR_FAIL_NULL(new_texture);

   set_image( new_texture->get_image() );
}


int PartManager::count_parts() const {
   return parts.size();
}
Ref<PartData> PartManager::lookup_id(int atlas_id) const {
   return parts[atlas_id];
}
Ref<PartData> PartManager::lookup_code(String code) const {
   return parts[code_to_id[code]];
}
const PackedVector2Array PartManager::get_atlas_offsets() {
   return atlas_offsets;
}
void PartManager::clear_parts() {
   parts.clear();
   code_to_id.clear();
}
Ref<PartData> PartManager::new_part(String code, String subtype) {
   ERR_FAIL_COND_V(code.length() > MAX_CODE_LENGTH, nullptr);
   ERR_FAIL_COND_V_MSG(code_to_id.has(code), nullptr, "<PartManager::add_part> No duplicates allowed");

   Ref<PartData> part = PartData::create_subtype(subtype);

   ERR_FAIL_NULL_V_MSG(part, nullptr, "<PartManager::new_part> Subtype does not exist: " + subtype);

   int atlas_id = parts.size();
   
   part->code = code;
   part->atlas_id = atlas_id;
   parts.push_back(part);
   code_to_id.insert(code, atlas_id);
   return part;
}
void PartManager::new_atlas(String save_path) {
   create_atlas();
   populate_atlas();
   atlas->save_png(save_path);
}
void PartManager::create_atlas() {
   PackedVector2Array part_sizes;

   for (Ref<PartData> part: parts) {
      part_sizes.push_back( PartData::to_world_vec( part->get_size() ) );
   }
   Dictionary atlas_data = Geometry2D::get_singleton()->make_atlas(part_sizes);
   Vector2i size = atlas_data["size"];
   atlas_offsets = atlas_data["points"];
   atlas = Image::create(size.x, size.y, true, PartData::IMAGE_FORMAT);
}
void PartManager::draw_part_on_atlas(Ref<PartData> part) {
   Vector2i size = PartData::to_world_vec( part->get_size() ) ;
   Rect2i rect   = {0, 0, size.width, size.height};
   atlas->blit_rect(part->image, rect, atlas_offsets[part->atlas_id]);
}
void PartManager::populate_atlas() {
   ERR_FAIL_COND(atlas_offsets.size() != parts.size());

   for (Ref<PartData> part: parts) {
      draw_part_on_atlas(part);
   }
}