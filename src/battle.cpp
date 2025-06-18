#include <godot_cpp/core/math.hpp>
#include "battle.hpp"

using namespace godot;

Battle::Battle() {
   rng.instantiate();
}
Ref<Map> Battle::get_map() {
   return map;
}
uint64_t Battle::get_seed() {
   return rng->get_seed();
}
Battle::State Battle::get_state() {
   return state;
}
Ref<Team> Battle::get_winner() {
   return winner;
}
int Battle::get_seconds_left() {
   return static_cast<int>(time_left_sec) % 60;
}
int Battle::get_minutes_left() {
   return static_cast<int>(time_left_sec / 60);
}
double Battle::get_time_left_sec() {
   return time_left_sec;
}
double Battle::get_duration_sec() {
   return duration_sec;
}
double Battle::get_countdown_sec() {
   return countdown_sec;
}
void Battle::set_map(Ref<Map> new_map) {
   ERR_FAIL_COND(new_map.is_null());

   map = new_map;
}
void Battle::set_seed(uint64_t seed) {
   rng->set_seed(seed);
}
void Battle::set_duration_sec(double new_duration_sec) {
   duration_sec = Math::clamp(new_duration_sec, MIN_DURATION_SEC, MAX_DURATION_SEC);
}
void Battle::set_countdown_sec(double new_countdown_sec) {
   countdown_sec = Math::clamp(new_countdown_sec, MIN_COUNTDOWN_SEC, MAX_COUNTDOWN_SEC);
}
Ref<Team> Battle::new_team(String name) {
   if (state != STOPPED) {
      WARN_PRINT_ED("Cannot add team after battle has started");
      return nullptr;
   }
   Ref<Team> team;
   team.instantiate();
   team->set_name(name);
   teams.append(team);
   return team;
}
Player* Battle::new_player() {
   Player* player = memnew(Player);
   add_child(player);
   return player;
}
void Battle::generate_map() {
   ERR_FAIL_COND(map.is_null());

   if (map_root) map_root->queue_free();
   map_root = memnew(Node2D);
   add_child(map_root);
   map->generate(rng, map_root, Map::STANDARD_DEPTH_LIMIT);
}
void Battle::start() {
   if (state == RUNNING) stop();
   time_left_sec = duration_sec;
   state = RUNNING;
   winner.unref();
   generate_map();
}
void Battle::start_countdown() {
   if (state == RUNNING) stop();
   time_left_sec = countdown_sec;
   state = STARTING;
}
void Battle::stop() {
   state = STOPPED;
}
void Battle::_physics_process(double dt) {
   if (state == STOPPED) return;
   time_left_sec -= dt;
   if (time_left_sec > 0) return;
   if (state == RUNNING) stop();
   if (state == STARTING) start();
}