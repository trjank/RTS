#ifndef PACKED_INT32_GRID_HPP
#define PACKED_INT32_GRID_HPP

#include "part.hpp"

namespace godot {

struct PackedInt32Grid {
   const PackedByteArray to_byte_array();
   bool encloses(Vector2i point);
   int calculate_area();
   int32_t& operator[](Vector2i xy);
   Vector2i get_size();
   void set_size(Vector2i new_size);
   void fill(int32_t new_value);
   // fill_rect returns false if every overwritten value was previously null_value
   // fill_rect returns true if any overwritten cell value was not null_value
   // This is useful for checking for overlap when filling in the grid
   bool fill_rect(Rect2i rect, int32_t new_value, int32_t null_value = 0);
private:
   Rect2i region;
   PackedInt32Array grid;
};

}

#endif // PACKED_INT32_GRID_HPP