#ifndef PLAYER_HPP
#define PLAYER_HPP

#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include "capturable.hpp"
#include "destructable.hpp"
#include "defaults.hpp"

namespace godot {

class Team: public RefCounted {
   GDCLASS(Team, RefCounted)
public:
   static constexpr int MAX_NAME_LENGTH = 20;

   bool is_sudden_death() const;
   int count_players() const;
   int count_players_alive() const;
   int count_celestials_owned() const;
   int count_kills() const;
   int count_losses() const;
   double get_value_killed() const;
   double get_value_lost() const;
   double get_net_value() const;
   double get_alloy_per_sec() const;
   double get_energy_per_sec() const;
   String get_name() const;
   Color get_color() const;
   void set_sudden_death(bool make_sudden_death);
   void set_name(String new_name);
   void set_color(Color new_color);
   void register_kill(const Destructable& ship);
   void register_loss(const Destructable& ship);
   void register_capture(const Capturable& capturable);
   void register_forfeit(const Capturable& capturable);
protected:
   static void _bind_methods();
private:
   bool sudden_death = false;
   int num_players = 0;
   int num_players_alive = 0;
   int id = 0;
   int kills = 0;
   int losses = 0;
   int celestials_owned = 0;
   double alloy_per_sec = 0.0;
   double energy_per_sec = 0.0;
   double value_killed = 0.0;
   double value_lost = 0.0;
   String name = "Spectators";
   Color color = {1.0F, 1.0F, 1.0F, 1.0F};

   friend class Battle;
};


class Player: public RefCounted {
   GDCLASS(Player, RefCounted)
public:
   static constexpr int MAX_NAME_LENGTH = 50;
   static constexpr double MIN_ALLOY = 0.0;
   static constexpr double MIN_ENERGY = 0.0;
   static constexpr double MAX_ALLOY = 10000.0;
   static constexpr double MAX_ENERGY = 10000.0;

   double get_alloy() const;
   double get_energy() const;
   double get_alloy_bounty() const;
   double get_energy_bounty() const;
   Color get_color() const;
   String get_name() const;
   Ref<Team> get_team() const;
   void set_alloy_bounty(double new_alloy_bounty);
   void set_energy_bounty(double new_energy_bounty);
   void set_color(Color new_color);
   void set_name(String new_name);
   void register_kill(const Destructable& kill);
   void register_loss(const Destructable& loss);
protected:
   static void _bind_methods();
private:
   bool is_alive = false;
   int id = -1;
   double energy = 0.0;
   double alloy = 0.0;
   double energy_bounty = 0.0;
   double alloy_bounty = 0.0;
   Color color = {0.0F, 0.0F, 0.0F, 1.0F};
   String name = "<unnamed>";
   NEVER_NULL Ref<Team> team = get_default<Team>();

   void _tick_resources(double dt);

   friend class Battle;
};

}

#endif // PLAYER_HPP