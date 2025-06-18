#include <godot_cpp/core/math.hpp>
#include "celestial.hpp"

using namespace godot;

double Orbit::time_scale = 1.0;
double Orbit::gravity_scale = 1.0;

double Orbit::get_time_scale() {
   return time_scale;
}
double Orbit::get_gravity_scale() {
   return gravity_scale;
}
void Orbit::set_time_scale(double new_scale) {
   time_scale = Math::clamp(new_scale, MIN_TIME_SCALE, MAX_TIME_SCALE);
}
void Orbit::set_gravity_scale(double new_scale) {
   gravity_scale = Math::clamp(new_scale, MIN_GRAVITY_SCALE, MAX_GRAVITY_SCALE);
}
double Orbit::get_distance() {
   return distance;
}
double Orbit::get_angular_velocity() {
   if ( !orbiting) return 0.0;

   double scaled_G = gravity_scale * GRAVITATIONAL_CONSTANT;
   return sqrt(scaled_G * orbiting->mass / distance);
}
void Orbit::set_angle(Node2D* orbiter, double angle) {
   ERR_FAIL_COND( !orbiter);

   orbiter->set_position(distance * Vector2::from_angle(angle));
}
void Orbit::fix_distance(Node2D* orbiter) {
   ERR_FAIL_COND( !orbiter);

   Vector2 direction = orbiter->get_position();
   if (direction.is_zero_approx())
      direction = {1.0, 0.0};
   else
      direction.normalize();
   orbiter->set_position(distance * direction);
}
void Orbit::set_distance(double new_distance) {
   distance = Math::max(new_distance, MIN_DISTANCE);
   queue_redraw();
   TypedArray<Node2D> children = get_children();
   for (int n = 0; n < children.size(); ++n) {
      fix_distance( Object::cast_to<Node2D>(children[n]) );
   }
}
void Orbit::set_path_visibility(bool visible) {
   path_visible = visible;
   queue_redraw();
}
void Orbit::orbit(Celestial* celestial) {
   ERR_FAIL_COND( !celestial);

   reparent(celestial);
   orbiting = celestial;
}
void Orbit::add(Node2D* orbiter, double angle) {
   if ( !orbiter) return;

   add_child(orbiter);
   set_angle(orbiter, angle);
}
void Orbit::_physics_process(double dt) {
   rotate(get_angular_velocity() * time_scale * dt);
}
void Orbit::_draw() {
   if (path_visible)
      draw_arc({0.0, 0.0}, distance, 0.0, Math_TAU, NUM_SEGMENTS, COLOR, THICKNESS, true);
}


double Celestial::alloy_abundance = 1.0;
double Celestial::energy_abundance = 1.0;

Celestial::Celestial() {
   CollisionShape2D* shape = memnew(CollisionShape2D);
   add_child(capture_zone = memnew(Area2D));
   add_child(image = memnew(ResizableSprite2D));
   capture_zone->add_child(shape);
   hitbox.instantiate();
   shape->set_shape(hitbox);
}
bool Celestial::can_capture() {
   return true;
}
double Celestial::get_mass() {
   return mass;
}
double Celestial::get_radius() {
   return radius;
}
double Celestial::get_angular_velocity() {
   return angular_velocity;
}
double Celestial::get_alloy_per_sec() {
   return surface_area * alloy_density * alloy_abundance;
}
double Celestial::get_energy_per_sec() {
   return surface_area * energy_density * energy_abundance;
}
Ref<Texture2D> Celestial::get_texture() {
   return image->get_texture();
}
void Celestial::set_alloy_density(double density) {
   alloy_density = density;
}
void Celestial::set_energy_density(double density) {
   energy_density = density;
}
void Celestial::set_angular_velocity(double new_angular_velocity) {
   angular_velocity = new_angular_velocity;
}
void Celestial::set_angular_offset(double angle) {
   Vector2 direction = Vector2::from_angle(angle);
   set_position(get_position().length() * direction);
}
void Celestial::set_mass(double new_mass) {
   mass = Math::max(0.0, new_mass);
}
void Celestial::set_radius(double new_radius) {
   radius = Math::max(new_radius, 0.0);
   hitbox->set_radius(radius);
   float diameter = 2 * radius;
   image->resize_scaled( {diameter, diameter} );
   surface_area = M_PI * diameter * diameter;
}
void Celestial::set_texture(Ref<Texture2D> new_texture) {
   image->set_texture(new_texture);
}
void Celestial::_physics_process(double dt) {
   rotate(angular_velocity * Orbit::get_time_scale() * dt);
}
void Celestial::_draw() {
   if (owner.is_valid())
      draw_arc({0.0, 0.0}, radius, 0.0, Math_TAU, NUM_SEGMENTS, owner->get_color(), THICKNESS, true);
   if (contestor.is_valid())
      draw_arc({0.0, 0.0}, radius, 0.0, Math_TAU * capture_progress, NUM_SEGMENTS, contestor->get_color(), THICKNESS, true);
}