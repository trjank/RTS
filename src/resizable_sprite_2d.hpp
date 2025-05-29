#ifndef RESIZABLE_SPRITE_2D_HPP
#define RESIZABLE_SPRITE_2D_HPP

#include <godot_cpp/classes/sprite2d.hpp>

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                resizable_sprite_2d.hpp                |
|                                                       |
*------------------------------------------------------*/

using godot::Sprite2D;
using godot::Vector2;
using godot::Texture2D;
using godot::Ref;
using godot::Rect2;

class ResizableSprite2D : public Sprite2D {
   GDCLASS(ResizableSprite2D, Sprite2D);
public:
   void resize_scaled(Vector2 new_size);
   void resize_region(Vector2 new_size);
protected:
   static void _bind_methods();
};

#endif // RESIZABLE_SPRITE_2D_HPP