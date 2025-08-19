#include "ship_data.hpp"
// needed to use math primitives on visual studio compiler...
#define _USE_MATH_DEFINES
#include <cmath>
#include <math.h>

using namespace godot;

constexpr double PI_2 = 0.5 * Math_PI;

Ref<ShipData> ShipData::create(int grid_width, int grid_height) {
   Ref<ShipData> ship = memnew(ShipData);

   /*------------------------------------------------------|
   | Because of the padding, the top left corner is really |
   | (1, 1). Keep this in mind for the functions below.    |
   |------------------------------------------------------*/
   int padded_width  = 2 * GRID_PADDING + grid_width;
   int padded_height = 2 * GRID_PADDING + grid_height;
   ship->grid_region = {GRID_PADDING, GRID_PADDING, grid_width, grid_height};
   ship->grid        = PackedInt32Grid::create(padded_width, padded_height);

   #if CPU_IMAGE_GENERATION
   padded_width  *= PartData::PX_PER_GRID_SQUARE;
   padded_height *= PartData::PX_PER_GRID_SQUARE;
   ship->image    = Image::create(padded_width, padded_height, true, Image::FORMAT_RGBA8);
   #endif // CPU_IMAGE_GENERATION

   return ship;
}
ShipData::RotationState ShipData::encode_rotation(double radians, bool flipped) {
   int quadrant = Math::posmod(0.5 + radians / PI_2, 4);
   int encoding = quadrant + FLIPPED_ROT_0_DEG * flipped;
   return static_cast<RotationState>(encoding);
}
ShipData::ShipData() {
   part_clusters.new_set();
}
int ShipData::count_parts() const
{
   return parts.size() - NUM_NULL_PARTS;
}
bool ShipData::is_empty() const {
   return count_parts() == 0;
}
bool ShipData::is_connected() const
{
   return part_clusters.count_num_sets() == NUM_NULL_PARTS + 1;
}
bool ShipData::has_part(int part_id) const {
   return NULL_PART_ID < part_id && part_id < parts.size();
}
Rect2i ShipData::get_grid_region() const {
   return grid_region;
}
Rect2i ShipData::get_ship_region() const {
   return ship_region;
}
int ShipData::get_cost() const
{
   return cost;
}
double ShipData::get_max_hp() const
{
   return max_hp;
}
double ShipData::get_max_warp() const
{
   return max_warp;
}
double ShipData::get_max_shield() const
{
   return max_shield;
}
double ShipData::get_max_energy() const
{
   return max_energy;
}
double ShipData::get_warp_per_sec() const
{
   return warp_per_sec;
}
double ShipData::get_shield_per_sec() const
{
   return shield_per_sec;
}
double ShipData::get_energy_per_sec() const
{
   return energy_per_sec;
}
double ShipData::get_thrust() const
{
   return thrust;
}
double ShipData::get_turnrate() const
{
   return turnrate;
}
Vector2 ShipData::get_center_of_mass() const {
   return center_of_mass;
}
Ref<Image> ShipData::get_image() const
{
   return image;
}
Ref<ImageTexture> ShipData::get_texture() const {
   return ImageTexture::create_from_image(image);
}
PackedInt32Array ShipData::get_unique_parts() {
   return unique_parts;
}
int ShipData::get_part_at(Vector2i location) const {
   return grid_region.has_point(location) ? grid.getv(location) : NULL_PART_ID;
}
ShipData::RotationState ShipData::get_part_rotation_state(int part_id) const {
   ERR_FAIL_COND_V_MSG( !has_part(part_id), ROT_0_DEG,
   "<ShipData> part not found (failed to get rotation state)");

   return part_rotation_states[part_id];
}
Vector2 ShipData::get_part_center(int part_id) const {
   ERR_FAIL_COND_V_MSG( !has_part(part_id), Vector2(0.0, 0.0),
   "<ShipData> part not found (failed to get part center)");

   return part_centers[part_id];
}
Rect2i ShipData::get_part_region(int part_id) const {
   ERR_FAIL_COND_V_MSG( !has_part(part_id), Rect2i(0, 0, 0, 0),
   "<ShipData> part not found (failed to get part region)");

   return part_regions[part_id];
}
Ref<PartData> ShipData::get_part_data(int part_id) const {
   ERR_FAIL_COND_V_MSG( !has_part(part_id), nullptr,
   "<ShipData> part not found (failed to get part data)");

   return parts[part_id];
}
void ShipData::set_image(Ref<Image> new_image) {
   ERR_FAIL_NULL_MSG(new_image,
   "<ShipData> Image is null (failed to set image)");

   image = new_image;
}
NO_ERROR_CHECK PackedInt32Array ShipData::find_neighbors(int part_id, int boundary_flags) const {
   PackedInt32Array neighbors;
   Vector2i min = part_regions[part_id].position;
   Vector2i max = part_regions[part_id].get_end();

   /*------------------------------------------------------|
   | Empty spaces are still counted as neighbors. This     |
   | is useful for parts like thrusters.                   |
   |------------------------------------------------------*/
   if (boundary_flags & EDGE_TOP)
      for (int x = min.x; x < max.x; ++x)
      {
         neighbors.push_back(grid.get(x, min.y - 1));
      }
   if (boundary_flags & EDGE_BOTTOM)
      for (int x = min.x; x < max.x; ++x)
      {
         neighbors.push_back(grid.get(x, max.y));
      }
   if (boundary_flags & EDGE_LEFT)
      for (int y = min.y; y < max.y; ++y)
      {
         neighbors.push_back(grid.get(min.x - 1, y));
      }
   if (boundary_flags & EDGE_RIGHT)
      for (int y = min.y; y < max.y; ++y)
      {
         neighbors.push_back(grid.get(max.x, y));
      }
   return neighbors;
}

void ShipData::set_bounds(Vector2 bounds)
{
   if (bounds.x > ship_bounds_x.x)
   {
      ship_bounds_x.x = bounds.x;
   }
   if (bounds.x < ship_bounds_x.y)
   {
      ship_bounds_x.y = bounds.x;
   }

   if (bounds.y > ship_bounds_y.x)
   {
      ship_bounds_y.x = bounds.y;
   }

   if (bounds.y < ship_bounds_y.y)
   {
      ship_bounds_y.y = bounds.y;
   }
}

ShipData::PartError ShipData::add_part(Ref<PartData> part, Vector2 center, RotationState rotation_state)
{
   if (part.is_null())
      return IS_NULL;

   Vector2i size = part->get_size();
   if (rotation_state % 2 == 0) SWAP(size.width, size.height);

   // Vector2i size   = transform_size(part->get_size(), rotation_state);
   Vector2i corner = center - 0.5 * static_cast<Vector2>(size);
   Rect2i rect     = Rect2i(corner, size).intersection(grid_region);

   if (rect.size != size)
      return OUT_OF_BOUNDS;

   int part_id = part_clusters.new_set();

   parts.push_back(part);
   part_centers.push_back(center);
   part_regions.push_back(rect);
   part_rotation_states.push_back(rotation_state);
   add_stats(part);
   
   mass_offset    += part->get_mass() * center;
   center_of_mass  = mass_offset / mass;

   switch (part->get_behavior()) {
      case PartData::UNIQUE_DISCONNECTED:
         part_clusters.merge(part_id, NULL_PART_ID);
         unique_parts.push_back(part_id);
         return OKAY;
      case PartData::UNIQUE_CONNECTED:
         unique_parts.push_back(part_id);
      case PartData::STATIC:
         if ( !grid.is_empty_region(rect, NULL_PART_ID)) return OVERLAP;

         place_on_grid(part_id, rect);
         draw_part(part->get_image(), rect, rotation_state);
      default:
         return OKAY;
   }
}
ShipData::PartError ShipData::add_part_node(Part* part) {
   if ( !part) return IS_NULL;

   Ref<PartData> data = part->get_data();
   bool flipped       = part->get_scale().x < 0;
   double rotation    = part->get_rotation();
   Vector2 position   = part->get_position() / PartData::PX_PER_GRID_SQUARE;

   if (part->get_scale().y < 0) {
      rotation += Math_PI;
      flipped = !flipped;
   }

   return add_part(data, position, encode_rotation(rotation, flipped));
}
void ShipData::add_stats(Ref<PartData> part) {
   thrust         += part->get_thrust();
   cost           += part->get_cost();
   mass           += part->get_mass();
   max_warp       += part->get_warp();
   max_shield     += part->get_shield();
   max_energy     += part->get_energy();
   warp_per_sec   += part->get_warp_per_sec();
   shield_per_sec += part->get_shield_per_sec();
   energy_per_sec += part->get_energy_per_sec();
}
void ShipData::place_on_grid(int part_id, Rect2i rect) {
   grid.fill_rect(rect, part_id);
   ship_region = count_parts() == 1 ? rect : ship_region.merge(rect);
   /*------------------------------------------------------|
   | Every part starts out as its own set. We union        |
   | adjacent sets to figure out if the ship is connected. |
   |------------------------------------------------------*/
   for (int id: find_neighbors(part_id, FULL_PERIMETER)) {
      if (id != NULL_PART_ID) part_clusters.merge(part_id, id);
   }
}
Vector2i ShipData::transform_size(Vector2i size, RotationState rotation_state) {
   return rotation_state % 2 == 0 ? size : Vector2i(size.height, size.width);
}
NO_ERROR_CHECK void ShipData::draw_part(Ref<Image> part_image, Rect2i rect, RotationState rotation_state) {

   #if CPU_IMAGE_GENERATION
   // No need to waste time or memory on default orientation
   if (rotation_state != ROT_0_DEG) part_image = part_image->duplicate();
   /*------------------------------------------------------|
   | Image flip_x, rotate_90, rotate_180, and blit_rect    |
   | functions all iterate over every pixel. This is       |
   | expensive, so you may want to use a compute shader.   |
   |------------------------------------------------------*/
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
   /*------------------------------------------------------|
   | For this to work, the part image size must be         |
   | consistent with PartData::PX_PER_GRID_SQUARE. The     |
   | scale will not automatically be fixed.                |
   |------------------------------------------------------*/
   rect.position *= PartData::PX_PER_GRID_SQUARE;
   rect.size *= PartData::PX_PER_GRID_SQUARE;
   image->blit_rect(part_image, {{0, 0}, rect.size}, rect.position);
#endif // CPU_IMAGE_GENERATION

}

ShipManager::ShipManager()
{
   part_manager.instantiate();
   part_manager->new_part("NULL");
}
void ShipManager::set_part_manager(Ref<PartManager> new_part_manager) {
   part_manager = new_part_manager;
}
void ShipManager::load_part_into_ship(Ref<ShipData> ship, PackedStringArray csv_line) {
   Ref<PartData> part = part_manager->lookup_code(csv_line[CODE]);
   float x = csv_line[X].to_float();
   float y = csv_line[Y].to_float();
   int rotation_state = csv_line[ROTATION_STATE].to_int();
   ship->add_part(part, {x, y}, static_cast<ShipData::RotationState>(rotation_state));
}
Ref<ImageTexture> ShipManager::load_ship_image(String path)
{
   return ResourceLoader::get_singleton()->load(path);
}
Ref<ShipData> ShipManager::load_ship_csv(int width, int height, String path) {
   Ref<ShipData> ship   = ShipData::create(width, height);
   Ref<FileAccess> file = FileAccess::open(path, FileAccess::READ);

   ERR_FAIL_COND_V_MSG(file.is_null(), ship,
                       "<ShipData> Ship csv file not found (failed to load csv)");
   ERR_FAIL_COND_V_MSG(file->get_csv_line() != CSV_HEADER, ship,
                       "<ShipData> Ship csv header is incorrect (failed to load csv)");

   while (!file->eof_reached())
   {
      load_part_into_ship(ship, file->get_csv_line());
   }
   return ship;
}
PackedStringArray ShipManager::to_csv_line(Ref<ShipData> ship, int part_id)
{
   PackedStringArray line;
   line.resize(NUM_PROPERTIES);
   line[CODE] = ship->parts[part_id]->get_code();
   line[X] = String::num(ship->part_centers[part_id].x);
   line[Y] = String::num(ship->part_centers[part_id].y);
   line[ROTATION_STATE] = String::num_int64(ship->part_rotation_states[part_id]);
   return line;
}
void ShipManager::save_ship_image(Ref<ShipData> ship, String path)
{
   ERR_FAIL_NULL_MSG(ship,
                     "<ShipManager> Ship is null (failed to save image)");
   ERR_FAIL_NULL_MSG(ship->get_image(),
                     "<ShipManager> Ship has no image (failed to save image)");
   ERR_FAIL_COND_MSG(!path.ends_with(".png"),
                     "<ShipManager> Ship images can only be saved as .png (failed to save image)");

   ship->get_image()->save_png(path);
}
void ShipManager::save_ship_csv(Ref<ShipData> ship, String path)
{
   ERR_FAIL_NULL_MSG(ship,
                     "<ShipManager> Ship is null (failed to save csv)");
   ERR_FAIL_COND_MSG(!path.ends_with(".csv"),
                     "<ShipManager> Ships can only be saved as a .csv file (failed to save csv)");

   Ref<FileAccess> csv = FileAccess::open(path, FileAccess::WRITE);
   csv->store_csv_line(CSV_HEADER);
   for (int id = ShipData::NULL_PART_ID + 1; id <= ship->count_parts(); ++id)
   {
      csv->store_csv_line(to_csv_line(ship, id));
   }
}

String ShipManager::save_ship_string(Ref<ShipData> ship)
{

   String str = "NULL";
   if (ship == nullptr)
   {
      return str;
   }
   str = "";
   String delim = ",";
   for (int id = ShipData::NULL_PART_ID + 1; id <= ship->count_parts(); ++id)
   {
      str += delim.join(to_csv_line(ship, id)) + "\n";
   }
   return str;
}