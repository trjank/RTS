#include "player.hpp"

using namespace godot;

bool Team::is_sudden_death() const {
   return sudden_death;
}
int Team::count_players() const {
   return num_players;
}
int Team::count_players_alive() const {
   return num_players_alive;
}
int Team::count_kills() const {
   return kills;
}
int Team::count_losses() const {
   return losses;
}
int Team::count_celestials_owned() const {
   return celestials_owned;
}
String Team::get_name() const {
   return name;
}
Color Team::get_color() const {
   return color;
}
double Team::get_value_killed() const {
   return value_killed;
}
double Team::get_value_lost() const {
   return value_lost;
}
double Team::get_net_value() const {
   return value_killed - value_lost;
}
double Team::get_alloy_per_sec() const {
   return alloy_per_sec;
}
double Team::get_energy_per_sec() const {
   return energy_per_sec;
}
void Team::set_sudden_death(bool make_sudden_death) {
   sudden_death = make_sudden_death;
}
void Team::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
}
void Team::set_color(Color new_color) {
   new_color.a = 1.0F;
   color = new_color;
}
/*------------------------------------------------------|
| None of these methods provide any sort of validation  |
| or check for duplicates, which can provide some       |
| flexibility. They are not exposed to the editor to    |
| prevent some tampering, so be careful using them.     |
|------------------------------------------------------*/
void Team::register_kill(const Destructable& kill) {
   ++kills;
   value_killed += kill.get_cost();
}
void Team::register_loss(const Destructable& loss) {
   ++losses;
   value_lost += loss.get_cost();
}
void Team::register_capture(const Capturable& capturable) {
   ++celestials_owned;
   alloy_per_sec  += capturable.get_alloy_per_sec();
   energy_per_sec += capturable.get_energy_per_sec();
}
void Team::register_forfeit(const Capturable& capturable) {
   --celestials_owned;
   alloy_per_sec  -= capturable.get_alloy_per_sec();
   energy_per_sec -= capturable.get_energy_per_sec();
}


double Player::get_alloy() const {
   return alloy;
}
double Player::get_energy() const {
   return energy;
}
double Player::get_alloy_bounty() const {
   return alloy_bounty;
}
double Player::get_energy_bounty() const {
   return energy_bounty;
}
Color Player::get_color() const {
   return color;
}
String Player::get_name() const {
   return name;
}
Ref<Team> Player::get_team() const {
   return team;
}
void Player::set_alloy_bounty(double new_alloy_bounty) {
   alloy_bounty = Math::max(new_alloy_bounty, 0.0);
}
void Player::set_energy_bounty(double new_energy_bounty) {
   energy_bounty = Math::max(new_energy_bounty, 0.0);
}
void Player::set_color(Color new_color) {
   color = new_color;
   emit_signal("changed_color", color);
}
void Player::set_name(String new_name) {
   name = new_name.substr(0, MAX_NAME_LENGTH);
   emit_signal("changed_name", name);
}
/*------------------------------------------------------|
| Similar to the versions in Team, these methods don't  |
| provide any sort of validation or check for           |
| duplicates. Be careful using them.                    |
|------------------------------------------------------*/
void Player::register_kill(const Destructable& kill) {
   team->register_kill(kill);
   alloy  += kill.get_cost() * alloy_bounty;
   energy += kill.get_energy() * energy_bounty;
}
void Player::register_loss(const Destructable& loss) {
   team->register_loss(loss);
}
void Player::_tick_resources(double dt) {
   double alloy_gain  = dt * team->get_alloy_per_sec();
   double energy_gain = dt * team->get_energy_per_sec();
   alloy  = Math::clamp(alloy + alloy_gain, MIN_ALLOY, MAX_ALLOY);
   energy = Math::clamp(energy + energy_gain, MIN_ENERGY, MAX_ENERGY);
}