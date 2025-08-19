#ifndef DETECTION_HPP
#define DETECTION_HPP

#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/circle_shape2d.hpp>
#include <godot_cpp/classes/convex_polygon_shape2d.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "unit.hpp"

namespace godot {

class Detection: public Area2D {
   GDCLASS(Detection, Area2D)
public:
   Detection();
   const Vector<NEVER_NULL Ref<Unit::RadarSignature>>& get_units() const;
   Ref<Shape2D> get_shape() const;
   Ref<Unit::RadarSignature> get_nearest(uint32_t collision_layer) const;
   void set_shape(Ref<Shape2D> new_shape);
   void set_shape_circle(double radius);
   void set_shape_small_angle_arc(float radius, double radians);
   void sort_by_distance();
   void update_detection();
protected:
   static void _bind_methods();
private:
   struct DistanceSorter;

   NEVER_NULL SAFE_PTR CollisionShape2D* collider = memnew(CollisionShape2D);
   Vector<NEVER_NULL Ref<Unit::RadarSignature>> units;

   void add_unit(Unit* unit);
};


struct Detection::DistanceSorter {
   Vector2 position;

   bool operator()(const Ref<Unit::RadarSignature> &A, const Ref<Unit::RadarSignature> &B) const;
};

}

#endif // DETECTION_HPP