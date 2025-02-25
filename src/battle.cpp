#include "battle.hpp"

#define INVALID_NAME_MSG "(Team) Name too short"

Ref<Battle::Team> Battle::new_team(String name) {
   Ref<Team> team;
   team.instantiate();
   team->set_name(name);
   teams.append(team);
   return team;
}

String Battle::Team::get_name() {
   return name;
}
void Battle::Team::set_name(String new_name) {
   ERR_FAIL_COND_MSG(new_name.length() < MIN_NAME_LENGTH, INVALID_NAME_MSG);
   name = new_name;
}
int Battle::Team::get_n_captured() {
   return n_terrestrial_planets + n_jovian_planets + n_moons;
}
int Battle::Team::get_ships_killed() {
   return ships_killed;
}
float Battle::Team::get_net_value() {
   return value_killed - value_lost;
}