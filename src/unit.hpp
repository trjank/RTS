#ifndef UNIT_HPP
#define UNIT_HPP

#include <godot_cpp/classes/rigid_body2d.hpp>
#include <godot_cpp/classes/physics_direct_body_state2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/templates/list.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include "defaults.hpp"

namespace godot {

class Unit: public RigidBody2D {
   GDCLASS(Unit, RigidBody2D)
public:
   enum State {DEAD, ALIVE, CLOAKED};
   class RadarSignature;
   class Command;
   static constexpr double TURN_JERKINESS = 10.0;
   static constexpr int MAX_NUM_COMMANDS = 3;

   Unit();
   ~Unit();
   double get_hp() const;
   int get_num_commands() const;
   Vector2 get_forward_direction() const;
   Ref<Command> get_current_command() const;
   Ref<RadarSignature> get_radar_signature() const;
   void set_target(Ref<Command> new_target);
   void cloak();
   void decloak();
   virtual void kill();
   void stop_moving();
   void stop_targeting();
   void clear_movement_queue();
   bool queue_move(Ref<Command> new_command);
   virtual void order_attack(Ref<Command> command);
   void hit(double damage);
   void _draw() override;
   void _process(double _dt) override;
   void _physics_process(double dt) override;
   void _integrate_forces(PhysicsDirectBodyState2D* state) override;
protected:
   static void _bind_methods();

   bool can_move = true;
   bool can_warp = false;
   bool applying_thrust = false;
   /*------------------------------------------------------*
   | Godot's builtin damping is not force-based, which     |
   | makes calculations like finding the top speed or stop |
   | distance more difficult. Use the drag value below     |
   | instead of setting linear_damp or angular_damp.       |
   *------------------------------------------------------*/
   double drag = 1.0;
   /*------------------------------------------------------*
   | NOTE: path_arcing should not be set exactly to zero   |
   | because the angle to the target will not always be    |
   | exactly zero and the unit may never move.             |
   |                                                       |
   | NOTE: path_arcing should be kept much lower than 1.0, |
   | since high values may cause the unit to infinitely    |
   | circle the destination depending on the initial       |
   | conditions.                                           |
   *------------------------------------------------------*/
   double hp = 0.0;
   double path_arcing = 0.1;
   double warp = 100.0;
   double thrust = 500.0;
   double speed = 0.0;
   double angle_to_target = 0.0;
   double stop_distance = 0.0;
   double distance_to_target = 0.0;
   double turnrate = 1.0;
private:
   Ref<Command> target;
   List<Ref<Command>> commands;
   NEVER_NULL Ref<RadarSignature> radar_signature;

   void update_radar_signature();
   void move_to_target();
   void try_to_warp(PhysicsDirectBodyState2D& state);
   void try_to_use_thrusters(PhysicsDirectBodyState2D& state);
};

class Unit::RadarSignature: public RefCounted {
   GDCLASS(RadarSignature, RefCounted)
public:
   double get_hp();
   Unit* as_unit();
   State get_state();
   bool is_valid();
   Vector2 get_position();
   Vector2 get_velocity();
protected:
   static void _bind_methods();
private:
   double hp;
   State state;
   Vector2 position;
   Vector2 velocity;
   Unit* unit;
   friend class Unit;
};

class Unit::Command: public RefCounted {
   GDCLASS(Command, RefCounted)
public:
   Command();
   ~Command();
   Vector2 get_position();
   void invalidate();
   bool is_valid();
   bool is_controlled_by(Unit* caller);
   void move_to(Vector2 new_position);
   friend class MouseCommands;
protected:
   static void _bind_methods();

   Unit* predator;
   Ref<RadarSignature> prey;

   void ram();
   void track();
   void flee(double safe_distance);
   void kite(double min_distance, double max_distance);
private:
   bool valid;
   Sprite2D* icon;
};

}

#endif // UNIT_HPP