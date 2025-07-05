#ifndef BATTLE_HPP
#define BATTLE_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "player.hpp"
#include "ship.hpp"
#include "map.hpp"
#include "defaults.hpp"
#include "disjoint_sets.hpp"

namespace godot {

class Battle: public Node2D {
   GDCLASS(Battle, Node2D)
public:
   enum State {STOPPED, STARTING, RUNNING};
   enum Error {OKAY, TEAM_NOT_FOUND, PLAYER_NOT_FOUND, WRONG_STATE, UNBALANCED_TEAMS};

   static constexpr int SPECTATORS_ID = 0;
   static constexpr int NUM_SPECTATOR_TEAMS = 1;

   Battle();
   ~Battle();
   bool is_map_generated() const;
   NO_ERROR_CHECK bool is_team_balanced(Ref<Team> team) const;
   bool has_player_id(int player_id) const;
   bool has_team_id(int team_id) const;
   bool has_player(Ref<Player> player) const;
   bool has_team(Ref<Team> team) const;
   int count_unbalanced_teams() const;
   int count_capturables() const;
   int get_num_capturables_to_win() const;
   int count_players() const;
   int count_teams() const;
   int count_teams_left() const;
   uint64_t get_seed() const;
   Ref<Map> get_map() const;
   Ref<Team> get_winner() const;
   Ref<Team> get_spectators() const;
   NO_ERROR_CHECK Ref<Team> get_team(int team_id) const;
   NO_ERROR_CHECK Ref<Player> get_player(int player_id) const;
   State get_state() const;
   double get_starting_alloy() const;
   double get_starting_energy() const;
   double get_starting_alloy_per_sec() const;
   double get_starting_energy_per_sec() const;
   void set_num_capturables_to_win(int new_num_capturables_to_win);
   void set_domination_victory_ratio(double domination_victory_ratio);
   void set_starting_alloy(double new_starting_alloy);
   void set_starting_energy(double new_starting_energy);
   void set_starting_alloy_per_sec(double new_starting_alloy_per_sec);
   void set_starting_energy_per_sec(double new_starting_alloy_per_sec);
   void set_map(Ref<Map> new_map);
   void set_seed(uint64_t new_seed);
   Error set_team(Ref<Player> player, Ref<Team> team);
   Error start_countdown();
   Error start();
   Error stop();
   Error declare_winner();
   Error declare_winning_team(Ref<Team> team);
   Error autobalance(Ref<Team> team, Ref<Team> other_team);
   void reset_autobalance();
   Ref<Player> connect_player(String player_name, Color color);
   Error disconnect_player(Ref<Player> player);
   void disconnect_all_players();
   Error kill_player(Ref<Player> player);
   void kill_team(Ref<Team> team);
   Ref<Team> add_team(String team_name);
   void reset_teams();
   Ship* spawn_ship(Ref<Player> player, Ref<ShipData> ship_data, Vector2 spawnpoint);
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   State state = STOPPED;
   int num_unbalanced_teams = 0;
   int num_capturables_to_win = 0;
   double starting_alloy = 1000.0;
   double starting_energy = 1000.0;
   double starting_alloy_per_sec = 10.0;
   double starting_energy_per_sec = 10.0;
   NEVER_NULL Ref<Team> winner;
   NEVER_NULL Ref<RandomNumberGenerator> rng;
   NEVER_NULL Ref<Map> map = get_default<Map>();
   Vector<Ref<Player>> players;
   Vector<Ref<Team>> teams;
   Vector<Ref<Team>> teams_left;
   DisjointSets team_balance;
   Map::Result generated_map = {0, 0.0, nullptr};

   void destroy_map();
   void calculate_team_balance();
   void reset_players_and_teams();
   void reset_team(Ref<Team> team);
   void reset_player(Ref<Player> player);
};

}

VARIANT_ENUM_CAST(Battle::State);
VARIANT_ENUM_CAST(Battle::Error);

#endif // BATTLE_HPP