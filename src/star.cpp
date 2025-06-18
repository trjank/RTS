#include "star.hpp"

using namespace godot;

Ref<ShaderMaterial>& Star::get_star_shader() {
   static Ref<ShaderMaterial> shader;
   return shader;
}
Ref<ShaderMaterial>& Star::get_black_hole_shader() {
   static Ref<ShaderMaterial> shader;
   return shader;
}
bool Star::is_black_hole() {
   return collapsed;
}
bool Star::can_capture() {
   return false;
}
void Star::set_star_shader(Ref<ShaderMaterial> shader){
   get_star_shader() = shader;
}
void Star::set_black_hole_shader(Ref<ShaderMaterial> shader) {
   get_black_hole_shader() = shader;
}
void Star::set_mass(double new_mass) {
   Celestial::set_mass(new_mass);
   check_for_black_hole();
}
void Star::set_radius(double new_radius) {
   Celestial::set_radius(new_radius);
   check_for_black_hole();
}
void Star::check_for_black_hole() {
   double r_schwarzschild = STABILITY * GRAVITATIONAL_CONSTANT * get_mass();
   collapsed = r_schwarzschild <= get_radius();
   set_material(collapsed ? get_black_hole_shader() : get_star_shader());
}