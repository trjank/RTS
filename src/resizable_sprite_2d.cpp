#include "resizable_sprite_2d.hpp"

using namespace godot;

bool ResizableSprite2D::resize(Vector2 new_size) {
   Ref<Texture2D> texture = get_texture();

   if (texture.is_null()) return false;

   WARN_PRINT_ONCE_ED("<ResizeableSprite2D> Note that resize only rescales sprites");
   set_scale(new_size / texture->get_size() );
   return true;
}