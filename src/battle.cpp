#include <godot_cpp/core/math.hpp>
#include "battle.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                      battle.cpp                       |
|                                                       |
*------------------------------------------------------*/

using godot::Math::clamp;
using godot::Math::min;
using godot::Math::max;

Battle::State Battle::get_state() {
   return state;
}
Ref<Battle::Team> Battle::get_winner() {
   return winner;
}
Ref<Battle::Team> Battle::new_team(String name) {
   Ref<Team> team;
   team.instantiate();
   team->set_name(name);
   teams.append(team);
   return team;
}
Battle::Player* Battle::new_player() {
   Player* player = memnew(Player);
   add_child(player);
   return player;
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
void Battle::set_duration_sec(double new_duration_sec) {
   duration_sec = clamp(new_duration_sec, MIN_DURATION_SEC, MAX_DURATION_SEC);
}
void Battle::set_countdown_sec(double new_countdown_sec) {
   countdown_sec = clamp(new_countdown_sec, MIN_COUNTDOWN_SEC, MAX_COUNTDOWN_SEC);
}
void Battle::start() {
   if (state == RUNNING) stop();
   time_left_sec = duration_sec;
   winner.unref();
   state = RUNNING;
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
   if ((time_left_sec -= dt) > 0) return;
   if (state == RUNNING) stop();
   if (state == STARTING) start();
}



float Battle::Gamemode::get_alloy_bounty() {
   return alloy_bounty;
}
float Battle::Gamemode::get_energy_bounty() {
   return energy_bounty;
}
void Battle::Gamemode::set_alloy_bounty(float new_alloy_bounty) {
   alloy_bounty = max<float>(0.0, new_alloy_bounty);
}
void Battle::Gamemode::set_energy_bounty(float new_energy_bounty) {
   energy_bounty = max<float>(0.0, new_energy_bounty);
}



String Battle::Team::get_name() {
   return name;
}
void Battle::Team::set_name(String new_name) {
   ERR_FAIL_COND(new_name.length() < MIN_NAME_LENGTH);

   name = new_name;
}
int Battle::Team::count_celestials_captured() {
   return celestials_captured;
}
int Battle::Team::count_kills() {
   return kills;
}
int Battle::Team::count_losses() {
   return losses;
}
float Battle::Team::get_net_value() {
   return value_killed - value_lost;
}
double Battle::Team::get_alloy_per_sec() {
   return alloy_per_sec;
}
double Battle::Team::get_energy_per_sec() {
   return energy_per_sec;
}
void Battle::Team::register_kill(Destructable& kill) {
   value_killed += kill.get_cost();
   kills++;
}
void Battle::Team::register_loss(Destructable& loss) {
   value_lost += loss.get_cost();
   losses++;
}
void Battle::Team::register_capture(Capturable& capturable) {
   /*------------------------------------------------------*
   | NOTE: Repeatedly adding to and subtracting from       |
   | alloy_per_sec and energy_per_sec can cause rounding   |
   | errors. These errors should be orders of magnitude    |
   | less than what would be considered noticeable, but    |
   | we've made both doubles as a precaution.              |
   *------------------------------------------------------*/
   alloy_per_sec  += capturable.get_alloy_per_sec();
   energy_per_sec += capturable.get_energy_per_sec();
   celestials_captured++;
}
void Battle::Team::register_forfeit(Capturable& capturable) {
   /*------------------------------------------------------*
   |       (See previous comment on rounding errors)       |
   *------------------------------------------------------*/
   alloy_per_sec  -= capturable.get_alloy_per_sec();
   energy_per_sec -= capturable.get_energy_per_sec();
   celestials_captured--;
}



float Battle::Player::get_energy() {
   return energy;
}
int Battle::Player::get_alloy() {
   return alloy;
}
Ref<Battle::Team> Battle::Player::get_team() {
   return team;
}
void Battle::Player::set_team(Ref<Team> new_team) {
   ERR_FAIL_COND(new_team.is_null());

   team = new_team;
}
void Battle::Player::register_kill(Destructable& kill) {
   if (team.is_valid()) team->register_kill(kill);

   ERR_FAIL_COND( !battle || battle->gamemode.is_null());

   alloy  += kill.get_cost()   * battle->gamemode->get_alloy_bounty();
   energy += kill.get_energy() * battle->gamemode->get_energy_bounty();
}
void Battle::Player::register_loss(Destructable& loss) {
   if (team.is_valid()) team->register_loss(loss);
}
void Battle::Player::_physics_process(double dt) {
   if (team.is_null()) return;

   alloy  = min(alloy  + dt * team->get_alloy_per_sec(), ALLOY_CAPACITY);
   energy = min(energy + dt * team->get_energy_per_sec(), ENERGY_CAPACITY);
}