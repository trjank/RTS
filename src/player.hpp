#ifndef PLAYER_HPP
#define PLAYER_HPP

#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "capturable.hpp"
#include "destructable.hpp"

namespace godot {

class Team;

class Player: public Node2D {
   GDCLASS(Player, Node2D)
public:
   static constexpr int MAX_NAME_LENGTH = 30;
   static constexpr int MAX_CLAN_LENGTH = 4;
   static constexpr double ALLOY_LIMIT = 1.0e5;
   static constexpr double ENERGY_LIMIT = 1.0e5;
   Player();
   double get_energy();
   double get_alloy();
   Color get_color();
   String get_name();
   String get_clan();
   Ref<Team> get_team();
   void set_color(Color new_color);
   void set_name(String new_name);
   void set_clan(String new_clan);
   void set_team(Ref<Team> new_team);
   void register_kill(Destructable& kill);
   void register_loss(Destructable& loss);
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   int rank = 0;
   double energy = 0.0;
   double alloy = 0.0;
   double energy_bounty;
   double alloy_bounty;
   String name = "<unnamed>";
   String clan = "";
   Color color = {0.0, 0.0, 0.0, 1.0};
   Ref<Team> team = nullptr;
};

class Team: public RefCounted {
   GDCLASS(Team, RefCounted)
public:
   static constexpr int MAX_NAME_LENGTH = 20;
   String get_name();
   void set_name(String new_name);
   int count_celestials_captured();
   int count_kills();
   int count_losses();
   float get_net_value();
   double get_alloy_per_sec();
   double get_energy_per_sec();
   Color get_color();
   void set_color(Color new_color);
   void register_kill(Destructable& ship);
   void register_loss(Destructable& ship);
   void register_capture(Capturable& capturable);
   void register_forfeit(Capturable& capturable);
protected:
   static void _bind_methods();
private:
   double alloy_per_sec = 0.0;
   double energy_per_sec = 0.0;
   int player_capacity = 0;
   int celestials_captured = 0;
   int kills = 0;
   int losses = 0;
   float value_killed = 0.0;
   float value_lost = 0.0;
   Color color = {0.0, 0.0, 0.0, 1.0};
   String name = "<unnamed>";
   Vector<Player*> players;
};

}

#endif // PLAYER_HPP