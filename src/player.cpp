#include "player.hpp"

using namespace godot;

Player::Player() {
   team.instantiate();
}
double Player::get_energy() {
   return energy;
}
double Player::get_alloy() {
   return alloy;
}
Color Player::get_color() {
   return color;
}
String Player::get_name() {
   return name;
}
String Player::get_clan() {
   return clan;
}
Ref<Team> Player::get_team() {
   return team;
}
void Player::set_color(Color new_color) {
   color = new_color;
   color.a = 1.0;
}
void Player::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
}
void Player::set_clan(String new_name) {
   name = new_name.substr(0, MAX_CLAN_LENGTH);
}
void Player::set_team(Ref<Team> new_team) {
   if (new_team.is_null())
      team.instantiate();
   else
      team = new_team;
}
void Player::register_kill(Destructable& kill) {
   if (team.is_valid()) team->register_kill(kill);
   alloy  += kill.get_cost() * alloy_bounty;
   energy += kill.get_energy() * energy_bounty;
}
void Player::register_loss(Destructable& loss) {
   if (team.is_valid()) team->register_loss(loss);
}
void Player::_physics_process(double dt) {
   alloy  = Math::min(alloy + team->get_alloy_per_sec() * dt, ALLOY_LIMIT);
   energy = Math::min(energy + team->get_energy_per_sec() * dt, ENERGY_LIMIT);
}


String Team::get_name() {
   return name;
}
void Team::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
}
int Team::count_celestials_captured() {
   return celestials_captured;
}
int Team::count_kills() {
   return kills;
}
int Team::count_losses() {
   return losses;
}
float Team::get_net_value() {
   return value_killed - value_lost;
}
double Team::get_alloy_per_sec() {
   return alloy_per_sec;
}
double Team::get_energy_per_sec() {
   return energy_per_sec;
}
Color Team::get_color() {
   return color;
}
void Team::set_color(Color new_color) {
   color = new_color;
}
void Team::register_kill(Destructable& kill) {
   ++kills;
   value_killed += kill.get_cost();
}
void Team::register_loss(Destructable& loss) {
   ++losses;
   value_lost += loss.get_cost();
}
void Team::register_capture(Capturable& capturable) {
   ++celestials_captured;
   alloy_per_sec  += capturable.get_alloy_per_sec();
   energy_per_sec += capturable.get_energy_per_sec();
}
void Team::register_forfeit(Capturable& capturable) {
   --celestials_captured;
   alloy_per_sec  -= capturable.get_alloy_per_sec();
   energy_per_sec -= capturable.get_energy_per_sec();
}