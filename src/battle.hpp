#ifndef BATTLE_HPP
#define BATTLE_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "capturable.hpp"
#include "destructable.hpp"
#include "part_data.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                      battle.hpp                       |
|                                                       |
*------------------------------------------------------*/

using godot::Ref;
using godot::Vector;
using godot::String;
using godot::Node2D;
using godot::RefCounted;
using godot::Color;

// class Fleet;

class Battle: public Node2D {
   GDCLASS(Battle, Node2D)
public:
   class Gamemode;
   class Team;
   class Player;
   enum State { STOPPED, STARTING, RUNNING };

   static constexpr double MIN_COUNTDOWN_SEC = 3.0;
   static constexpr double MAX_COUNTDOWN_SEC = 60.0;
   static constexpr double MIN_DURATION_SEC = 5.0;
   static constexpr double MAX_DURATION_SEC = 600.0;

   State get_state();
   Ref<Team> get_winner();
   Ref<Team> new_team(String name);
   Player* new_player();
   int get_seconds_left();
   int get_minutes_left();
   double get_time_left_sec();
   double get_duration_sec();
   double get_countdown_sec();
   void set_duration_sec(double new_duration_sec);
   void set_countdown_sec(double new_countdown_sec);
   void start();
   void start_countdown();
   void stop();
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   State state;
   Ref<Team> winner;
   Ref<Gamemode> gamemode;
   Vector<Ref<Team>> teams;
   double duration_sec = 0.0;
   double countdown_sec = 5.0;
   double time_left_sec = 0.0;
   friend class Team;
};

class Battle::Gamemode: public RefCounted {
   GDCLASS(Gamemode, RefCounted)
public:
   /*------------------------------------------------------*
   | When a player kills a ship, they receive a percentage |
   | of the ship's alloy cost and energy. The exact ratios |
   | are stored as alloy_bounty and energy_bounty.         |
   *------------------------------------------------------*/
   float get_alloy_bounty();
   float get_energy_bounty();
   void set_alloy_bounty(float new_alloy_bounty);
   void set_energy_bounty(float new_energy_bounty);
protected:
   static void _bind_methods();
private:
   bool FFA = false;
   bool teams_are_filled = false;
   bool allow_team_imbalance = false;
   float alloy_bounty = 0.0;
   float energy_bounty = 0.0;
   double starting_alloy = 2000.0;
   double starting_energy = 2000.0;
   Vector<String> team_names;
};

class Battle::Team: public RefCounted {
   GDCLASS(Team, RefCounted)
public:
   static constexpr int MIN_NAME_LENGTH = 5;

   String get_name();
   void set_name(String new_name);
   int count_celestials_captured();
   int count_kills();
   int count_losses();
   float get_net_value();
   double get_alloy_per_sec();
   double get_energy_per_sec();
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
   String name;
   Vector<Player*> players;
};

class Battle::Player: public Node2D {
   GDCLASS(Player, Node2D)
public:
   static constexpr double ALLOY_CAPACITY = 1.0e5;
   static constexpr double ENERGY_CAPACITY = 1.0e5;

   float get_energy();
   int get_alloy();
   Ref<Team> get_team();
   void set_team(Ref<Team> new_team);
   void register_kill(Destructable& kill);
   void register_loss(Destructable& loss);
   void _physics_process(double dt) override;
private:
   int rank;
   float energy = 0.0;
   float alloy = 0.0;
   String name;
   Color color;
   Ref<Team> team;
   // Ref<Fleet> fleet;
   Battle* battle = nullptr;
};

VARIANT_ENUM_CAST(Battle::State);

#endif // BATTLE_HPP