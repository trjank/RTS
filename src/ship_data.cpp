#include "ship_data.hpp"

using namespace godot;

#include <godot_cpp/variant/utility_functions.hpp>

Vector2i ShipData::get_grid_padding() {
   /*------------------------------------------------------*
   | Grid padding serves two purposes:                     |
   |                                                       |
   | 1. We can avoid error handling at the grid boundary,  |
   |    which simplifies searches for neighboring parts.   |
   | 2. We can use outline shaders on the padded image,    |
   |    since the borders are guaranteed to be empty.      |
   *------------------------------------------------------*/
   return {1, 1};
}
Ref<ShipData> ShipData::assemble(Vector2i size, TypedArray<Node> parts) {
   Ref<ShipData> ship = memnew(ShipData);
   Vector2 padded_size = size + 2 * get_grid_padding();
   ship->part_clusters.new_set(); // NULL part
   ship->grid_region = {get_grid_padding(), size};
   ship->grid = PackedInt32Grid::createv(padded_size);

   #if CPU_IMAGE_GENERATION
   padded_size *= PartData::PX_PER_GRID_SQUARE;
   ship->image = Image::create(padded_size.width, padded_size.height, true, Image::FORMAT_RGBA8);
   #endif // CPU_IMAGE_GENERATION

   for (int n = 0; n < parts.size(); ++n) {
      ship->add_part_node( Object::cast_to<Part>( parts[n] ) );
      UtilityFunctions::print("ERROR: ", ship->get_error());
   }

   return ship;
}
int ShipData::count_parts() {
   return parts.size() - NUM_NULL_PARTS;
}
bool ShipData::is_empty() {
   return parts.is_empty();
}
bool ShipData::is_connected() {
   return part_clusters.count_num_sets() == NUM_NULL_PARTS + 1;
}
ShipData::PartError ShipData::get_error() {
   return error;
}
int ShipData::get_cost() {
   return cost;
}
double ShipData::get_max_hp() {
   return max_hp;
}
double ShipData::get_max_warp() {
   return max_warp;
}
double ShipData::get_max_shield() {
   return max_shield;
}
double ShipData::get_max_energy() {
   return max_energy;
}
double ShipData::get_warp_per_sec() {
   return warp_per_sec;
}
double ShipData::get_shield_per_sec() {
   return shield_per_sec;
}
double ShipData::get_energy_per_sec() {
   return energy_per_sec;
}
double ShipData::get_thrust() {
   return thrust;
}
double ShipData::get_turnrate() {
   return turnrate;
}
Vector2 ShipData::get_center_of_mass() {
   return mass_offset / mass;
}
Vector2i ShipData::get_size() {
   return grid_region.size;
}
Vector2i ShipData::get_size_px() {
   return PartData::PX_PER_GRID_SQUARE * grid_region.size;
}
Ref<Image> ShipData::get_image() {
   return image;
}
Ref<PartData> ShipData::get_part_data(int part_id) {
   return parts[part_id];
}
void ShipData::set_image(Ref<Image> new_image) {
   ERR_FAIL_COND_MSG(CPU_IMAGE_GENERATION
      && new_image.is_valid()
      && new_image->get_size() < get_size_px(),
      "<ShipData> Image size is too small (failed to set image)");

   image = new_image;
}
bool ShipData::has_part(int part_id) {
   return part_id > NULL_PART_ID && part_id < parts.size();
}
PackedInt32Array ShipData::find_neighbors(int part_id, PartData::BoundaryFlag flags) {
   PackedInt32Array neighbors;
   Vector2i min = part_regions[part_id].position;
   Vector2i max = part_regions[part_id].get_end();

   if (flags & PartData::EDGE_TOP)
   for (int x = min.x; x < max.x; ++x) {
      neighbors.push_back(grid.get(x, min.y - 1));
   }
   if (flags & PartData::EDGE_BOTTOM)
   for (int x = min.x; x < max.x; ++x) {
      neighbors.push_back(grid.get(x, max.y));
   }
   if (flags & PartData::EDGE_LEFT)
   for (int y = min.y; y < max.y; ++y) {
      neighbors.push_back(grid.get(min.x - 1, y));
   }
   if (flags & PartData::EDGE_RIGHT)
   for (int y = min.y; y < max.y; ++y) {
      neighbors.push_back(grid.get(max.x, y));
   }
   return neighbors;
}
int ShipData::add_part(Ref<PartData> part, Vector2 center, RotationState rotation_state) {
   if (part.is_null()) {
      error = IS_NULL;
      return NULL_PART_ID;
   }

   // I'll clean this up later...
   center /= PartData::PX_PER_GRID_SQUARE;
   center += get_grid_padding() + grid_region.get_center();
   UtilityFunctions::print(center);

   Vector2i size = part->get_size();
   if (rotation_state % 2 == 1)
      size = {size.height, size.width};

   Rect2i rect(center - 0.5 * (Vector2) size, size);
   rect = rect.intersection(grid_region);
   part_regions.push_back(rect);
   part_centers.push_back(center);

   if (rect.size != size) {
      error = OUT_OF_BOUNDS;
      return NULL_PART_ID;
   }

   #if CHECK_FOR_PART_OVERLAP
   if ( !grid.is_empty_region(rect, NULL_PART_ID)) {
      error = OVERLAP;
      return NULL_PART_ID;
   }
   #endif // CHECK_FOR_PART_OVERLAP

   int part_id = part_clusters.new_set();
   UtilityFunctions::print("STARTING SEARCH: ", part_id);
   UtilityFunctions::print("(BEFORE): ", part_clusters.count_num_sets());
   for (int neighbor_id: find_neighbors(part_id, part->get_boundary())) {
      UtilityFunctions::print("part_id: ", part_id, " | neighbor_id: ", neighbor_id);
      if (neighbor_id != NULL_PART_ID) part_clusters.merge(part_id, neighbor_id);
   }
   UtilityFunctions::print("(AFTER): ", part_clusters.count_num_sets());
   parts.push_back(part);
   rotation_states.push_back(rotation_state);
   grid.fill_rect(rect, part_id);
   add_stats(part, center);

   #if CPU_IMAGE_GENERATION
   // TODO: Maybe cache rotated and flipped variations?
   Ref<Image> part_image = part->get_image()->duplicate();
   switch (rotation_state) {
      case ROT_0_DEG:
         break;
      case FLIPPED_ROT_0_DEG:
         part_image->flip_x();
         break;
      case FLIPPED_ROT_90_DEG:
         part_image->flip_x();
      case ROT_90_DEG:
         part_image->rotate_90(ClockDirection::CLOCKWISE);
         break;
      case FLIPPED_ROT_180_DEG:
         part_image->flip_x();
      case ROT_180_DEG:
         part_image->rotate_180();
         break;
      case FLIPPED_ROT_270_DEG:
         part_image->flip_x();
      case ROT_270_DEG:
         part_image->rotate_90(ClockDirection::COUNTERCLOCKWISE);
         break;
   }
   rect.size     *= PartData::PX_PER_GRID_SQUARE;
   rect.position *= PartData::PX_PER_GRID_SQUARE;
   UtilityFunctions::print("BEFORE: ", image->is_invisible());
   image->blit_rect(part_image, {{0, 0}, rect.size}, rect.position);
   UtilityFunctions::print("AFTER: ", image->is_invisible());
   #endif // CPU_IMAGE_GENERATION

   error = OKAY;
   return part_id;
}
int ShipData::add_part_node(Part* part) {
   if ( !part) {
      error = IS_NULL;
      return NULL_PART_ID;
   }
   Ref<PartData> data = part->get_data();
   Vector2 position   = part->get_position();
   double rotation    = part->get_rotation();
   bool flipped       = part->get_scale().x < 0;
   return part->ship_data_part_id = add_part(data, position, encode_rotation(rotation, flipped));
}
Ref<PartData> ShipData::collision_check(Vector2 point) {
   Vector2i coords = point + get_center_of_mass();

   if ( !grid_region.has_point(coords)) return nullptr;

   int part_id = grid.getv(coords);
   return parts[part_id];
}
void ShipData::add_stats(Ref<PartData> part, Vector2 center) {
   cost           += part->get_cost();
   mass           += part->get_mass();
   max_warp       += part->get_warp();
   max_shield     += part->get_shield();
   max_energy     += part->get_energy();
   warp_per_sec   += part->get_warp_per_sec();
   shield_per_sec += part->get_shield_per_sec();
   energy_per_sec += part->get_energy_per_sec();
   mass_offset    += part->get_mass() * center;
}
ShipData::RotationState ShipData::encode_rotation(double radians, bool flipped) {
   // I'll clean this up later...
   radians = Math::fmod(radians, 2 * Math_PI);
   if (radians < 0) radians += 2 * Math_PI;

   int quadrant = Math::snapped(radians, PI_2) / PI_2;
   int encoding = quadrant + NUM_ROTATION_INCREMENTS * flipped;
   return static_cast<RotationState>(encoding);
}


ShipManager::ShipManager() {
   part_manager.instantiate();
   part_manager->new_part("NULL");
}
void ShipManager::load_part_into_ship(Ref<ShipData> ship, PackedStringArray csv_line) {
   Ref<PartData> part = part_manager->lookup_code(csv_line[CODE]);
   float x            = csv_line[X].to_float();
   float y            = csv_line[Y].to_float();
   int rotation_state = csv_line[ROTATION_STATE].to_int();
   ship->add_part(part, {x, y}, static_cast<ShipData::RotationState>(rotation_state));
}
Ref<ImageTexture> ShipManager::load_ship_image(String path) {
   return ResourceLoader::get_singleton()->load(path);
}
Ref<ShipData> ShipManager::load_ship_csv(String path) {
   Ref<ShipData> ship = memnew(ShipData);
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
   line.resize(NUM_PROPERTIES);
   line[CODE]           = ship->parts[part_id]->get_code();
   line[X]              = String::num(ship->part_centers[part_id].x);
   line[Y]              = String::num(ship->part_centers[part_id].y);
   line[ROTATION_STATE] = String::num_int64(ship->rotation_states[part_id]);
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