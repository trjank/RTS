#include "resizable_sprite_2d.hpp"

using namespace godot;

void ResizableSprite2D::resize_scaled(Vector2 new_size) {
   Ref<Texture2D> texture = get_texture();
   ERR_FAIL_COND(texture.is_null());
   set_scale(new_size / texture->get_size());
}
void ResizableSprite2D::resize_region(Vector2 new_size) {
   Rect2 region = get_region_rect();
   region.set_size(new_size);
   set_region_rect(region);
}