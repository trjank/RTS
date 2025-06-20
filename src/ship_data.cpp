#include "ship_data.hpp"
// needed to use math primitives on visual studio compiler...
#define _USE_MATH_DEFINES
#include <cmath>
#include <math.h>

using namespace godot;

int ShipData::count_parts() {
   return codes.size() - NUM_NULL_PARTS;
}
ShipData::State ShipData::get_state() {
   return state;
}
int ShipData::get_cost() {
   return cost;
}
double ShipData::get_max_warp() {
   return max_warp;
}
double ShipData::get_max_hp() {
   return max_hp;
}
double ShipData::get_max_shield() {
   return max_shield;
}
double ShipData::get_max_energy() {
   return max_energy;
}
double ShipData::get_turnrate() {
   return turnrate;
}
const PackedByteArray ShipData::get_index_buffer() {
   return index_grid.to_byte_array();
}
const PackedByteArray ShipData::get_rotation_buffer() {
   return rotation_states.to_byte_array();
}
const PackedByteArray ShipData::get_position_buffer() {
   return centers.to_byte_array();
}
void ShipData::clear_all_data() {
   rotation_states.clear();
   index_grid.fill(NULL_PART_ID);
   mass_offset = {0.0, 0.0};
   state = EMPTY;
}
void ShipData::assemble_from(Vector<Part*> parts) {
   clear_all_data();
   for (Part* const part: parts) {
      add_part_to_grid(part);
   }
}
ShipData::RotationState ShipData::encode_rotation(double radians, bool flipped) {
   constexpr int NUM_QUADRANTS = 4;
   int quadrant = Math::snapped(radians, M_PI_2) * M_2_PI;
   int encoding = quadrant + NUM_QUADRANTS * int(flipped);
   return static_cast<RotationState>(encoding);
}
void ShipData::update_adjacency_stats(int receiving_part, int giving_part) {
   // TODO
}
void ShipData::check_for_adjacent_part(int part_id, Vector2i xy) {
   if ( !index_grid.encloses(xy)) return;

   int adjacent_part_id = index_grid[xy];
   part_clusters.merge(part_id, adjacent_part_id);
   update_adjacency_stats(part_id, adjacent_part_id);
   update_adjacency_stats(adjacent_part_id, part_id);
}
void ShipData::check_for_adjacent_parts(int part_id, Rect2i rect) {
   Vector2i min = rect.position;
   Vector2i max = min + rect.size;
   for (int x = min.x; x < max.x; ++x) {
      // Check above the part's top edge
      check_for_adjacent_part(part_id, {x, min.y - 1} );
      // Check below the part's bottom edge
      check_for_adjacent_part(part_id, {x, max.y} );
   }
   for (int y = min.y; y < max.y; ++y) {
      // Check next to the part's left edge
      check_for_adjacent_part(part_id, {min.x - 1, y} );
      // Check next to the part's right edge
      check_for_adjacent_part(part_id, {max.x, y} );
   }
}
void ShipData::add_part_to_grid(Ref<PartData> part, Vector2 center, RotationState rotation_state) {
   ERR_FAIL_COND(part.is_null());

   codes.push_back(part->get_code());
   rotation_states.push_back(rotation_state);
   cost += part->get_cost();
   mass += part->get_mass();
   mass_offset += part->get_mass() * center;
   center_of_mass = mass_offset / mass;

   // Multiples of 180 degrees do not affect the part's bounding box
   // However, 90 and 270 degree rotations flip the width and height
   Vector2i size = part->get_size();
   if (rotation_state % 2 == 1) size = {size.height, size.width};

   int part_id = part_clusters.new_set();
   Vector2i top_left_corner = center - 0.5 * size;
   Rect2i part_rect(top_left_corner, size);
   bool overlapped = index_grid.fill_rect(part_rect, part_id, NULL_PART_ID);
   check_for_adjacent_parts(part_id, part_rect);

   if (unlikely(state == EMPTY)) state = VALID;
   if (overlapped) state = PART_OVERLAP;
   if (part_clusters.count_num_sets() != 1) state = PARTS_DISCONNECTED;
}
void ShipData::add_part_to_grid(Part* part) {
   ERR_FAIL_COND( !part);

   bool rotation = part->get_rotation();
   bool flipped  = part->get_scale().x < 0;
   RotationState state = encode_rotation(rotation, flipped);
   add_part_to_grid(part->get_data(), part->get_position(), state);
}
String ShipData::get_error_message() {
   switch (state) {
      case VALID: return "";
      case EMPTY: return "No parts found";
      case PART_OVERLAP: return "Parts are overlapping!";
      case PARTS_DISCONNECTED: return "Ship is not connected!";
   }
}


ShipManager::ShipManager() {
   part_manager.instantiate();
   part_manager->new_part("NULL");
}
Ref<PartManager> ShipManager::get_part_manager() {
   WARN_PRINT_ED("NOTE: Do NOT add or remove parts while ships are active!");
   return part_manager;
}
int ShipManager::get_num_hotbar_slots() {
   return hotbar.size();
}
int ShipManager::get_num_turret_slots() {
   return turrets.size();
}
Ref<ShipData> ShipManager::get_capital_ship() {
   return capital_ship;
}
Ref<ShipData> ShipManager::get_hotbar_slot(int slot) {
   return hotbar[slot];
}
Ref<ShipData> ShipManager::get_turret_slot(int slot) {
   return turrets[slot];
}
void ShipManager::set_num_hotbar_slots(int slots) {
   hotbar.resize(Math::min(slots, MAX_NUM_HOTBAR_SLOTS));
}
void ShipManager::set_num_turret_slots(int slots) {
   turrets.resize(Math::min(slots, MAX_NUM_TURRET_SLOTS));
}
void ShipManager::set_capital_ship(Ref<ShipData> ship) {
   capital_ship = ship;
}
void ShipManager::set_hotbar_slot(int slot, Ref<ShipData> ship) {
   hotbar.set(slot, ship);
}
void ShipManager::set_turret_slot(int slot, Ref<ShipData> turret) {
   turrets.set(slot, turret);
}
void ShipManager::load_part_into_ship(Ref<ShipData> ship, PackedStringArray csv_line) {
   Ref<PartData> part = part_manager->lookup_code(csv_line[0]);
   float x = csv_line[1].to_float();
   float y = csv_line[2].to_float();
   auto rotation_state = static_cast<ShipData::RotationState>(csv_line[3].to_int());
   ship->add_part_to_grid(part, {x, y}, rotation_state);
}
Ref<ShipData> ShipManager::load_ship(String csv_path) {
   Ref<FileAccess> file = FileAccess::open(csv_path, FileAccess::READ);
   if (file->get_csv_line() != CSV_COLUMNS) {
      WARN_PRINT_ED("Ship csv header is incorrect (failed to load)");
      return nullptr;
   }
   Ref<ShipData> ship;
   ship.instantiate();
   while ( !file->eof_reached()) {
      load_part_into_ship(ship, file->get_csv_line());
   }
   file->close();
   return ship;
}
PackedStringArray ShipManager::to_csv_line(Ref<ShipData> ship, int part_id) {
   return {
      ship->codes[part_id],
      String::num(ship->centers[part_id].x),
      String::num(ship->centers[part_id].y),
      String::num_int64(ship->rotation_states[part_id])
   };
}
void ShipManager::save_ship(Ref<ShipData> ship, String csv_path) {
   Ref<FileAccess> csv = FileAccess::open(csv_path, FileAccess::WRITE);
   csv->store_csv_line(CSV_COLUMNS);
   for (int part_id = NUM_NULL_PARTS; part_id <= ship->count_parts(); ++part_id) {
      csv->store_csv_line(to_csv_line(ship, part_id));
   }
   csv->close();
}