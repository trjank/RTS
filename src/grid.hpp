#ifndef GRID_HPP
#define GRID_HPP

#include <godot_cpp/variant/rect2i.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "defaults.hpp"

namespace godot {

struct Grid {
   static Grid create(int width, int height);

   void fill(int value);
   const Rect2i& get_rect() const;
   NO_ERROR_CHECK void fill_rect(const Rect2i& rect, const int value);
   NO_ERROR_CHECK bool rect_is_value(const Rect2i& rect, const int& value) const;
   NO_ERROR_CHECK int get(int x, int y) const;
   NO_ERROR_CHECK int getv(Vector2i xy) const;
   NO_ERROR_CHECK void set(int x, int y, int value);
   NO_ERROR_CHECK void setv(Vector2i, int value);
private:
   Vector<int> data;
   Rect2i rect = {0, 0, 0, 0};

   int index_of(int x, int y) const;
};

}

#endif // GRID_HPP