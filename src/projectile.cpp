#include "projectile.hpp"

using namespace godot;


Projectile* Projectile::create_from(Ref<ProjectileData> data) {
   Projectile* projectile = memnew(Projectile);

   projectile->data = data;
   projectile->set_texture( data->get_texture() );
   projectile->hitbox->set_size( data->get_size_px() );

   return projectile;
}
Projectile::Projectile() {
   add_child(collision_shape, false, INTERNAL_MODE_FRONT);
   collision_shape->set_shape(hitbox);
}
Ref<ProjectileData> Projectile::get_data() const {
   return data;
}
double Projectile::get_lifespan_sec() const {
   return lifespan_sec;
}
double Projectile::get_time_lived_sec() const {
   return time_lived_sec;
}
double Projectile::get_safe_scale() const {
   return safe_scale;
}
void Projectile::set_lifespan_sec(double new_lifespan_sec) {
   lifespan_sec = Math::max(0.0, new_lifespan_sec);
}
void Projectile::set_safe_scale(double new_safe_scale) {
   safe_scale = new_safe_scale;
   hitbox->set_size(data->get_size_px() * safe_scale);
   resize_image(data->get_size_px() * safe_scale);
}
void Projectile::_physics_process(double dt) {
   if ( (time_lived_sec += dt) > lifespan_sec) kill();
}