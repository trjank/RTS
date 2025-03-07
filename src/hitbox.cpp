#include "hitbox.hpp"

void Hitbox::calculate_size() {
   size = cells.count();
}
int Hitbox::get_size() {
   return size;
}
bool Hitbox::inside_grid(Vector2i coords) {
   bool x_valid = 0 <= coords.x && coords.x < WIDTH;
   bool y_valid = 0 <= coords.y && coords.y < HEIGHT;
   return x_valid && y_valid;
}
int Hitbox::to_index_1D(Vector2i coords) {
   return coords.x + WIDTH * coords.y;
}
bool Hitbox::contains(Vector2i coords) {
   return inside_grid(coords) && cells[to_index_1D(coords)];
}
void Hitbox::insert(Vector2i coords, bool value) {
   ERR_FAIL_COND_MSG( !inside_grid(coords),
                     "(Hitbox::insert) Out of bounds coordinates");
   cells[to_index_1D(coords)] = value;
}
void Hitbox::merge(Ref<Hitbox> hitbox) {
   if (hitbox.is_valid()) cells |= hitbox->cells;
}
void Hitbox::remove(Ref<Hitbox> hitbox) {
   if (hitbox.is_valid()) cells &= hitbox->cells;
}