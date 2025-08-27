#include "grid.hpp"

using namespace godot;

Grid Grid::create(int width, int height) {
   Grid grid;

   grid.rect.size = {width, height};
   grid.data.resize(width * height);
   return grid;
}
int Grid::index_of(int x, int y) const {
   return x + y * rect.size.width;
}
void Grid::fill(int value) {
   data.fill(value);
}
const Rect2i& Grid::get_rect() const {
   return rect;
}
NO_ERROR_CHECK int Grid::get(int x, int y) const {
   return data.get( index_of(x, y) );
}
NO_ERROR_CHECK int Grid::getv(Vector2i xy) const {
   return data.get( index_of(xy.x, xy.y) );
}
NO_ERROR_CHECK void Grid::set(int x, int y, int value) {
   data.set(index_of(x, y), value);
}
NO_ERROR_CHECK void Grid::setv(Vector2i xy, int value) {
   data.set(index_of(xy.x, xy.y), value);
}
NO_ERROR_CHECK void Grid::fill_rect(const Rect2i& rect, const int value) {
   Vector2 min = rect.position;
   Vector2 max = rect.get_end();

   for (int x = min.x; x < max.x; ++x) {
      for (int y = min.y; y < max.y; ++y) {
         data.set(index_of(x, y), value);
      }
   }
}
NO_ERROR_CHECK bool Grid::rect_is_value(const Rect2i& rect, const int& value) const {
   Vector2 min = rect.position;
   Vector2 max = rect.get_end();

   for (int x = min.x; x < max.x; ++x) {
      for (int y = min.y; y < max.y; ++y) {
         if (unlikely( get(x, y) != value )) return false;
      }
   }
   return true;
}