#include "resizable_sprite_2d.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                resizable_sprite_2d.cpp                |
|                                                       |
*------------------------------------------------------*/

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