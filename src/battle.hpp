#ifndef BATTLE_HPP
#define BATTLE_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include "capturable.hpp"
#include "destructable.hpp"
#include "player.hpp"
#include "map.hpp"

namespace godot {

class Gamemode;

class Battle: public Node2D {
   GDCLASS(Battle, Node2D)
public:
   enum State {STOPPED, STARTING, RUNNING};
   static constexpr double MIN_COUNTDOWN_SEC = 3.0;
   static constexpr double MAX_COUNTDOWN_SEC = 60.0;
   static constexpr double MIN_DURATION_SEC = 5.0;
   static constexpr double MAX_DURATION_SEC = 600.0;

   Battle();
   State get_state();
   Ref<Team> get_winner();
   uint64_t get_seed();
   Ref<Map> get_map();
   Player* get_client();
   int get_seconds_left();
   int get_minutes_left();
   double get_time_left_sec();
   double get_duration_sec();
   double get_countdown_sec();
   void set_map(Ref<Map> new_map);
   void set_seed(uint64_t new_seed);
   void set_duration_sec(double new_duration_sec);
   void set_countdown_sec(double new_countdown_sec);
   Ref<Team> new_team(String name);
   Player* new_player();
   void start();
   void start_countdown();
   void stop();
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   State state = STOPPED;
   double time_left_sec = 0.0;
   double duration_sec = 0.0;
   double countdown_sec = 0.0;
   Ref<Team> winner;
   Ref<Gamemode> gamemode;
   Vector<Ref<Team>> teams;
   Ref<RandomNumberGenerator> rng;
   Ref<Map> map;
   Node2D* map_root = nullptr;

   void generate_map();
};

class Gamemode: public RefCounted {
   GDCLASS(Gamemode, RefCounted)
public:

protected:
   static void _bind_methods();
private:
   bool FFA = false;
   bool teams_are_filled = false;
   bool allow_team_imbalance = false;
   double starting_alloy = 2000.0;
   double starting_energy = 2000.0;
   Vector<String> team_names;
};

}

VARIANT_ENUM_CAST(Battle::State);

#endif // BATTLE_HPP