#include "packed_int32_grid.hpp"

using namespace godot;

const PackedByteArray PackedInt32Grid::to_byte_array() {
   return grid.to_byte_array();
}
int PackedInt32Grid::calculate_area() {
   return region.size.width * region.size.height;
}
bool PackedInt32Grid::encloses(Vector2i point) {
   return region.has_point(point);
}
Vector2i PackedInt32Grid::get_size() {
   return region.size;
}
void PackedInt32Grid::set_size(Vector2i new_size) {
   ERR_FAIL_COND(new_size.width < 0 || new_size.height < 0);
   region.size = new_size;
   grid.resize(calculate_area());
}
int32_t& PackedInt32Grid::operator[](Vector2i xy) {
   return grid[xy.x + xy.y * region.size.width];
}
void PackedInt32Grid::fill(int32_t new_value) {
   grid.fill(new_value);
}
bool PackedInt32Grid::fill_rect(Rect2i rect, int32_t new_value, int32_t null_value) {
   rect = rect.intersection(region);
   Vector2i min = rect.position;
   Vector2i max = min + rect.size;
   bool overlapped = false;
   for (int x = min.x; x < max.x; ++x) {
      for (int y = min.y; y < max.y; ++y) {
         int& cell = operator[]( {x, y} );
         overlapped |= (cell != null_value);
         cell = new_value;
      }
   }
   return overlapped;
}