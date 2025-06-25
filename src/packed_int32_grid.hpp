#ifndef PACKED_INT32_GRID_HPP
#define PACKED_INT32_GRID_HPP

#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/rect2i.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include "part.hpp"

namespace godot {

/*------------------------------------------------------*
| Godot does not provide integer type support for       |
| image classes, despite the existence of usampler2D    |
| and isampler2D within the shading language. We can    |
| still use the Image class, but integers need to be    |
| casted to or from colors before they can be used,     |
| which the wrapper below will do for you.              |
*------------------------------------------------------*/
struct PackedInt32Grid {
   static PackedInt32Grid create(int width, int height);
   static PackedInt32Grid createv(Vector2i size);

   void fill(int32_t integer);
   void fill_rect(Rect2i rect, int32_t integer);
   PackedByteArray to_byte_buffer();
   int32_t get(int x, int y);
   int32_t getv(Vector2i point);
   void set(Vector2i coords, int32_t integer);
   bool is_empty();
   bool is_empty_region(Rect2i region, int32_t _null_value = 0);
private:
   Ref<Image> grid;

   _FORCE_INLINE_ int32_t decode(Color color);
   _FORCE_INLINE_ Color encode(int32_t integer);
};

}

#endif // PACKED_INT32_GRID_HPP