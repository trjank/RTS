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
NO_ERROR_CHECK PartData::Rotation ShipData::get_part_rotation(int part_id) const {
   return static_cast<PartData::Rotation>(parts[part_id].rotation);
}
NO_ERROR_CHECK bool ShipData::is_part_flipped(int part_id) const {
   return parts[part_id].flipped;
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
ShipData::PartError ShipData::add_part(Ref<PartData> part, Rect2i rect, PartData::Rotation rotation, bool flipped) {
   if (part.is_null()) return IS_NULL;
   if ( !id_grid.get_rect().encloses(rect)) return OUT_OF_BOUNDS;
   if ( !part->is_valid_orientation(rotation, flipped)) return INVALID_ORIENTATION;
   if (part->is_connected() && !id_grid.rect_is_value(rect, NULL_PART_ID)) return OVERLAP;

   /*------------------------------------------------------|
   | Each part starts as an isolated cluster. We merge     |
   | clusters to determine if the ship is connected.       |
   |------------------------------------------------------*/
   int part_id = part_clusters.new_set();

   PackedPart packed = {flipped, rotation, part, rect};

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
   if ( !part) return IS_NULL;

   Rect2i rect = PartData::to_grid_rect( part->get_rect() );
   
   return add_part(part->get_data(), rect, part->get_rotation_state(), part->is_flipped());
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


ShipManager::ShipManager() {
   part_manager.instantiate();
   part_manager->new_part("NULL");
}
void ShipManager::set_part_manager(Ref<PartManager> new_part_manager) {
   part_manager = new_part_manager;
}
void ShipManager::load_part_into_ship(Ref<ShipData> ship, PackedStringArray csv_line) {
   Ref<PartData> part = part_manager->lookup_code(csv_line[CODE]);
   int x            = csv_line[X].to_int();
   int y            = csv_line[Y].to_int();
   int rotation = csv_line[ROTATION].to_int();
   bool flipped = csv_line[FLIPPED] == "true";
   Rect2i rect({x, y}, part->get_size());
   ship->add_part(part, rect, static_cast<PartData::Rotation>(rotation), flipped);
}
Ref<ImageTexture> ShipManager::load_ship_image(String path) {
   return ResourceLoader::get_singleton()->load(path);
}
Ref<ShipData> ShipManager::load_ship_csv(int width, int height, String path) {
   Ref<ShipData> ship   = ShipData::create(width, height);
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::READ);

   ERR_FAIL_COND_V_MSG(file.is_null(), ship,
   "<ShipData> Ship csv file not found (failed to load csv)");
   ERR_FAIL_COND_V_MSG(file->get_csv_line() != CSV_HEADER, ship,
   "<ShipData> Ship csv header is incorrect (failed to load csv)");

   while ( !file->eof_reached()) {
      load_part_into_ship(ship, file->get_csv_line());
   }
   return ship;
}
PackedStringArray ShipManager::to_csv_line(Ref<ShipData> ship, int part_id) {
   PackedStringArray line;
   Vector2 center = ship->get_part_center(part_id);
   line.resize(NUM_PROPERTIES);
   line[CODE]           = ship->parts[part_id].part_data->get_code();
   line[X]              = String::num(center.x);
   line[Y]              = String::num(center.y);
   line[ROTATION] = String::num_int64(ship->parts[part_id].rotation);
   line[FLIPPED] = String::num_int64(ship->parts[part_id].flipped);
   return line;
}
void ShipManager::save_ship_image(Ref<ShipData> ship, String path) {
   ERR_FAIL_NULL_MSG(ship,
   "<ShipManager> Ship is null (failed to save image)");
   ERR_FAIL_NULL_MSG(ship->get_image(),
   "<ShipManager> Ship has no image (failed to save image)");
   ERR_FAIL_COND_MSG( !path.ends_with(".png"),
   "<ShipManager> Ship images can only be saved as .png (failed to save image)");

   ship->get_image()->save_png(path);
}
void ShipManager::save_ship_csv(Ref<ShipData> ship, String path) {
   ERR_FAIL_NULL_MSG(ship,
   "<ShipManager> Ship is null (failed to save csv)");
   ERR_FAIL_COND_MSG( !path.ends_with(".csv"),
   "<ShipManager> Ships can only be saved as a .csv file (failed to save csv)");

   Ref<FileAccess> csv = FileAccess::open(path, FileAccess::WRITE);
   csv->store_csv_line(CSV_HEADER);

   for (int id = ShipData::NULL_PART_ID + 1; id <= ship->count_parts(); ++id) {
      csv->store_csv_line( to_csv_line(ship, id) );
   }
}