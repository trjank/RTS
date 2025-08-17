#ifndef UNIT_FORMATION_HPP
#define UNIT_FORMATION_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/classes/shape_cast2d.hpp>
#include <godot_cpp/classes/circle_shape2d.hpp>
#include <godot_cpp/classes/rectangle_shape2d.hpp>
#include <godot_cpp/variant/rect2.hpp>
#include <godot_cpp/classes/geometry2d.hpp>
#include "unit.hpp"
namespace godot {

class UnitFormation: public Node2D {
   GDCLASS(UnitFormation, Node2D)
public:
   // Represents the number of points needed to construct the formation curve
   enum Formation: int {LINE = 2, V = 3, SMOOTH = 10, PRECISE = 30};

   static constexpr double SEARCH_EXPANSION = 50.0;
   static constexpr int MAX_CLEANUP_ITERATIONS = 5;
   
   UnitFormation();
   bool is_curve_active() const;
   int count_units() const;
   int count_targets() const;
   uint32_t get_collision_mask();
   Formation get_formation() const;
   Rect2 get_bound_box_units() const;
   Rect2 get_bound_box_targets() const;
   Ref<Player> get_player() const;
   NO_ERROR_CHECK Ref<Unit::RadarSignature> get_unit(int unit_num) const;
   NO_ERROR_CHECK Ref<Target> get_target(int target_num) const;
   void set_collision_mask(uint32_t new_collision_mask);
   void set_formation(Formation new_formation);
   void set_player(Ref<Player> new_player);
   void set_units_selected(bool selected);
   void select_closest_unit_to(Vector2 position, double search_radius);
   void select_region(Vector2 position, Ref<Shape2D> shape);
   void select_units(TypedArray<Node2D> selection);
   void order_units_to_target();
   void order_units_to_stop();
   void order_units_to_toggle_lock(double threshold = 0.5);
   void order_units_to_lock(bool movement_lock = false);
   void order_units_to_move();
   void begin_curve_at(Vector2 path_start);
   void move_curve_to(Vector2 new_endpoint);
   void end_curve(bool target_units = false);
protected:
   static void _bind_methods();
private:
template<typename T>
   struct AxisSorter;

   typedef AxisSorter<Target> TargetAxisSorter;
   typedef AxisSorter<Unit::RadarSignature> UnitAxisSorter;

   Formation formation = LINE;
   bool curve_is_active = false;
   bool target_units = false;
   double curve_length = 0.0;
   Rect2 bound_box_units = {0.0, 0.0, 0.0, 0.0};
   Rect2 bound_box_targets = {0.0, 0.0, 0.0, 0.0};
   Ref<Player> player;
   Vector<Vector2> points;
   Vector<Ref<Target>> targets;
   Vector<Ref<Unit::RadarSignature>> units;
   NEVER_NULL SAFE_PTR ShapeCast2D* shape_cast = memnew(ShapeCast2D);
   NEVER_NULL Ref<CircleShape2D> search_circle = memnew(CircleShape2D);
   NEVER_NULL Ref<RectangleShape2D> search_rectangle = memnew(RectangleShape2D);

template<typename T>
   Rect2 calculate_bound_box(const Vector<Ref<T>>& objects);
   Vector2 get_point_along_curve(double parametric_distance);
   Vector<Ref<Unit::RadarSignature>> search_region_for_units(Vector2 position, Ref<Shape2D> shape);
   Ref<Unit::RadarSignature> find_closest_unit(Vector2 position, const Vector<Ref<Unit::RadarSignature>> &units);
   void snap_targets();
   void update_target_positions();
   void add_unit_to_buffer(Unit* unit, Vector<Ref<Unit::RadarSignature>>& out_buffer);
   bool cleanup_intersections();
   bool paths_intersect(int a, int b);
   bool maybe_swap_path_endpoints(int a, int b);
};

template<typename T>
struct UnitFormation::AxisSorter {
   Vector2 axis;
   Vector2 center;

   bool operator()(const Ref<T> &A, const Ref<T> &B) const;
};


}

VARIANT_ENUM_CAST(UnitFormation::Formation);

#endif // UNIT_FORMATION_HPP