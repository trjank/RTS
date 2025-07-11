#include "ship_data.hpp"
// needed to use math primitives on visual studio compiler...
#define _USE_MATH_DEFINES
#include <cmath>
#include <math.h>

using namespace godot;

constexpr double PI_2 = 0.5 * Math_PI;

Vector2i ShipData::get_grid_padding() {
   /*------------------------------------------------------|
   | Grid padding serves two purposes:                     |
   |                                                       |
   | 1. We can avoid error handling at the grid boundary,  |
   |    which simplifies searches for neighboring parts.   |
   | 2. We can use outline shaders on the padded image,    |
   |    since the borders are guaranteed to be empty.      |
   |------------------------------------------------------*/
   return {1, 1};
}
Ref<ShipData> ShipData::assemble(Vector2i size, TypedArray<Node> parts) {
   Ref<ShipData> ship  = memnew(ShipData);
   Vector2 padded_size = size + 2 * get_grid_padding();

   ship->grid_region.size = size;
   ship->grid = PackedInt32Grid::createv(padded_size);

   #if CPU_IMAGE_GENERATION
   padded_size *= PartData::PX_PER_GRID_SQUARE;
   ship->image  = Image::create(padded_size.width, padded_size.height, true, Image::FORMAT_RGBA8);
   #endif // CPU_IMAGE_GENERATION

   for (int n = 0; n < parts.size(); ++n) {
      ship->add_part_node( Object::cast_to<Part>( parts[n] ) );
   }
   //UtilityFunctions::print("bro plz ", ship->get_ship_bounds());
   return ship;
}
ShipData::ShipData() {
   grid_region.position = get_grid_padding();
   grid_region.size = {0, 0};

   // Create some placeholders for the null part
   parts = {nullptr};
   part_rotation_states = {ROT_0_DEG};
   part_centers = { {0.0F, 0.0F} };
   part_regions = { {0, 0, 0, 0} };
   part_clusters.new_set();
}
int ShipData::count_parts() const {
   return parts.size() - NUM_NULL_PARTS;
}
bool ShipData::is_empty() const {
   return parts.is_empty();
}
bool ShipData::is_connected() const {
   return part_clusters.count_num_sets() == NUM_NULL_PARTS + 1;
}
bool ShipData::has_part(int part_id) const {
   return part_id > NULL_PART_ID && part_id < parts.size();
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
Vector2i ShipData::get_size() const {
   return grid_region.size;
}
Vector2i ShipData::get_size_px() const {
   return grid_region.size * PartData::PX_PER_GRID_SQUARE;
}
Ref<Image> ShipData::get_image() const {
   return image;
}
PackedInt32Array ShipData::get_unique_parts() {
   return unique_parts;
}
int ShipData::get_part_at(Vector2 location) const {
   return grid.getv(location);
}
ShipData::RotationState ShipData::get_part_rotation_state(int part_id) const {
   return part_rotation_states[part_id];
}
Vector2 ShipData::get_part_center(int part_id) const {
   return part_centers[part_id];
}
Vector2 ShipData::get_part_center_px(int part_id) const {
   return part_centers[part_id] * PartData::PX_PER_GRID_SQUARE;
}
Rect2i ShipData::get_part_region(int part_id) const {
   return part_regions[part_id];
}
Ref<PartData> ShipData::get_part_data(int part_id) const {
   return parts[part_id];
}
void ShipData::set_image(Ref<Image> new_image) {
   #if CPU_IMAGE_GENERATION
   ERR_FAIL_COND_MSG(new_image.is_valid() && new_image->get_size() != get_size_px(),
   "<ShipData> Image size is too small (failed to set image)");
   #endif // CPU_IMAGE_GENERATION

   image = new_image;
}
PackedInt32Array ShipData::find_neighbors(int part_id, int boundary_flags) const {
   PackedInt32Array neighbors;
   Vector2i min = part_regions[part_id].position;
   Vector2i max = part_regions[part_id].get_end();

   if (boundary_flags & EDGE_TOP)
   for (int x = min.x; x < max.x; ++x) {
      neighbors.push_back( grid.get(x, min.y - 1) );
   }
   if (boundary_flags & EDGE_BOTTOM)
   for (int x = min.x; x < max.x; ++x) {
      neighbors.push_back( grid.get(x, max.y) );
   }
   if (boundary_flags & EDGE_LEFT)
   for (int y = min.y; y < max.y; ++y) {
      neighbors.push_back( grid.get(min.x - 1, y) );
   }
   if (boundary_flags & EDGE_RIGHT)
   for (int y = min.y; y < max.y; ++y) {
      neighbors.push_back( grid.get(max.x, y) );
   }
   return neighbors;
}

void ShipData::set_bounds(Vector2 bounds){
   if(bounds.x > ship_bounds_x.x){
      ship_bounds_x.x = bounds.x;
   }
   if(bounds.x < ship_bounds_x.y){
      ship_bounds_x.y = bounds.x;
   }

   if(bounds.y > ship_bounds_y.x){
      ship_bounds_y.x = bounds.y;
   }

   if(bounds.y < ship_bounds_y.y){
      ship_bounds_y.y = bounds.y;
   }

}

ShipData::PartError ShipData::add_part(Ref<PartData> part, Vector2 center, RotationState rotation_state) {
   if (part.is_null()) return IS_NULL;

   Vector2i size = get_grid_size(part->get_size(), rotation_state);
   center += get_grid_padding();
   Rect2i rect(center - 0.5 * static_cast<Vector2>(size), size);
   rect = rect.intersection(grid_region);
   part_regions.push_back(rect);
   part_centers.push_back(center);
   set_bounds(center);
   #if CHECK_FOR_PART_OVERLAP
   if ( !grid.is_empty_region(rect, NULL_PART_ID)) {
      error = OVERLAP;
      return NULL_PART_ID;
   }
   #endif // CHECK_FOR_PART_OVERLAP

   if (rect.size != size) return OUT_OF_BOUNDS;

   int part_id = part_clusters.new_set();
   parts.push_back(part);
   part_regions.push_back(rect);
   part_centers.push_back(center);
   part_rotation_states.push_back(rotation_state);
   add_stats(part, center);

   switch (part->get_behavior()) {
      case PartData::UNIQUE_DISCONNECTED:
         part_clusters.merge(part_id, NULL_PART_ID);
         unique_parts.push_back(part_id);
         return OKAY;
      case PartData::UNIQUE_CONNECTED:
         unique_parts.push_back(part_id);
      case PartData::STATIC:
         if ( !grid.is_empty_region(rect, NULL_PART_ID)) return OVERLAP;
   }

   grid.fill_rect(rect, part_id);
   for (int id: find_neighbors(part_id, FULL_PERIMETER)) {
      if (id != NULL_PART_ID) part_clusters.merge(part_id, id);
   }

   #if CPU_IMAGE_GENERATION
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
   }
   rect.position *= PartData::PX_PER_GRID_SQUARE;
   rect.size     *= PartData::PX_PER_GRID_SQUARE;
   image->blit_rect(part_image, {{0, 0}, rect.size}, rect.position);
   #endif // CPU_IMAGE_GENERATION

   return OKAY;
}
ShipData::PartError ShipData::add_part_node(Part* part) {
   if ( !part) return IS_NULL;

   Ref<PartData> data = part->get_data();
   double rotation    = part->get_rotation();
   bool flipped       = part->get_scale().x < 0;
   Vector2 position   = part->get_position() / PartData::PX_PER_GRID_SQUARE;
   return add_part(data, position, encode_rotation(rotation, flipped));
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
   thrust         += part->get_thrust();
   mass_offset    += part->get_mass() * center;
}
Vector2i ShipData::get_grid_size(Vector2i size, RotationState rotation_state) {
   return rotation_state % 2 == 0 ? size : Vector2i(size.height, size.width);
}
ShipData::RotationState ShipData::encode_rotation(double radians, bool flipped) {
   radians = Math::snapped(radians, PI_2);
   int quadrant = Math::wrapi(radians / PI_2, 0, 4);
   int encoding = quadrant + 4 * flipped;
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
   line[ROTATION_STATE] = String::num_int64(ship->part_rotation_states[part_id]);
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

String ShipManager::save_ship_string(Ref<ShipData>ship){

      String str = "NULL";
      if(ship==nullptr){return str;}
      str = "";
      String delim = ",";
   for (int id = ShipData::NULL_PART_ID + 1; id <= ship->count_parts(); ++id) {
     str += delim.join(to_csv_line(ship, id))+"\n";
   }
   return str; 
}