#include <godot_cpp/core/math.hpp>
#include "unit_formation.hpp"

using namespace godot;

UnitFormation::UnitFormation() {
   shape_cast->set_target_position( {0.0, 0.0} );
   shape_cast->set_enabled(false);
   add_child(shape_cast, false, Node::INTERNAL_MODE_FRONT);
}
bool UnitFormation::is_curve_active() const {
   return curve_is_active;
}
int UnitFormation::count_units() const {
   return units.size();
}
int UnitFormation::count_targets() const {
   return targets.size();
}
UnitFormation::Formation UnitFormation::get_formation() const {
   return formation;
}
Rect2 UnitFormation::get_bound_box_units() const {
   return bound_box_units;
}
Rect2 UnitFormation::get_bound_box_targets() const {
   return bound_box_targets;
}
Ref<Player> UnitFormation::get_player() const {
   return player;
}
NO_ERROR_CHECK Ref<Unit::RadarSignature> UnitFormation::get_unit(int unit_num) const {
   return units[unit_num];
}
NO_ERROR_CHECK Ref<Target> UnitFormation::get_target(int target_num) const {
   return targets[target_num];
}
uint32_t UnitFormation::get_collision_mask() {
   return shape_cast->get_collision_mask();
}
void UnitFormation::set_formation(Formation new_formation) {
   ERR_FAIL_COND_MSG(new_formation <= 1, "<UnitFormation> Too few points (failed to set formation)");

   formation = new_formation;
}
void UnitFormation::set_player(Ref<Player> new_player) {
   player = new_player;
}
void UnitFormation::set_collision_mask(uint32_t new_collision_mask) {
   shape_cast->set_collision_mask(new_collision_mask);
}
void UnitFormation::set_units_selected(bool selected) {
   for (Ref<Unit::RadarSignature> unit: units) {
      unit->unwrap()->set_selected(selected);
   }
}
void UnitFormation::select_region(Vector2 position, Ref<Shape2D> shape) {
   targets.clear();
   units = search_region_for_units(position, shape);
}
void UnitFormation::select_units(TypedArray<Node2D> selection) {
   targets.clear();
   units.clear();

   for (int n = 0; n < selection.size(); ++n) {
      add_unit_to_buffer(Object::cast_to<Unit>(selection[n]), units);
   }
}
void UnitFormation::select_closest_unit_to(Vector2 position, double search_radius) {
   search_circle->set_radius(search_radius);
   units.clear();

   Vector<Ref<Unit::RadarSignature>> search = search_region_for_units(position, search_circle);
   Ref<Unit::RadarSignature> closest_unit   = find_closest_unit(position, search);

   if (closest_unit.is_valid()) units.push_back(closest_unit);
}
void UnitFormation::order_units_to_stop() {
   for (Ref<Unit::RadarSignature> unit: units) {
      if (unit->is_alive()) unit->unwrap()->clear_movement_queue();
   }
}
void UnitFormation::order_units_to_target() {
   for (int n = 0; n < targets.size(); ++n) {
      if (units[n]->is_alive()) units[n]->unwrap()->target(targets[n]);
   }
}
void UnitFormation::order_units_to_move() {
   for (int n = 0; n < targets.size(); ++n) {
      if (units[n]->is_alive()) units[n]->unwrap()->queue_waypoint(targets[n]);
   }
}
void UnitFormation::order_units_to_toggle_lock(double threshold) {
   int locked_units   = 0;
   int majority_units = threshold * units.size();

   for (const Ref<Unit::RadarSignature> unit: units) {
      if (unit->is_alive() && unit->unwrap()->is_movement_locked()) ++locked_units;
   }
   order_units_to_lock(locked_units <= majority_units);
}
void UnitFormation::order_units_to_lock(bool movement_lock) {
   for (Ref<Unit::RadarSignature> unit: units) {
      if (unit->is_alive()) unit->unwrap()->set_movement_lock(movement_lock);
   }
}
void UnitFormation::begin_curve_at(Vector2 path_start) {
   int num_points = static_cast<int>(formation);

   points.resize(num_points);
   points.fill(path_start);
   targets.resize( units.size() );

   for (int n = 0; n < targets.size(); ++n) {
      targets.set(n, StaticTarget::create_at(path_start));
   }
   curve_length    = 0.0;
   curve_is_active = true;

   emit_signal("path_started");
}
void UnitFormation::move_curve_to(Vector2 new_endpoint) {
   ERR_FAIL_COND_MSG( !curve_is_active, "<UnitFormation> Begin curve before moving it");

   constexpr double UNSTABLE_CURVE_LENGTH = 0.1;

   int end_index  = points.size() - 1;
   double stretch = points[end_index].distance_to(new_endpoint);

   points.set(end_index, new_endpoint);
   
   if ( (curve_length += stretch) <= UNSTABLE_CURVE_LENGTH) return;
   
   /*------------------------------------------------------|
   | While points can grow further apart, the 'parametric' |
   | length of a segment is always defined to be 1.0       |
   |------------------------------------------------------*/
   double step_distance = 1.0 + stretch / curve_length;

   for (int n = 1; n < end_index; ++n) {
      points.set(n, get_point_along_curve(n * step_distance));
   }
   update_target_positions();
}
void UnitFormation::end_curve(bool target_units) {
   ERR_FAIL_COND_MSG( !curve_is_active, "<UnitFormation> Begin curve before ending it");

   curve_is_active   = false;
   bound_box_units   = calculate_bound_box(units);
   bound_box_targets = calculate_bound_box(targets);

   Vector2 center_targets = bound_box_targets.get_center();
   Vector2 center_units   = bound_box_units.get_center();
   Vector2 sort_axis      = center_targets - center_units;

   /*------------------------------------------------------|
   | Pair up units and targets by their distance along one |
   | axis. We want to reduce intersections and distance.   |
   |------------------------------------------------------*/
   units.sort_custom<UnitAxisSorter>(sort_axis, center_units);
   targets.sort_custom<TargetAxisSorter>(sort_axis, center_targets);

   for (int n = 0; n < MAX_CLEANUP_ITERATIONS; ++n) {
      if ( !cleanup_intersections()) break;
   }
   if (target_units) snap_targets();

   emit_signal("path_ended");
}
Ref<Unit::RadarSignature> UnitFormation::find_closest_unit(Vector2 position, const Vector<Ref<Unit::RadarSignature>> &units) {
   double min_distance = Math_INF;

   Ref<Unit::RadarSignature> closest_unit;

   for (const Ref<Unit::RadarSignature> unit: units) {
      double distance = unit->get_position().distance_squared_to(position);
      if (min_distance <= distance) continue;
      min_distance = distance;
      closest_unit = unit;
   }
   return closest_unit;
}
void UnitFormation::snap_targets() {
   Rect2 region = bound_box_targets.grow(SEARCH_EXPANSION);
   
   search_rectangle->set_size(region.size);

   Vector<Ref<Unit::RadarSignature>> search = search_region_for_units(region.get_center(), search_rectangle);

   for (int n = 0; n < targets.size(); ++n) {
      targets.set(n, find_closest_unit(targets[n]->get_position(), search));
   }
}
Vector<Ref<Unit::RadarSignature>> UnitFormation::search_region_for_units(Vector2 position, Ref<Shape2D> shape) {
   Vector<Ref<Unit::RadarSignature>> search;

   shape_cast->set_shape(shape);
   shape_cast->set_global_position(position);
   shape_cast->set_enabled(true);
   shape_cast->force_shapecast_update();

   for (int n = 0; n < shape_cast->get_collision_count(); ++n) {
      add_unit_to_buffer(Object::cast_to<Unit>( shape_cast->get_collider(n) ), search);
   }
   return search;
}
template<typename T>
Rect2 UnitFormation::calculate_bound_box(const Vector<Ref<T>>& objects) {
   Rect2 rect = {0.0, 0.0, 0.0, 0.0};

   if (objects.is_empty()) return rect;

   rect.position = objects[0]->get_future_position();

   for (int n = 1; n < objects.size(); ++n) {
      rect.expand_to( objects[n]->get_future_position() );
   }
   return rect;
}
Vector2 UnitFormation::get_point_along_curve(double parametric_distance) {
   int start_index = Math::clamp<int>(parametric_distance, 0, points.size() - 2);
   double fraction = Math::clamp(parametric_distance - start_index, 0.0, 1.0);

   return points[start_index].lerp(points[start_index + 1], fraction);
}
void UnitFormation::update_target_positions() {
   constexpr double PREVENT_DIVIDE_ZERO = 0.001;

   double end_distance  = points.size() - 1;
   double step_distance = end_distance / (targets.size() - 1 + PREVENT_DIVIDE_ZERO);

   for (int n = 0; n < targets.size(); ++n) {
      targets[n]->set_position( get_point_along_curve(n * step_distance) );
   }
}
void UnitFormation::add_unit_to_buffer(Unit* unit, Vector<Ref<Unit::RadarSignature>> &out_buffer) {
   if (unit) out_buffer.push_back( unit->get_radar_signature() );
}
bool UnitFormation::cleanup_intersections() {
   bool swapped = false;

   /*------------------------------------------------------|
   | We assume that targets are almost in their correct    |
   | order (from sorting) and just check neighbors.        |
   |------------------------------------------------------*/
   for (int n = 1; n < targets.size(); ++n) {
      swapped |= maybe_swap_path_endpoints(n - 1, n);
   }
   return swapped;
}
bool UnitFormation::paths_intersect(int a, int b) {
   Vector2 a_from = units[a]->get_future_position();
   Vector2 b_from = units[b]->get_future_position();
   Vector2 a_to   = targets[a]->get_future_position();
   Vector2 b_to   = targets[b]->get_future_position();

   return Geometry2D::get_singleton()->segment_intersects_segment(a_from, a_to, b_from, b_to);
}
bool UnitFormation::maybe_swap_path_endpoints(int a, int b) {
   if ( !paths_intersect(a, b)) return false;

   Ref<Target> temporary = targets[a];

   targets.set(a, targets[b]);
   targets.set(b, temporary);
   return true;
}


template<typename T>
bool UnitFormation::AxisSorter<T>::operator()(const Ref<T> &A, const Ref<T> &B) const {
   Vector2 A_offset = A->get_future_position() - center;
   Vector2 B_offset = B->get_future_position() - center;
   return A_offset.cross(axis) < B_offset.cross(axis);
}