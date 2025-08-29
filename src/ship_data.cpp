#include "ship_data.hpp"

using namespace godot;

Ref<ShipData> ShipData::create(int grid_width, int grid_height) {
   Ref<ShipData> ship = memnew(ShipData);

   ship->id_grid = Grid::create(grid_width, grid_height);
   ship->id_grid.fill(NULL_PART_ID);

   return ship;
}
ShipData::ShipData() {
   PackedPart null_part;

   part_clusters.new_set();
   parts.push_back(null_part);
}
int ShipData::count_part_clusters() const {
   return part_clusters.count_sets() - NUM_NULL_PARTS;
}
int ShipData::count_parts() const {
   return parts.size() - NUM_NULL_PARTS;
}
bool ShipData::is_empty() const {
   return count_parts() == 0;
}
bool ShipData::is_connected() const {
   return part_clusters.count_sets() == NUM_NULL_PARTS + 1;
}
bool ShipData::has_part(int part_id) const {
   return NULL_PART_ID < part_id && part_id < parts.size();
}
Rect2i ShipData::get_grid_rect() const {
   return id_grid.get_rect();
}
Rect2i ShipData::get_ship_rect() const {
   return ship_rect;
}
int ShipData::get_cost() const {
   return cost;
}
double ShipData::get_max_hp() const {
   return max_hp;
}
double ShipData::get_max_warp() const {
   return max_warp;
}
double ShipData::get_max_shield() const {
   return max_shield;
}
double ShipData::get_max_energy() const {
   return max_energy;
}
double ShipData::get_warp_per_sec() const {
   return warp_per_sec;
}
double ShipData::get_shield_per_sec() const {
   return shield_per_sec;
}
double ShipData::get_energy_per_sec() const {
   return energy_per_sec;
}
double ShipData::get_thrust() const {
   return thrust;
}
double ShipData::get_turnrate() const {
   return turnrate;
}
Vector2 ShipData::get_center_of_mass() const {
   return mass_offset / mass;
}
NEVER_NULL Ref<Image> ShipData::get_image() const {
   return image;
}
Ref<ImageTexture> ShipData::get_texture() const {
   return ImageTexture::create_from_image(image);
}
String ShipData::get_name() const {
   return name;
}
String ShipData::get_csv() const {
   return csv;
}
PackedInt32Array ShipData::get_unique_parts() {
   return unique_parts;
}
int ShipData::get_part_at(Vector2i xy) const {
   return id_grid.get_rect().has_point(xy) ? id_grid.getv(xy) : NULL_PART_ID;
}
NO_ERROR_CHECK Vector2 ShipData::get_part_center(int part_id) const {
   return static_cast<Rect2>(parts[part_id].rect).get_center();
}
NO_ERROR_CHECK Ref<PartData> ShipData::get_part_data(int part_id) const {
   return parts[part_id].part_data;
}
NO_ERROR_CHECK Rect2i ShipData::get_part_rect(int part_id) const {
   return parts[part_id].rect;
}
NO_ERROR_CHECK PartData::Orientation ShipData::get_part_orientation(int part_id) const {
   return parts[part_id].orientation;
}
void ShipData::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
}
void ShipData::set_image(Ref<Image> new_image) {
   ERR_FAIL_NULL(new_image);

   image = new_image;
}
bool ShipData::rect_is_part(Rect2i rect, int part_id) const {
   rect = id_grid.get_rect().intersection(rect);

   return id_grid.rect_is_value(rect, part_id);
}
PackedInt32Array ShipData::find_neighbors(int part_id, int boundary_flags) const {
   PackedInt32Array neighbors;

   ERR_FAIL_COND_V( !has_part(part_id), neighbors);

   Vector2i min = parts[part_id].rect.position;
   Vector2i max = parts[part_id].rect.get_end();

   /*------------------------------------------------------|
   | Empty space is ignored. Note that this is relative to |
   | the ship, not the part (part orientation is ignored). |
   |------------------------------------------------------*/
   if ((boundary_flags & EDGE_TOP) && min.y > 0)
   for (int id, x = min.x; x < max.x; ++x) {
      if ((id = id_grid.get(x, min.y - 1)) != NULL_PART_ID) neighbors.push_back(id);
   }
   if ((boundary_flags & EDGE_BOTTOM) && max.y < id_grid.get_rect().size.height)
   for (int id, x = min.x; x < max.x; ++x) {
      if ((id = id_grid.get(x, max.y)) != NULL_PART_ID) neighbors.push_back(id);
   }
   if ((boundary_flags & EDGE_LEFT) && min.x > 0)
   for (int id, y = min.y; y < max.y; ++y) {
      if ((id = id_grid.get(min.x - 1, y)) != NULL_PART_ID) neighbors.push_back(id);
   }
   if ((boundary_flags & EDGE_RIGHT) && max.x < id_grid.get_rect().size.width)
   for (int id, y = min.y; y < max.y; ++y) {
      if ((id = id_grid.get(max.x, y)) != NULL_PART_ID) neighbors.push_back(id);
   }
   return neighbors;
}
ShipData::PartError ShipData::add_part(Ref<PartData> part, Rect2i rect, PartData::Orientation orientation) {
   if (unlikely( part.is_null() )) return IS_NULL;
   if (unlikely( !id_grid.get_rect().encloses(rect) )) return OUT_OF_BOUNDS;
   if (unlikely( !part->is_valid_orientation(orientation) )) return INVALID_ORIENTATION;
   if (unlikely( part->is_connected() && !id_grid.rect_is_value(rect, NULL_PART_ID) )) return OVERLAP;

   /*------------------------------------------------------|
   | Each part starts as an isolated cluster. We merge     |
   | clusters to determine if the ship is connected.       |
   |------------------------------------------------------*/
   int part_id = part_clusters.new_set();

   PackedPart packed = {orientation, part, rect};

   parts.push_back(packed);
   add_stats(part_id, part);
   expand_ship_rect(rect);

   if (part->is_unique()) unique_parts.push_back(part_id);

   if (part->is_connected())
      place_on_grid(part_id, rect);
   else
      part_clusters.merge(part_id, NULL_PART_ID);
   return OKAY;
}
ShipData::PartError ShipData::add_part_node(Part* part) {
   return !part ? IS_NULL : add_part(part->get_data(), part->get_grid_rect(), part->get_orientation());
}
ShipData::PartError ShipData::add_part_csv_line(PackedStringArray data, NEVER_NULL Ref<PartManager> part_manager) {
   if (unlikely( data.size() < NUM_COLUMNS )) return MISSING_CSV_DATA;

   Ref<PartData> part_data = part_manager->lookup_code(data[CODE]);

   if (unlikely( part_data.is_null() )) return IS_NULL;

   Rect2i rect;

   int orientation = data[ORIENTATION].to_int();

   rect.position.x = data[X].to_int();
   rect.position.y = data[Y].to_int();
   rect.size       = part_data->get_size();
   return add_part(part_data, rect, static_cast<PartData::Orientation>(orientation));
}
void ShipData::encode_csv(const String delimeter) {
   csv = "";

   for (int n = NULL_PART_ID + 1; n < parts.size(); ++n) {
      csv += part_to_string(parts[n], delimeter) + '\n';
   }
}
void ShipData::add_stats(int part_id, Ref<PartData> part) {
   thrust         += part->get_thrust();
   cost           += part->get_cost();
   mass           += part->get_mass();
   max_warp       += part->get_warp();
   max_shield     += part->get_shield();
   max_energy     += part->get_energy();
   warp_per_sec   += part->get_warp_per_sec();
   shield_per_sec += part->get_shield_per_sec();
   energy_per_sec += part->get_energy_per_sec();
   mass_offset    += part->get_mass() * get_part_center(part_id);
}
void ShipData::expand_ship_rect(Rect2i rect) {
   ship_rect = unlikely(count_parts() <= 1) ? rect : ship_rect.merge(rect);
}
void ShipData::place_on_grid(int part_id, Rect2i rect) {
   id_grid.fill_rect(rect, part_id);

   for (int neighbor_id: find_neighbors(part_id, FULL_PERIMETER)) {
      part_clusters.merge(part_id, neighbor_id);
   }
}
String ShipData::part_to_string(const PackedPart& part, const String DELIMETER) {
   String str = "";

   str += part.part_data->get_code()
   + DELIMETER + String::num_int64(part.rect.position.x)
   + DELIMETER + String::num_int64(part.rect.position.y)
   + DELIMETER + String::num_int64(part.orientation);
   return str;
}