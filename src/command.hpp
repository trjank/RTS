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
   Unit* predator;
   Ref<const Unit::RadarSignature> prey;
   Command();
   ~Command();
public:
   void invalidate();
   bool is_valid();
   Vector2 get_position();
   bool is_controlled_by(Unit* caller);
   void move_to(Vector2 new_position);
   void ram();
   void kite(float min_distance, float max_distance);
   void flee(float safe_distance);
   void track();
};

#endif