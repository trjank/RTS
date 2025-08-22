#include "projectile.hpp"

using namespace godot;


Projectile* Projectile::create_from(Ref<ProjectileData> data) {
   Projectile* projectile = memnew(Projectile);

   projectile->data = data;
   projectile->hp = data->get_hp();
   projectile->set_texture( data->get_texture() );
   projectile->hitbox->set_size( PartData::to_world_vec(data->get_size()) );

   return projectile;
}
Projectile::Projectile() {
   set_contact_monitor(true);
   connect("body_shape_entered", Callable(this, "_on_body_shape_entered"));
   collision_shape->set_shape(hitbox);
   add_child(collision_shape, false, INTERNAL_MODE_FRONT);
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
   Vector2 size = PartData::to_world_vec(data->get_size());
   resize_image(size * safe_scale);
   hitbox->set_size(size * safe_scale);
}
void Projectile::_on_body_shape_entered(RID body_rid, Node* body, int body_shape_index, int local_shape_index) {
   Ship* ship = Object::cast_to<Ship>(body);

   ERR_FAIL_NULL_MSG(ship, "<Projectile> Non-ship detected (change the collision mask)");

   ship->set_kill_credit( get_radar_signature() );
   // ship->hit(damage, penetration);
   hit(1.0);
}
void Projectile::_physics_process(double dt) {
   if ( (time_lived_sec += dt) > lifespan_sec) kill();
}


Laser* Laser::create_from(Ref<ProjectileData> data) {
   Laser* laser = memnew(Laser);

   return laser;
}
Laser::Laser() {
   set_begin_cap_mode(LINE_CAP_ROUND);
   set_end_cap_mode(LINE_CAP_ROUND);
}
void Laser::begin_arc_at(Vector2 position, double duration_sec) {
   Ref<Tween> tween = create_tween();

   tween->tween_callback( Callable(this, "queue_free") );
   tween->tween_property(this, "default_color", FADE_COLOR, duration_sec);

   clear_points();
   add_point(position);
}
void Laser::set_glow(float strength) {
   set_self_modulate( Color(strength, strength, strength) );
}
void Laser::arc_to(Ref<Unit::RadarSignature> unit) {
   // if (current >= max || !unit->is_alive()) return;

   // Vector2 position = unit->get_position();
   // Vector2 previous = get_point_position(-1);

   // if (previous.distance_to(position) > max_distance) return;

   // unit->unwrap()->hit(damage);
   // add_point(position);
   // arc_to(unit->get_nearest_unit());
}