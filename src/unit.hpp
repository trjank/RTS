#ifndef UNIT_HPP
#define UNIT_HPP

#include <godot_cpp/classes/rigid_body2d.hpp>
#include <godot_cpp/classes/physics_direct_body_state2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/templates/list.hpp>

using godot::Sprite2D;
using godot::List;
using godot::RigidBody2D;
using godot::Vector2;
using godot::Color;
using godot::Ref;
using godot::RefCounted;
using godot::PhysicsDirectBodyState2D;
using godot::Texture2D;

class Unit: public RigidBody2D {
   GDCLASS(Unit, RigidBody2D)
   static float friction;
   void move_to_target();
public:
   static constexpr float DISTANCE_TOLERANCE = 50.0;
   static constexpr float ANGLE_TOLERANCE = 0.1;
   static constexpr int MAX_N_COMMANDS = 3;
   enum State { DEAD, ALIVE, CLOAKED };
   class RadarSignature;
   class Command;
   float get_HP();
   Vector2 get_forward_direction();
   void cloak();
   void decloak();
   void hit(float damage);
   void kill();
   void stop_moving();
   void stop_targeting();
   void queue_move(Ref<Command> new_command);
   void set_target(Ref<Command> new_target);
   Ref<Command> get_current_command();
   virtual void order_attack(Ref<Command> command);
   void _draw() override;
   void _process(double _dt) override;
   void _physics_process(double dt) override;
   void _integrate_forces(PhysicsDirectBodyState2D* state) override;
   Unit();
   ~Unit();
   friend class MouseCommands;
protected:
   static void _bind_methods();
   bool can_move: 1;
   bool applying_thrust: 1;
   float HP = 0.0;
   float path_arcing = 0.1;
   float turnrate = 1.0;
   float thrust = 500.0;
   float drag = 1.0;

   float time_to_turn = 0.0;
   float time_to_move = 0.0;
   float angle_to_target = 0.0;
   float stop_distance = 0.0;
   float distance_to_target = 0.0;
   
   List<Ref<Command>> commands;
   Ref<RadarSignature> radar_signature;
   Ref<Command> target;
   void update_radar_signature();
};

class Unit::RadarSignature: public RefCounted {
   GDCLASS(RadarSignature, RefCounted)
   float HP;
   State state;
   Vector2 position;
   Vector2 velocity;
   Unit* unit;
public:
   float get_HP();
   State get_state();
   Vector2 get_position();
   Vector2 get_velocity();
   void try_queue_move(Ref<Command> command);
   void try_set_target(Ref<Command> command);
   friend class Unit;
protected:
   static void _bind_methods();
};

class Unit::Command: public RefCounted {
   GDCLASS(Command, RefCounted)
   bool valid;
   Sprite2D* icon;
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
   void flee(float safe_distance);
   void kite(float min_distance, float max_distance);
};

#endif