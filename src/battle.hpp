#ifndef BATTLE_HPP
#define BATTLE_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>

using godot::Ref;
using godot::Vector;
using godot::String;
using godot::Node2D;
using godot::RefCounted;

class Battle: public Node2D {
   GDCLASS(Battle, Node2D)
public:
   class Team;
   Ref<Team> new_team(String name);
private:
   Vector<Ref<Team>> teams;
   float countdown;
   float duration;
   float time;
   bool start(float duration);
   void end();
};

class Battle::Team: public RefCounted {
   GDCLASS(Team, RefCounted)
public:
   static constexpr int MIN_NAME_LENGTH = 5;
   String get_name();
   void set_name(String new_name);
   int get_n_captured();
   int get_ships_killed();
   float get_net_value();
private:
   String name;
   int n_terrestrial_planets = 0;
   int n_jovian_planets = 0;
   int n_moons = 0;
   int ships_killed = 0;
   float value_killed = 0.0;
   float value_lost = 0.0;
};

#endif // BATTLE_HPP