#include "battle.hpp"

using namespace godot;

Battle::Battle() {
   Ref<Team> spectators = memnew(Team);
   winner     = spectators;
   teams      = {spectators};
   teams_left = {spectators};
   team_balance.new_set();
   set_physics_process(false);
}
Battle::~Battle() {
   destroy_map();
}
bool Battle::is_map_generated() const {
   /*------------------------------------------------------|
   | The map_root node should never be used outside this   |
   | class. Regardless, it is still possible to access and |
   | free map_root externally, so we have to check if the  |
   | pointer is still valid.                               |
   |------------------------------------------------------*/
   return UtilityFunctions::is_instance_valid(generated_map.map_root);
}
NO_ERROR_CHECK bool Battle::is_team_balanced(Ref<Team> team) const {
   int root_team = team_balance.find_root(team->id);
   int root_size = teams[root_team]->num_players;

   return team->num_players == root_size;
}
bool Battle::has_player_id(int player_id) const {
   return 0 <= player_id && player_id < players.size();
}
bool Battle::has_team_id(int team_id) const {
   return 0 <= team_id && team_id < teams.size();
}
bool Battle::has_player(Ref<Player> player) const {
   return player.is_valid() && has_player_id(player->id) && player == players[player->id];
}
bool Battle::has_team(Ref<Team> team) const {
   return team.is_valid() && has_team_id(team->id) && team == teams[team->id];
}
int Battle::count_unbalanced_teams() const {
   return num_unbalanced_teams;
}
int Battle::count_capturables() const {
   return generated_map.num_capturables;
}
int Battle::get_num_capturables_to_win() const {
   return num_capturables_to_win;
}
int Battle::count_players() const {
   return players.size();
}
int Battle::count_teams() const {
   return teams.size() - NUM_SPECTATOR_TEAMS;
}
int Battle::count_teams_left() const {
   return teams_left.size() - NUM_SPECTATOR_TEAMS;
}
uint64_t Battle::get_seed() const {
   return rng->get_seed();
}
Ref<Map> Battle::get_map() const {
   return map;
}
Ref<Team> Battle::get_winner() const {
   return winner;
}
Ref<Team> Battle::get_spectators() const {
   return teams[SPECTATORS_ID];
}
NO_ERROR_CHECK Ref<Team> Battle::get_team(int team_id) const {
   return teams[team_id];
}
NO_ERROR_CHECK Ref<Player> Battle::get_player(int player_id) const {
   return players[player_id];
}
void Battle::set_seed(uint64_t seed) {
   rng->set_seed(seed);
}
Battle::State Battle::get_state() const {
   return state;
}
double Battle::get_starting_alloy() const {
   return starting_alloy;
}
double Battle::get_starting_energy() const {
   return starting_energy;
}
double Battle::get_starting_alloy_per_sec() const {
   return starting_alloy_per_sec;
}
double Battle::get_starting_energy_per_sec() const {
   return starting_energy_per_sec;
}
void Battle::set_num_capturables_to_win(int new_num_capturables_to_win) {
   num_capturables_to_win = Math::max(new_num_capturables_to_win, 0);
}
void Battle::set_domination_victory_ratio(double domination_victory_ratio) {
   set_num_capturables_to_win(domination_victory_ratio * generated_map.num_capturables);
}
void Battle::set_starting_alloy(double new_starting_alloy) {
   starting_alloy = Math::max(new_starting_alloy, 0.0);
}
void Battle::set_starting_energy(double new_starting_energy) {
   starting_energy = Math::max(new_starting_energy, 0.0);
}
void Battle::set_starting_alloy_per_sec(double new_starting_alloy_per_sec) {
   starting_alloy_per_sec = Math::max(new_starting_alloy_per_sec, 0.0);
}
void Battle::set_starting_energy_per_sec(double new_starting_alloy_per_sec) {
   starting_energy_per_sec = Math::max(new_starting_alloy_per_sec, 0.0);
}
void Battle::set_map(Ref<Map> new_map) {
   ERR_FAIL_NULL_MSG(new_map,
   "<Battle> Map is null (failed to set map)");

   map = new_map;
}
Battle::Error Battle::set_team(Ref<Player> player, Ref<Team> team) {
   if (unlikely( !has_player(player) )) return PLAYER_NOT_FOUND;
   if (unlikely( !has_team(team) )) return TEAM_NOT_FOUND;

   ++team->num_players;
   ++team->num_players_alive;
   --player->team->num_players;
   --player->team->num_players_alive;
   player->team = team;
   return OKAY;
}
Battle::Error Battle::start_countdown() {
   if (state == STARTING) return WRONG_STATE;

   calculate_team_balance();
   if (num_unbalanced_teams != 0) return UNBALANCED_TEAMS;

   state = STARTING;
   emit_signal("started_countdown");
   return OKAY;
}
Battle::Error Battle::start() {
   if (state == RUNNING) return WRONG_STATE;

   calculate_team_balance();
   if (num_unbalanced_teams != 0) return UNBALANCED_TEAMS;

   state = RUNNING;
   winner.unref();
   reset_players_and_teams();
   destroy_map();
   generated_map = map->generate(rng, *this);
   set_physics_process(true);
   emit_signal("started");
   return OKAY;
}
Battle::Error Battle::stop() {
   state = STOPPED;
   set_physics_process(false);
   emit_signal("stopped");
   return OKAY;
}
Battle::Error Battle::declare_winner() {
   return declare_winning_team( *teams_left.end());
}
Battle::Error Battle::declare_winning_team(Ref<Team> team) {
   if (state != RUNNING) return WRONG_STATE;

   winner = team;
   stop();
   return OKAY;
}
Ref<Player> Battle::connect_player(String player_name, Color color) {
   Ref<Player> player = memnew(Player);

   player->id = players.size();
   player->set_name(player_name);
   player->set_color(color);
   set_team(player, get_spectators());
   players.push_back(player);
   return player;
}
Battle::Error Battle::disconnect_player(Ref<Player> player) {
   if (unlikely( !has_player(player) )) return PLAYER_NOT_FOUND;

   int back = players.size() - 1;
   /*------------------------------------------------------|
   | Remove from the back so we have fewer ids to fix. We  |
   | get O(1) deletion for free by using the ids.          |
   |------------------------------------------------------*/
   players[back]->id = player->id;
   players.set(player->id, players[back] );
   players.remove_at(back);
   player->id = -1;
   return OKAY;
}
void Battle::disconnect_all_players() {
   players.clear();
}
Ref<Team> Battle::add_team(String team_name) {
   ERR_FAIL_COND_V_MSG(state != STOPPED, nullptr,
   "<Battle> Cannot add teams while battle is running!");

   Ref<Team> team = memnew(Team);

   team->id = teams.size();
   team->set_name(team_name);
   team_balance.new_set();
   teams.push_back(team);
   return team;
}
void Battle::reset_teams() {
   teams = {get_spectators()};
   team_balance = {};
   team_balance.new_set();
}
Battle::Error Battle::autobalance(Ref<Team> team, Ref<Team> other_team) {
   if (unlikely( !has_team(team) || !has_team(other_team) )) return TEAM_NOT_FOUND;

   team_balance.merge(team->id, other_team->id);
   return OKAY;
}
void Battle::reset_autobalance() {
   team_balance.reset();
}
void Battle::kill_team(Ref<Team> team) {
   teams_left.erase(team);
   if (count_teams_left() == 0) declare_winner();
}
Battle::Error Battle::kill_player(Ref<Player> player) {
   if (unlikely( !has_player(player))) return PLAYER_NOT_FOUND;
   if (unlikely( !player->is_alive)) return OKAY;

   // We need to check the win conditions every time a player dies
   Ref<Team> team   = player->team;
   player->is_alive = false;
   if ( --team->num_players_alive <= 0 || team->sudden_death) kill_team(team);
   return OKAY;
}
Ship* Battle::spawn_ship(Ref<Player> player, Ref<ShipData> ship_data, Vector2 spawnpoint) {
   if (unlikely( !has_player(player) || !is_map_generated() )) return nullptr;

   Ship* ship = Ship::create_from(ship_data);

   if (unlikely( !ship)) return nullptr;

   generated_map.map_root->add_child(ship);
   ship->set_player_owner(player);
   ship->set_position(spawnpoint);
   emit_signal("spawned_ship", ship);
   return ship;
}
void Battle::_physics_process(double dt) {
   for (Ref<Player> player: players) {
      player->_tick_resources(dt);
   }
}
void Battle::destroy_map() {
   if ( !is_map_generated()) return;
   
   generated_map.map_root->queue_free();
   generated_map = {0, 0.0, nullptr};
}
void Battle::calculate_team_balance() {
   num_unbalanced_teams = 0;

   for (const Ref<Team> team: teams) {
      num_unbalanced_teams += !is_team_balanced(team);
   }
}
void Battle::reset_player(Ref<Player> player) {
   player->is_alive = true;
   player->alloy    = starting_alloy;
   player->energy   = starting_energy;
}
void Battle::reset_team(Ref<Team> team) {
   team->alloy_per_sec     = starting_alloy_per_sec;
   team->energy_per_sec    = starting_energy_per_sec;
   team->value_killed      = 0.0;
   team->value_lost        = 0.0;
   team->kills             = 0;
   team->losses            = 0;
   team->celestials_owned  = 0;
   team->num_players_alive = team->num_players;
}
void Battle::reset_players_and_teams() {
   teams_left = teams.duplicate();

   for (Ref<Player> player: players) {
      reset_player(player);
   }
   for (Ref<Team> team: teams) {
      reset_team(team);
   }
}