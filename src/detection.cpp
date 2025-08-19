#include "detection.hpp"

using namespace godot;

Detection::Detection() {
   add_child(collider, false, INTERNAL_MODE_FRONT);
}
const Vector<NEVER_NULL Ref<Unit::RadarSignature>>& Detection::get_units() const {
   return units;
}
Ref<Shape2D> Detection::get_shape() const {
   return collider->get_shape();
}
void Detection::set_shape(Ref<Shape2D> new_shape) {
   collider->set_shape(new_shape);
}
void Detection::set_shape_circle(double radius) {
   Ref<CircleShape2D> circle = memnew(CircleShape2D);

   circle->set_radius(radius);
   collider->set_shape(circle);
}
void Detection::set_shape_small_angle_arc(float radius, double radians) {
   Ref<ConvexPolygonShape2D> triangle = memnew(ConvexPolygonShape2D);

   PackedVector2Array triangle_points;

   float x_offset = radius * Math::tan(0.5 * radians);

   triangle_points.resize(3);
   triangle_points[0] = {0.0, 0.0};
   triangle_points[1] = {-x_offset, radius};
   triangle_points[2] = { x_offset, radius};
   triangle->set_points(triangle_points);
   collider->set_shape(triangle);
}
void Detection::sort_by_distance() {
   units.sort_custom<DistanceSorter>( get_global_position() );
}
Ref<Unit::RadarSignature> Detection::get_nearest(uint32_t collision_mask) const {
   if ((collision_mask & get_collision_mask()) == 0) return nullptr;

   Ref<Unit::RadarSignature> nearest;

   for (int n = 0; nearest.is_null() && n < units.size(); ++n) {
      // if (units[n]->is_alive() && units[n]->unwrap()->get_collision_layer() & collision_mask != 0) nearest = units[n];
   }
   return nearest;
}
void Detection::update_detection() {
   TypedArray<Node2D> colliders = get_overlapping_bodies();

   units.clear();

   for (int n = 0; n < colliders.size(); ++n) {
      add_unit( Object::cast_to<Unit>(colliders[n]) );
   }
}
void Detection::add_unit(Unit* unit) {
   /*------------------------------------------------------|
   | If you get this warning, consider changing either the |
   | collision mask or the node's collision layer.         |
   |------------------------------------------------------*/
   if (unlikely(unit == nullptr))
      WARN_PRINT_ED("<Detection> Non-unit detected!");
   else
      units.push_back( unit->get_radar_signature() );
}


bool Detection::DistanceSorter::operator()(const Ref<Unit::RadarSignature> &A, const Ref<Unit::RadarSignature> &B) const {
   double A_distance = A->get_position().distance_squared_to(position);
   double B_distance = B->get_position().distance_squared_to(position);
   return A_distance < B_distance;
}