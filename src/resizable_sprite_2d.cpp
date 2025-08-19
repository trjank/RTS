#include "resizable_sprite_2d.hpp"

using namespace godot;

bool ResizableSprite2D::resize(Vector2 new_size) {
   Ref<Texture2D> texture = get_texture();

   if (texture.is_null()) return false;

   set_scale(new_size / texture->get_size());
   return true;
}
void ResizableSprite2D::reset_to_default_size() {
   set_scale( {1.0, 1.0} );
}