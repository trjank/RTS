#include <godot_cpp/core/math.hpp>
#include "unit.hpp"

using namespace godot;

Unit::Unit() {
   radar_signature.instantiate();
   radar_signature->unit  = this;
   radar_signature->state = ALIVE;
   path->add_point( {0.0, 0.0} );
   path->set_texture_mode(Line2D::LineTextureMode::LINE_TEXTURE_TILE);
   path->set_texture_repeat(CanvasItem::TextureRepeat::TEXTURE_REPEAT_ENABLED);

   set_linear_damp(0.0);
   set_angular_damp(0.0);
   set_gravity_scale(0.0);

   add_child(path, false, INTERNAL_MODE_FRONT);
   add_child(image, false, INTERNAL_MODE_FRONT);
}
Unit::~Unit() {
   radar_signature->unit  = nullptr;
   radar_signature->state = DEAD;
}
bool Unit::is_selected() const {
   return selected;
}
bool Unit::is_queue_empty() const {
   return waypoints.is_empty();
}
bool Unit::is_applying_thrust() const {
   return applying_thrust;
}
bool Unit::is_movement_locked() const {
   return movement_locked;
}
int Unit::count_waypoints() const {
   return waypoints.size();
}
double Unit::get_hp() const {
   return hp;
}
double Unit::get_warp() const {
   return warp;
}
double Unit::get_distance_to_target() const {
   return distance_to_target;
}
double Unit::get_angle_to_target() const {
   return angle_to_target;
}
double Unit::get_stop_distance() const {
   return stop_distance;
}
double Unit::get_speed() const {
   return speed;
}
double Unit::get_approx_time_to_move() const {
   return approx_time_to_move;
}
double Unit::get_approx_time_to_turn() const {
   return approx_time_to_turn;
}
double Unit::get_path_width() const {
   return path->get_width();
}
Vector2 Unit::get_forward_direction() const {
   return -get_transform().columns[1];
}
Color Unit::get_selected_color() const {
   return selected_color;
}
Color Unit::get_cloak_color() const {
   return cloak_color;
}
NO_ERROR_CHECK Ref<Target> Unit::get_waypoint(int waypoint_num) const {
   return waypoints[waypoint_num];
}
NO_ERROR_CHECK Ref<Target> Unit::get_last_waypoint() const {
   return waypoints[waypoints.size() - 1];
}
Ref<StaticTarget> Unit::get_attack_position() const {
   return attack_position;
}
Ref<Unit::RadarSignature> Unit::get_radar_signature() const {
   return radar_signature;
}
Ref<Player> Unit::get_player_owner() const {
   return owner;
}
Ref<Texture2D> Unit::get_texture() const {
   return image->get_texture();
}
Ref<Texture2D> Unit::get_path_texture() const {
   return path->get_texture();
}
void Unit::set_selected_color(Color new_selected_color) {
   selected_color = new_selected_color;
}
void Unit::set_cloak_color(Color new_cloak_color) {
   cloak_color = new_cloak_color;
}
void Unit::set_selected(bool select) {
   selected = select;
   path->set_visible(selected);
   image->set_self_modulate(select ? selected_color : Color(1.0, 1.0, 1.0, 1.0) );
}
void Unit::set_movement_lock(bool lock_movement) {
   movement_locked = lock_movement;
}
void Unit::set_player_owner(Ref<Player> new_owner) {
   ERR_FAIL_NULL_MSG(new_owner, "<Unit> New owner is null (failed to set owner)");

   owner = new_owner;
}
void Unit::set_texture(Ref<Texture2D> new_texture) {
   image->set_texture(new_texture);
   image->reset_to_default_size();
}
void Unit::set_image_offset(Vector2 new_offset) {
   image->set_offset(new_offset);
}
bool Unit::resize_image(Vector2 new_size) {
   return image->resize(new_size);
}
void Unit::set_path_texture(Ref<Texture2D> new_path_texture) {
   path->set_texture(new_path_texture);
}
void Unit::set_path_width(double new_path_width) {
   path->set_width(new_path_width);
}
void Unit::cloak() {
   radar_signature->state = CLOAKED;
   set_modulate(cloak_color);
}
void Unit::decloak() {
   radar_signature->state = ALIVE;
   set_modulate( {1.0, 1.0, 1.0, 1.0} );
}
void Unit::kill() {
   queue_free();
}
void Unit::clear_movement_queue() {
   waypoints.clear();
   path->clear_points();
   path->add_point( get_global_position() );
}
bool Unit::queue_waypoint(Ref<Target> new_waypoint) {
   if (new_waypoint.is_null() || waypoints.size() >= MAX_NUM_WAYPOINTS) return false;

   Vector2 position = new_waypoint->get_position();

   // Add the point twice to prevent linecap distortion
   path->add_point(position);
   path->add_point(position);
   return waypoints.push_back(new_waypoint);
}
void Unit::target(Ref<Target> new_target) {
   /*------------------------------------------------------|
   | Ships treat targets and waypoints differently. For    |
   | any custom targeting behavior, override this method.  |
   |------------------------------------------------------*/
   clear_movement_queue();
   queue_waypoint(new_target);
}
void Unit::order_attack() {
   /*------------------------------------------------------|
   | This is the main logic for the unit. If you want AI   |
   | and other custom behavior, override this method.      |
   |------------------------------------------------------*/
   ram( get_waypoint() );
}
void Unit::hit(double damage) {
   if ( (hp -= damage) <= 0) kill();
}
bool Unit::pop_waypoint() {
   if (waypoints.is_empty()) return false;

   path->remove_point(2);
   path->remove_point(1);
   waypoints.remove_at(0);
   return true;
}
void Unit::_physics_process(double dt) {
   move_to_target();
   update_radar_signature();
   update_path();
}
void Unit::_integrate_forces(PhysicsDirectBodyState2D* state) {
   Vector2 drag_force = -drag * get_linear_velocity();
   state->apply_central_force(drag_force);
   
   if (is_queue_empty()) return state->set_angular_velocity(0.0);
   
   // This smoothing prevents jittering when angle_to_target is near 0.0
   double turn_direction = Math::clamp(TURN_JERKINESS * angle_to_target, -1.0, 1.0);

   state->set_angular_velocity(turnrate * turn_direction);
   try_to_apply_thrust(state);
   try_to_warp(state);
}
void Unit::move_to(Vector2 new_position) {
   attack_position->set_position(new_position);
}
void Unit::ram(Ref<Target> target) {
   move_to( target->get_position() );
}
void Unit::track(Ref<Target> target) {
   /*------------------------------------------------------|
   | Ramming is more efficient and should be used in most  |
   | cases. Only use track for melee units and missiles.   |
   |------------------------------------------------------*/
   Target::Prediction prediction = radar_signature->predict(target);

   if (prediction.will_intersect)
      move_to(prediction.intersection);
   else
      ram(target);
}
void Unit::flee(Ref<Target> target, double safe_distance) {
   Vector2 position  = get_global_position();
   Vector2 direction = position - target->get_position();

   move_to(position + safe_distance * direction.normalized());
}
void Unit::kite(Ref<Target> target, double min_distance, double max_distance) {
   // NOTE: Manual movement lock is completely overridden
   if (distance_to_target < min_distance) {
      flee(target, max_distance);
      set_movement_lock(false);
   } else if (distance_to_target > max_distance) {
      ram(target);
      set_movement_lock(false);
   } else
      set_movement_lock(true);
}
void Unit::update_path() {
   path->set_global_rotation(0.0);
   path->set_global_position( {0.0, 0.0} );
   path->set_point_position(0, get_global_position());
}
void Unit::update_radar_signature() {
   if (radar_signature->state == CLOAKED) return;

   radar_signature->speed = speed;
   radar_signature->velocity = get_linear_velocity();
   radar_signature->position = get_global_position();
}
void Unit::update_attack_info() {
   Vector2 separation = attack_position->get_position() - get_global_position();
   Vector2 velocity   = get_linear_velocity();

   distance_to_target  = separation.length();
   angle_to_target     = get_forward_direction().angle_to(separation);
   stop_distance       = velocity.dot( separation.normalized() );
   speed               = velocity.length();
   approx_time_to_move = distance_to_target / speed;
   approx_time_to_turn = Math::abs(angle_to_target / turnrate);
}
void Unit::move_to_target() {
   if (waypoints.is_empty()) return;

   order_attack();
   update_attack_info();

   applying_thrust = !movement_locked && approx_time_to_turn <= path_arcing * approx_time_to_move;
   
   if (distance_to_target <= MOVE_LAZINESS * stop_distance) pop_waypoint();
}
void Unit::try_to_apply_thrust(PhysicsDirectBodyState2D* state) {
   if (applying_thrust) state->apply_central_force(thrust * get_forward_direction());
}
void Unit::try_to_warp(PhysicsDirectBodyState2D* state) {
   if (waypoints.size() > MAX_NUM_WAYPOINTS_TO_WARP || !applying_thrust || warp < distance_to_target) return;

   Vector2 warp_start = get_global_position();
   Vector2 warp_end   = attack_position->get_position();

   warp -= distance_to_target;

   rotate(angle_to_target);
   set_global_position(warp_end);
   state->set_linear_velocity( {0.0, 0.0} );

   emit_signal("warped", warp_start, warp_end);
}


bool Unit::RadarSignature::is_alive() const {
   return state != DEAD;
}
SAFE_PTR Unit* Unit::RadarSignature::unwrap() const {
   return unit;
}
Unit::State Unit::RadarSignature::get_state() const {
   return state;
}
double Unit::RadarSignature::get_speed() const {
   return speed;
}
Vector2 Unit::RadarSignature::get_position() const {
   return position;
}
Vector2 Unit::RadarSignature::get_velocity() const {
   return velocity;
}
Vector2 Unit::RadarSignature::get_future_position() const {
   return state == DEAD || unit->is_queue_empty() ? position : unit->get_last_waypoint()->get_position();
}
void Unit::RadarSignature::set_position(Vector2 new_position) {
   WARN_PRINT_ED("<Unit::RadarSignature> 'set_position' does nothing");
}