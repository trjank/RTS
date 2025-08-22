#ifndef UNIT_HPP
#define UNIT_HPP

#include <godot_cpp/classes/rigid_body2d.hpp>
#include <godot_cpp/classes/physics_direct_body_state2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/line2d.hpp>
#include "player.hpp"
#include "target.hpp"
#include "defaults.hpp"
#include "resizable_sprite_2d.hpp"

namespace godot {
class Unit: public RigidBody2D {
   GDCLASS(Unit, RigidBody2D)
public:
   enum State {DEAD, ALIVE, CLOAKED};

   class RadarSignature;

   static constexpr int MAX_NUM_WAYPOINTS = 5;
   static constexpr int MAX_NUM_WAYPOINTS_TO_WARP = 1;
   static constexpr double TURN_JERKINESS = 10.0;
   static constexpr double PATH_WIDTH = 1.0;
   static constexpr double MOVE_LAZINESS = 1.0;

   static_assert(0.0 < MOVE_LAZINESS && MOVE_LAZINESS <= 1.0);

   Unit();
   ~Unit();
   bool is_selected() const;
   bool is_queue_empty() const;
   bool is_applying_thrust() const;
   bool is_movement_locked() const;
   int count_waypoints() const;
   double get_hp() const;
   double get_warp() const;
   double get_distance_to_target() const;
   double get_angle_to_target() const;
   double get_stop_distance() const;
   double get_speed() const;
   double get_approx_time_to_move() const;
   double get_approx_time_to_turn() const;
   double get_path_width() const;
   Vector2 get_forward_direction() const;
   Color get_selected_color() const;
   Color get_cloak_color() const;
   NO_ERROR_CHECK Ref<Target> get_waypoint(int waypoint_num = 0) const;
   NO_ERROR_CHECK Ref<Target> get_last_waypoint() const;
   Ref<StaticTarget> get_attack_position() const;
   Ref<RadarSignature> get_radar_signature() const;
   Ref<Player> get_player_owner() const;
   Ref<Texture2D> get_texture() const;
   Ref<Texture2D> get_path_texture() const;
   void set_selected_color(Color new_selected_color);
   void set_cloak_color(Color new_cloak_color);
   void set_selected(bool select);
   void set_movement_lock(bool lock_movement);
   void set_player_owner(Ref<Player> new_owner);
   void set_texture(Ref<Texture2D> new_texture);
   void set_image_offset(Vector2 new_offset);
   void set_path_texture(Ref<Texture2D> new_path_texture);
   void set_path_width(double new_path_width);
   bool resize_image(Vector2 new_size);
   void cloak();
   void decloak();
   virtual void kill();
   void clear_movement_queue();
   bool queue_waypoint(Ref<Target> new_waypoint);
   virtual void target(Ref<Target> new_target);
   void hit(double damage);
   void _physics_process(double dt) override;
   void _integrate_forces(PhysicsDirectBodyState2D* state) override;
protected:
   static void _bind_methods();

   bool selected = false;
   bool movement_locked = false;
   bool applying_thrust = false;
   /*------------------------------------------------------|
   | Godot's builtin damping is not force-based, which     |
   | makes calculations like finding the top speed or stop |
   | distance more difficult. Use the drag value below     |
   | instead of setting linear_damp or angular_damp.       |
   |------------------------------------------------------*/
   double drag = 1.0;
   /*------------------------------------------------------|
   | NOTE: path_arcing should not be set exactly to zero   |
   | because the angle to the target will not always be    |
   | exactly zero and the unit may never move.             |
   |                                                       |
   | NOTE: path_arcing should be kept much lower than 1.0, |
   | since high values may cause the unit to infinitely    |
   | circle the destination depending on the initial       |
   | conditions.                                           |
   |------------------------------------------------------*/
   double path_arcing = 0.1;
   double hp = 0.0;
   double warp = 500.0;
   double thrust = 500.0;
   double speed = 0.0;
   double angle_to_target = 0.0;
   double stop_distance = 0.0;
   double approx_time_to_turn = 0.0;
   double approx_time_to_move = 0.0;
   double distance_to_target = 0.0;
   double turnrate = 1.0;
   Color cloak_color = {1.0, 1.0, 1.0, 0.5};
   Color selected_color = {1.0, 0.5, 0.5, 1.0};

   virtual void order_attack();
   bool pop_waypoint();
   void move_to(Vector2 position);
   void ram(Ref<Target> target);
   void track(Ref<Target> target);
   void flee(Ref<Target> target, double safe_distance);
   void kite(Ref<Target> target, double min_distance, double max_distance);
private:
   Vector<NEVER_NULL Ref<Target>> waypoints;
   NEVER_NULL Ref<StaticTarget> attack_position = memnew(StaticTarget);
   NEVER_NULL Ref<RadarSignature> radar_signature;
   NEVER_NULL Ref<Player> owner = get_default<Player>();
   NEVER_NULL SAFE_PTR ResizableSprite2D* image = memnew(ResizableSprite2D);
   NEVER_NULL SAFE_PTR Line2D* path = memnew(Line2D);

   void update_path();
   void update_radar_signature();
   void update_attack_info();
   void move_to_target();
   void try_to_warp(PhysicsDirectBodyState2D* state);
   void try_to_apply_thrust(PhysicsDirectBodyState2D* state);
};

class Unit::RadarSignature: public Target {
   GDCLASS(RadarSignature, Target)
public:
   bool is_alive() const;
   SAFE_PTR Unit* unwrap() const;
   State get_state() const;
   double get_speed() const override;
   Vector2 get_position() const override;
   Vector2 get_velocity() const override;
   Vector2 get_future_position() const override;
   void set_position(Vector2 new_position) override;
protected:
   static void _bind_methods();
private:
   State state = DEAD;
   double speed = 0.0;
   Vector2 position = {0.0, 0.0};
   Vector2 future_position = {0.0, 0.0};
   Vector2 velocity = {0.0, 0.0};
   SAFE_PTR Unit* unit = nullptr;

   friend class Unit;
};

}

VARIANT_ENUM_CAST(Unit::State);

#endif // UNIT_HPP