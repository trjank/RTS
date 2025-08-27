#include "target.hpp"

using namespace godot;

Target::Prediction Target::predict_lazy(NEVER_NULL Ref<Target> target) const {
   return target->predict_lazy_from(get_position(), get_speed());
}
Target::Prediction Target::predict(NEVER_NULL Ref<Target> target) const {
   return target->predict_from(get_position(), get_speed());
}
Target::Prediction Target::predict_lazy_from(Vector2 position, double speed) const {
   /*------------------------------------------------------|
   | This assumes that an intersection is always possible. |
   | Fast to compute, but inaccurate for fast targets.     |
   |------------------------------------------------------*/
   Vector2 target_vel    = get_velocity();
   Vector2 target_pos    = get_position();
   double intersect_time = position.distance_to(target_pos) / speed;

   return {true, intersect_time, target_pos + intersect_time * target_vel};
}
Target::Prediction Target::predict_from(Vector2 position, double speed) const {
   /*------------------------------------------------------|
   | This assumes the speeds will remain constant and the  |
   | paths will be straight.                               |
   |------------------------------------------------------*/

   // We'll use this information to apply the quadratic formula
   Vector2 target_vel  = get_velocity();
   Vector2 target_pos  = get_position();
   Vector2 dx          = position - target_pos;
   double v_dot_dx     = target_vel.dot(dx);
   double dspeed_sq    = speed * speed - target_vel.length_squared();
   double discriminant = v_dot_dx * v_dot_dx + dspeed_sq * dx.length_squared();

   // No real solutions to the quadratic means no intersection is possible
   if (discriminant < 0) return {false, Math_INF, target_pos};

   // Return the positive time solution
   double intersect_time = (v_dot_dx + Math::sqrt(discriminant)) / dspeed_sq;

   return {true, intersect_time, target_pos + intersect_time * target_vel};
}


Ref<StaticTarget> StaticTarget::create_at(Vector2 position) {
   Ref<StaticTarget> target = memnew(StaticTarget);

   target->set_position(position);
   return target;
}
double StaticTarget::get_speed() const {
   return 0.0;
}
Vector2 StaticTarget::get_position() const {
   return position;
}
Vector2 StaticTarget::get_velocity() const {
   return {0.0, 0.0};
}
Vector2 StaticTarget::get_future_position() const {
   return position;
}
void StaticTarget::set_position(Vector2 new_position) {
   position = new_position;
}