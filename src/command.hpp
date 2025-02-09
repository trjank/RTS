#ifndef COMMAND_HPP
#define COMMAND_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include "unit.hpp"

using godot::Sprite2D;
using godot::Vector2;
using godot::Ref;
using godot::RefCounted;

class Command: public RefCounted {
   GDCLASS(Command, RefCounted)
   bool valid;
   Sprite2D* icon;
protected:
   static void _bind_methods();
   Ref<const Unit::RadarSignature> target_lock;
   Command();
   ~Command();
public:
   void invalidate();
   bool is_valid();
   Vector2 get_position();
   void move_to(Vector2 new_position);
   void ram(Unit& prey);
   void kite(Unit& prey);
   void flee(Unit& predator, Unit& prey, float safe_distance);
   void track(Unit& predator, Unit& prey);
   void execute_from(Unit& caller);
   virtual void attack(Unit& predator, Unit& prey);
};

#endif