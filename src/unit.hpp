#ifndef UNIT_HPP
#define UNIT_HPP

#include <godot_cpp/classes/physics_body2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/templates/list.hpp>
#include "command.hpp"

using godot::Sprite2D;
using godot::List;
using godot::PhysicsBody2D;
using godot::Vector2;
using godot::Color;
using godot::Ref;
using godot::RefCounted;

class Unit: public PhysicsBody2D {
   GDCLASS(Unit, PhysicsBody2D)
   static int max_n_commands;
   static float friction;
   void move_to_target();
   Unit();
   ~Unit();
public:
   enum State { DEAD, ALIVE, CLOAKED };
   class RadarSignature: public RefCounted {
      GDCLASS(RadarSignature, RefCounted)
   public:
      Unit* unit;
      State state;
      Vector2 position;
      Vector2 velocity;
   };
protected:
   bool can_move: 1 = true;
   bool applying_thrust: 1 = false;
   float HP = 0;
   float path_arcing = 0.0;
   float turnrate = 0.0;
   float thrust = 0.0;
   float mass = 1.0;
   
   float time_to_turn = 0;
   float time_to_move = 0;
   float distance_to_target = 0;
   float angle_to_target = 0;
   
   float angular_velocity = 0;
   Vector2 velocity = {0, 0};
   Vector2 force = {0, 0};
   List<Ref<Command>> move_commands;
   Ref<RadarSignature> radar_signature;
   Ref<Command> target;
   static void _bind_methods();
   void _draw() override;
   void _process(double _dt) override;
   void _physics_process(double dt) override;
public:
   void hit(float damage);
   void kill();
   void stop_moving();
   void stop_targeting();
   void queue_move(Ref<Command> new_command);
   void set_target(Ref<Command> new_target);
   virtual void attack(Unit& prey, Ref<Command> command);
   Ref<const RadarSignature> lock_on();
};

#endif