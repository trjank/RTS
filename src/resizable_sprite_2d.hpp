#ifndef RESIZABLE_SPRITE_2D_HPP
#define RESIZABLE_SPRITE_2D_HPP

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {

class ResizableSprite2D : public Sprite2D {
   GDCLASS(ResizableSprite2D, Sprite2D)
public:
   /*------------------------------------------------------|
	| This only rescales the sprite. If you change the      |
   | scale, the size will not be preserved.                |
	|------------------------------------------------------*/
   bool resize(Vector2 new_size);
   void reset_to_default_size();
protected:
   static void _bind_methods();
};

}

#endif // RESIZABLE_SPRITE_2D_HPP