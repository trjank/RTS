#include "packed_int32_grid.hpp"

using namespace godot;

PackedInt32Grid PackedInt32Grid::create(int width, int height) {
   PackedInt32Grid new_grid;
   /*------------------------------------------------------*
   | FORMAT_RF stores a single 32-bit float channel (red). |
   | Note that we are really storing 32-bit integers, and  |
   | the 32-bit floats are just placeholder types.         |
   *------------------------------------------------------*/
   new_grid.grid = Image::create(width, height, true, Image::FORMAT_RF);
   return new_grid;
}
PackedInt32Grid PackedInt32Grid::createv(Vector2i size) {
   return create(size.width, size.height);
}
void PackedInt32Grid::fill(int32_t integer) {
   grid->fill(encode(integer));
}
void PackedInt32Grid::fill_rect(Rect2i rect, int32_t integer) {
   grid->fill_rect(rect, encode(integer));
}
PackedByteArray PackedInt32Grid::to_byte_buffer() {
   return grid->get_data();
}
int32_t PackedInt32Grid::get(int x, int y) {
   return decode(grid->get_pixel(x, y));
}
int32_t PackedInt32Grid::getv(Vector2i point) {
   return decode(grid->get_pixelv(point));
}
void PackedInt32Grid::set(Vector2i point, int32_t integer) {
   grid->set_pixelv(point, encode(integer));
}
int32_t PackedInt32Grid::decode(Color color) {
   return *(int32_t*) &(color.r);
}
Color PackedInt32Grid::encode(int32_t integer) {
   float red_channel = *(float*) &integer;
   return {red_channel, 0.0f, 0.0f, 1.0f};
}
bool PackedInt32Grid::is_empty() {
   return grid->is_empty();
}
bool PackedInt32Grid::is_empty_region(Rect2i region, int32_t _null_value) {
   Vector2i min = region.position;
   Vector2i max = region.get_end();
   /*------------------------------------------------------*
   | The Image class has the is_invisible() method, but    |
   | since this is not FORMAT_RF compatible (no alpha      |
   | channel), we have to define our own.                  |
   *------------------------------------------------------*/
   for (int x = min.x; x < max.x; ++x) {
      for (int y = min.y; y < max.y; ++y) {
         if (unlikely( get(x, y) != _null_value )) return false;
      }
   }
   return true;
}