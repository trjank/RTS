#ifndef RESIZABLE_SPRITE_2D_HPP
#define RESIZABLE_SPRITE_2D_HPP

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {

class ResizableSprite2D : public Sprite2D {
   GDCLASS(ResizableSprite2D, Sprite2D)
public:
   void resize_scaled(Vector2 new_size);
   void resize_region(Vector2 new_size);
protected:
   static void _bind_methods();
};

}

#endif // RESIZABLE_SPRITE_2D_HPP