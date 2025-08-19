#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "register_types.h"
#include "unit.hpp"
#include "ship.hpp"
#include "projectile.hpp"
#include "unit_formation.hpp"
#include "mouse_selection.hpp"
#include "battle.hpp"
#include "part_data.hpp"
#include "part.hpp"
#include "resizable_sprite_2d.hpp"
#include "ship_data.hpp"
#include "celestial.hpp"
#include "star.hpp"
#include "map.hpp"
#include "fleet.hpp"
#include "unique_part.hpp"
#include "target.hpp"

void Unit::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_selected"), &Unit::is_selected);
	ClassDB::bind_method(D_METHOD("is_queue_empty"), &Unit::is_queue_empty);
	ClassDB::bind_method(D_METHOD("is_applying_thrust"), &Unit::is_applying_thrust);
	ClassDB::bind_method(D_METHOD("is_movement_locked"), &Unit::is_movement_locked);
	ClassDB::bind_method(D_METHOD("count_waypoints"), &Unit::count_waypoints);
	ClassDB::bind_method(D_METHOD("get_hp"), &Unit::get_hp);
	ClassDB::bind_method(D_METHOD("get_warp"), &Unit::get_warp);
	ClassDB::bind_method(D_METHOD("get_distance_to_target"), &Unit::get_distance_to_target);
	ClassDB::bind_method(D_METHOD("get_angle_to_target"), &Unit::get_angle_to_target);
	ClassDB::bind_method(D_METHOD("get_stop_distance"), &Unit::get_stop_distance);
	ClassDB::bind_method(D_METHOD("get_speed"), &Unit::get_speed);
	ClassDB::bind_method(D_METHOD("get_approx_time_to_move"), &Unit::get_approx_time_to_move);
	ClassDB::bind_method(D_METHOD("get_approx_time_to_turn"), &Unit::get_approx_time_to_turn);
	ClassDB::bind_method(D_METHOD("get_path_texture"), &Unit::get_path_texture);
	ClassDB::bind_method(D_METHOD("get_path_width"), &Unit::get_path_width);
	ClassDB::bind_method(D_METHOD("get_forward_direction"), &Unit::get_forward_direction);
	ClassDB::bind_method(D_METHOD("get_selected_color"), &Unit::get_selected_color);
	ClassDB::bind_method(D_METHOD("get_cloak_color"), &Unit::get_cloak_color);
	ClassDB::bind_method(D_METHOD("get_waypoint", "waypoint_num"), &Unit::get_waypoint);
	ClassDB::bind_method(D_METHOD("get_attack_position"), &Unit::get_attack_position);
	ClassDB::bind_method(D_METHOD("get_radar_signature"), &Unit::get_radar_signature);
	ClassDB::bind_method(D_METHOD("get_player_owner"), &Unit::get_player_owner);
	ClassDB::bind_method(D_METHOD("get_texture"), &Unit::get_texture);
	ClassDB::bind_method(D_METHOD("set_selected_color", "new_selected_color"), &Unit::set_selected_color);
	ClassDB::bind_method(D_METHOD("set_cloak_color", "new_cloak_color"), &Unit::set_cloak_color);
	ClassDB::bind_method(D_METHOD("set_selected", "select"), &Unit::set_selected);
	ClassDB::bind_method(D_METHOD("set_movement_lock", "lock_movement"), &Unit::set_movement_lock);
	ClassDB::bind_method(D_METHOD("set_player_owner", "new_owner"), &Unit::set_player_owner);
	ClassDB::bind_method(D_METHOD("set_texture", "new_texture"), &Unit::set_texture);
	ClassDB::bind_method(D_METHOD("set_image_offset", "new_offset"), &Unit::set_image_offset);
	ClassDB::bind_method(D_METHOD("set_path_texture", "new_path_texture"), &Unit::set_path_texture);
	ClassDB::bind_method(D_METHOD("set_path_width", "new_path_width"), &Unit::set_path_width);
	ClassDB::bind_method(D_METHOD("resize_image", "new_size"), &Unit::resize_image);
	ClassDB::bind_method(D_METHOD("cloak"), &Unit::cloak);
	ClassDB::bind_method(D_METHOD("decloak"), &Unit::decloak);
	ClassDB::bind_method(D_METHOD("kill"), &Unit::kill);
	ClassDB::bind_method(D_METHOD("clear_movement_queue"), &Unit::clear_movement_queue);
	ClassDB::bind_method(D_METHOD("queue_waypoint", "new_waypoint"), &Unit::queue_waypoint);
	ClassDB::bind_method(D_METHOD("target", "new_target"), &Unit::target);
	ClassDB::bind_method(D_METHOD("hit", "damage"), &Unit::hit);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "selected"), "set_selected", "is_selected");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "movement_lock"), "set_movement_lock", "is_movement_locked");
	ADD_SIGNAL(MethodInfo("warped", PropertyInfo(Variant::VECTOR2, "warp_start"), PropertyInfo(Variant::VECTOR2, "warp_end")));
}
void Unit::RadarSignature::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_future_position"), &Unit::RadarSignature::get_future_position);
	// Nothing to bind
}
void Ship::_bind_methods() {
	ClassDB::bind_static_method("Ship", D_METHOD("create_from", "ship_data"), &Ship::create_from);
	ClassDB::bind_method(D_METHOD("clone"), &Ship::clone);
	ClassDB::bind_method(D_METHOD("is_stunlocked"), &Ship::is_stunlocked);
	ClassDB::bind_method(D_METHOD("kill"), &Ship::kill);
	ClassDB::bind_method(D_METHOD("get_cost"), &Ship::get_cost);
	ClassDB::bind_method(D_METHOD("get_energy"), &Ship::get_energy);
	ClassDB::bind_method(D_METHOD("get_shield"), &Ship::get_shield);
	ClassDB::bind_method(D_METHOD("get_ratio_reserve_energy"), &Ship::get_ratio_reserve_energy);
	ClassDB::bind_method(D_METHOD("get_ratio_recharge_warp"), &Ship::get_ratio_recharge_warp);
	ClassDB::bind_method(D_METHOD("get_ratio_recharge_shield"), &Ship::get_ratio_recharge_shield);
	ClassDB::bind_method(D_METHOD("get_data"), &Ship::get_data);
	ClassDB::bind_method(D_METHOD("reset_stats"), &Ship::reset_stats);
	ClassDB::bind_method(D_METHOD("hit_shield", "damage"), &Ship::hit_shield);
	ClassDB::bind_method(D_METHOD("hit", "damage", "shield_penetration"), &Ship::hit);
	ADD_SIGNAL(MethodInfo("fire"));
}
void UnitFormation::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_curve_active"), &UnitFormation::is_curve_active);
	ClassDB::bind_method(D_METHOD("count_units"), &UnitFormation::count_units);
	ClassDB::bind_method(D_METHOD("count_targets"), &UnitFormation::count_targets);
	ClassDB::bind_method(D_METHOD("get_collision_mask"), &UnitFormation::get_collision_mask);
	ClassDB::bind_method(D_METHOD("get_formation"), &UnitFormation::get_formation);
	ClassDB::bind_method(D_METHOD("get_player"), &UnitFormation::get_player);
	ClassDB::bind_method(D_METHOD("get_unit", "unit_num"), &UnitFormation::get_unit);
	ClassDB::bind_method(D_METHOD("get_target", "target_num"), &UnitFormation::get_target);
	ClassDB::bind_method(D_METHOD("set_collision_mask", "new_collision_mask"), &UnitFormation::set_collision_mask);
	ClassDB::bind_method(D_METHOD("set_formation", "new_formation"), &UnitFormation::set_formation);
	ClassDB::bind_method(D_METHOD("set_player"), &UnitFormation::set_player);
	ClassDB::bind_method(D_METHOD("set_units_selected", "selected"), &UnitFormation::set_units_selected);
	ClassDB::bind_method(D_METHOD("select_closest_unit_to", "position", "search_radius"), &UnitFormation::select_closest_unit_to);
	ClassDB::bind_method(D_METHOD("select_region", "position", "shape"), &UnitFormation::select_region);
	ClassDB::bind_method(D_METHOD("select_units", "selection"), &UnitFormation::select_units);
	ClassDB::bind_method(D_METHOD("order_units_to_target"), &UnitFormation::order_units_to_target);
	ClassDB::bind_method(D_METHOD("order_units_to_stop"), &UnitFormation::order_units_to_stop);
	ClassDB::bind_method(D_METHOD("order_units_to_toggle_lock", "threshold"), &UnitFormation::order_units_to_toggle_lock);
	ClassDB::bind_method(D_METHOD("order_units_to_lock"), &UnitFormation::order_units_to_lock);
	ClassDB::bind_method(D_METHOD("order_units_to_move"), &UnitFormation::order_units_to_move);
	ClassDB::bind_method(D_METHOD("begin_curve_at", "path_start"), &UnitFormation::begin_curve_at);
	ClassDB::bind_method(D_METHOD("move_curve_to", "new_endpoint"), &UnitFormation::move_curve_to);
	ClassDB::bind_method(D_METHOD("end_curve"), &UnitFormation::end_curve);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "formation"), "set_formation", "get_formation");
	ADD_SIGNAL(MethodInfo("path_started"));
	ADD_SIGNAL(MethodInfo("path_ended"));
	BIND_ENUM_CONSTANT(LINE);
	BIND_ENUM_CONSTANT(V);
	BIND_ENUM_CONSTANT(SMOOTH);
	BIND_ENUM_CONSTANT(PRECISE);
}
void MouseSelection::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_enabled"), &MouseSelection::is_enabled);
	ClassDB::bind_method(D_METHOD("is_selecting"), &MouseSelection::is_enabled);
	ClassDB::bind_method(D_METHOD("get_color"), &MouseSelection::get_color);
	ClassDB::bind_method(D_METHOD("get_region"), &MouseSelection::get_region);
	ClassDB::bind_method(D_METHOD("get_selected"), &MouseSelection::get_selected);
	ClassDB::bind_method(D_METHOD("set_enabled", "enable"), &MouseSelection::set_enabled);
	ClassDB::bind_method(D_METHOD("set_color", "new_color"), &MouseSelection::set_color);
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "color"), "set_color", "get_color");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enabled"), "set_enabled", "is_enabled");
	ADD_SIGNAL(MethodInfo("selection_started"));
	ADD_SIGNAL(MethodInfo("selection_ended", PropertyInfo(Variant::ARRAY, "selected"), PropertyInfo(Variant::RECT2, "region")));
}
void Battle::_bind_methods() {
	BIND_ENUM_CONSTANT(STOPPED);
	BIND_ENUM_CONSTANT(STARTING);
	BIND_ENUM_CONSTANT(RUNNING);
	BIND_ENUM_CONSTANT(OKAY);
	BIND_ENUM_CONSTANT(TEAM_NOT_FOUND);
	BIND_ENUM_CONSTANT(PLAYER_NOT_FOUND);
	BIND_ENUM_CONSTANT(WRONG_STATE);
	BIND_ENUM_CONSTANT(UNBALANCED_TEAMS);
	BIND_CONSTANT(SPECTATORS_ID);
	BIND_CONSTANT(NUM_SPECTATOR_TEAMS);
	ClassDB::bind_method(D_METHOD("is_map_generated"), &Battle::is_map_generated);
	ClassDB::bind_method(D_METHOD("is_team_balanced", "team"), &Battle::is_team_balanced);
	ClassDB::bind_method(D_METHOD("has_player_id", "player_id"), &Battle::has_player_id);
	ClassDB::bind_method(D_METHOD("has_team_id", "team_id"), &Battle::has_team_id);
	ClassDB::bind_method(D_METHOD("has_player", "player"), &Battle::has_player);
	ClassDB::bind_method(D_METHOD("has_team", "team"), &Battle::has_team);
	ClassDB::bind_method(D_METHOD("count_unbalanced_teams"), &Battle::count_unbalanced_teams);
	ClassDB::bind_method(D_METHOD("count_capturables"), &Battle::count_capturables);
	ClassDB::bind_method(D_METHOD("get_num_capturables_to_win"), &Battle::get_num_capturables_to_win);
	ClassDB::bind_method(D_METHOD("count_players"), &Battle::count_players);
	ClassDB::bind_method(D_METHOD("count_teams"), &Battle::count_teams);
	ClassDB::bind_method(D_METHOD("count_teams_left"), &Battle::count_teams_left);
	ClassDB::bind_method(D_METHOD("get_seed"), &Battle::get_seed);
	ClassDB::bind_method(D_METHOD("get_map"), &Battle::get_map);
	ClassDB::bind_method(D_METHOD("get_winner"), &Battle::get_winner);
	ClassDB::bind_method(D_METHOD("get_spectators"), &Battle::get_spectators);
	ClassDB::bind_method(D_METHOD("get_team", "team_id"), &Battle::get_team);
	ClassDB::bind_method(D_METHOD("get_player", "player_id"), &Battle::get_player);
	ClassDB::bind_method(D_METHOD("get_starting_alloy"), &Battle::get_starting_alloy);
	ClassDB::bind_method(D_METHOD("get_starting_energy"), &Battle::get_starting_energy);
	ClassDB::bind_method(D_METHOD("get_starting_alloy_per_sec"), &Battle::get_starting_alloy_per_sec);
	ClassDB::bind_method(D_METHOD("get_starting_energy_per_sec"), &Battle::get_starting_energy_per_sec);
	ClassDB::bind_method(D_METHOD("set_num_capturables_to_win", "new_num_capturables_to_win"), &Battle::set_num_capturables_to_win);
	ClassDB::bind_method(D_METHOD("set_domination_victory_ratio", "new_domination_victory_ratio"), &Battle::set_domination_victory_ratio);
	ClassDB::bind_method(D_METHOD("set_starting_alloy", "new_starting_alloy"), &Battle::set_starting_alloy);
	ClassDB::bind_method(D_METHOD("set_starting_energy", "new_starting_energy"), &Battle::set_starting_energy);
	ClassDB::bind_method(D_METHOD("set_starting_alloy_per_sec", "new_starting_alloy_per_sec"), &Battle::set_starting_alloy_per_sec);
	ClassDB::bind_method(D_METHOD("set_starting_energy_per_sec", "new_starting_energy_per_sec"), &Battle::set_starting_energy_per_sec);
	ClassDB::bind_method(D_METHOD("set_map", "new_map"), &Battle::set_map);
	ClassDB::bind_method(D_METHOD("set_seed", "new_seed"), &Battle::set_seed);
	ClassDB::bind_method(D_METHOD("set_team", "player", "new_team"), &Battle::set_team);
	ClassDB::bind_method(D_METHOD("start_countdown"), &Battle::start_countdown);
	ClassDB::bind_method(D_METHOD("start"), &Battle::start);
	ClassDB::bind_method(D_METHOD("stop"), &Battle::stop);
	ClassDB::bind_method(D_METHOD("declare_winner"), &Battle::declare_winner);
	ClassDB::bind_method(D_METHOD("declare_winning_team", "team"), &Battle::declare_winning_team);
	ClassDB::bind_method(D_METHOD("autobalance", "team", "other_team"), &Battle::autobalance);
	ClassDB::bind_method(D_METHOD("reset_autobalance"), &Battle::reset_autobalance);
	ClassDB::bind_method(D_METHOD("connect_player", "player_name", "color"), &Battle::connect_player);
	ClassDB::bind_method(D_METHOD("disconnect_player", "player"), &Battle::disconnect_player);
	ClassDB::bind_method(D_METHOD("disconnect_all_players"), &Battle::disconnect_all_players);
	ClassDB::bind_method(D_METHOD("kill_player", "player"), &Battle::kill_player);
	ClassDB::bind_method(D_METHOD("kill_team", "team"), &Battle::kill_team);
	ClassDB::bind_method(D_METHOD("add_team", "team_name"), &Battle::add_team);
	ClassDB::bind_method(D_METHOD("reset_teams"), &Battle::reset_teams);
	ClassDB::bind_method(D_METHOD("spawn_ship", "player", "ship_data", "spawnpoint"), &Battle::spawn_ship);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "seed"), "set_seed", "get_seed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "starting_alloy"), "set_starting_alloy", "get_starting_alloy");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "starting_energy"), "set_starting_energy", "get_starting_energy");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "starting_alloy_per_sec"), "set_starting_alloy_per_sec", "get_starting_alloy_per_sec");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "starting_energy_per_sec"), "set_starting_energy_per_sec", "get_starting_energy_per_sec");
	ADD_SIGNAL(MethodInfo("spawned_ship", PropertyInfo(Variant::OBJECT, "ship")));
	ADD_SIGNAL(MethodInfo("started_countdown"));
	ADD_SIGNAL(MethodInfo("started"));
	ADD_SIGNAL(MethodInfo("stopped"));
}
void Player::_bind_methods() {
	BIND_CONSTANT(MAX_NAME_LENGTH);
	ClassDB::bind_method(D_METHOD("get_alloy"), &Player::get_alloy);
	ClassDB::bind_method(D_METHOD("get_energy"), &Player::get_energy);
	ClassDB::bind_method(D_METHOD("get_alloy_bounty"), &Player::get_alloy_bounty);
	ClassDB::bind_method(D_METHOD("get_energy_bounty"), &Player::get_energy_bounty);
	ClassDB::bind_method(D_METHOD("get_name"), &Player::get_name);
	ClassDB::bind_method(D_METHOD("get_color"), &Player::get_color);
	ClassDB::bind_method(D_METHOD("get_team"), &Player::get_team);
	ClassDB::bind_method(D_METHOD("set_alloy_bounty", "new_alloy_bounty"), &Player::set_alloy_bounty);
	ClassDB::bind_method(D_METHOD("set_energy_bounty", "new_energy_bounty"), &Player::set_energy_bounty);
	ClassDB::bind_method(D_METHOD("set_name", "new_name"), &Player::set_name);
	ClassDB::bind_method(D_METHOD("set_color", "new_team"), &Player::set_color);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "alloy_bounty"), "set_alloy_bounty", "get_alloy_bounty");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "energy_bounty"), "set_energy_bounty", "get_energy_bounty");
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "color"), "set_color", "get_color");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "name"), "set_name", "get_name");
	ADD_SIGNAL(MethodInfo("changed_name", PropertyInfo(Variant::STRING, "name")));
	ADD_SIGNAL(MethodInfo("changed_color", PropertyInfo(Variant::COLOR, "color")));
}
void Team::_bind_methods() {
	BIND_CONSTANT(MAX_NAME_LENGTH);
	ClassDB::bind_method(D_METHOD("is_sudden_death"), &Team::is_sudden_death);
	ClassDB::bind_method(D_METHOD("count_players"), &Team::count_players);
	ClassDB::bind_method(D_METHOD("count_players_alive"), &Team::count_players_alive);
	ClassDB::bind_method(D_METHOD("count_celestials_owned"), &Team::count_celestials_owned);
	ClassDB::bind_method(D_METHOD("count_kills"), &Team::count_kills);
	ClassDB::bind_method(D_METHOD("count_losses"), &Team::count_losses);
	ClassDB::bind_method(D_METHOD("get_value_killed"), &Team::get_value_killed);
	ClassDB::bind_method(D_METHOD("get_value_lost"), &Team::get_value_lost);
	ClassDB::bind_method(D_METHOD("get_net_value"), &Team::get_net_value);
	ClassDB::bind_method(D_METHOD("get_alloy_per_sec"), &Team::get_alloy_per_sec);
	ClassDB::bind_method(D_METHOD("get_energy_per_sec"), &Team::get_energy_per_sec);
	ClassDB::bind_method(D_METHOD("get_name"), &Team::get_name);
	ClassDB::bind_method(D_METHOD("get_color"), &Team::get_color);
	ClassDB::bind_method(D_METHOD("set_sudden_death"), &Team::set_sudden_death);
	ClassDB::bind_method(D_METHOD("set_name", "new_name"), &Team::set_name);
	ClassDB::bind_method(D_METHOD("set_color", "new_color"), &Team::set_color);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "sudden_death"), "set_sudden_death", "is_sudden_death");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "name"), "set_name", "get_name");
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "color"), "set_color", "get_color");
}
void Orbit::_bind_methods() {
	ClassDB::bind_static_method("Orbit", D_METHOD("get_time_scale"), &Orbit::get_time_scale);
	ClassDB::bind_static_method("Orbit", D_METHOD("set_time_scale", "new_time_scale"), &Orbit::set_time_scale);
	ClassDB::bind_method(D_METHOD("get_linear_velocity"), &Orbit::get_linear_velocity);
	ClassDB::bind_method(D_METHOD("get_angular_velocity"), &Orbit::get_angular_velocity);
	ClassDB::bind_method(D_METHOD("get_distance"), &Orbit::get_distance);
	ClassDB::bind_method(D_METHOD("set_distance", "new_distance"), &Orbit::set_distance);
	ClassDB::bind_method(D_METHOD("orbit", "celestial"), &Orbit::orbit);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "distance"), "set_distance", "get_distance");
}
void Celestial::_bind_methods() {
	ClassDB::bind_method(D_METHOD("can_capture"), &Celestial::can_capture);
	ClassDB::bind_method(D_METHOD("get_mass"), &Celestial::get_mass);
	ClassDB::bind_method(D_METHOD("get_radius"), &Celestial::get_radius);
	ClassDB::bind_method(D_METHOD("get_angular_velocity"), &Celestial::get_angular_velocity);
	ClassDB::bind_method(D_METHOD("get_alloy_per_sec"), &Celestial::get_alloy_per_sec);
	ClassDB::bind_method(D_METHOD("get_energy_per_sec"), &Celestial::get_energy_per_sec);
	ClassDB::bind_method(D_METHOD("get_texture"), &Celestial::get_texture);
	ClassDB::bind_method(D_METHOD("set_mass", "new_mass"), &Celestial::set_mass);
	ClassDB::bind_method(D_METHOD("set_radius", "new_radius"), &Celestial::set_radius);
	ClassDB::bind_method(D_METHOD("set_angular_velocity", "new_angular_velocity"), &Celestial::set_angular_velocity);
	ClassDB::bind_method(D_METHOD("set_angular_offset", "angle"), &Celestial::set_angular_offset);
	ClassDB::bind_method(D_METHOD("set_energy_density", "new_energy_density"), &Celestial::set_energy_density);
	ClassDB::bind_method(D_METHOD("set_alloy_density", "new_alloy_density"), &Celestial::set_alloy_density);
	ClassDB::bind_method(D_METHOD("set_texture", "new_texture"), &Celestial::set_texture);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "mass"), "set_mass", "get_mass");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "radius"), "set_radius", "get_radius");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "angular_velocity"), "set_angular_velocity", "get_angular_velocity");
}
void PartData::_bind_methods() {
	BIND_CONSTANT(MIN_WIDTH);
	BIND_CONSTANT(MIN_HEIGHT);
	BIND_CONSTANT(PX_PER_GRID_SQUARE);
	BIND_CONSTANT(MAX_NAME_LENGTH);
	BIND_CONSTANT(MAX_DESC_LENGTH);
	ClassDB::bind_method(D_METHOD("get_cost"), &PartData::get_cost);
	ClassDB::bind_method(D_METHOD("get_hp"), &PartData::get_hp);
	ClassDB::bind_method(D_METHOD("get_mass"), &PartData::get_mass);
	ClassDB::bind_method(D_METHOD("get_shield"), &PartData::get_shield);
	ClassDB::bind_method(D_METHOD("get_shield_per_sec"), &PartData::get_shield_per_sec);
	ClassDB::bind_method(D_METHOD("get_warp"), &PartData::get_warp);
	ClassDB::bind_method(D_METHOD("get_warp_per_sec"), &PartData::get_warp_per_sec);
	ClassDB::bind_method(D_METHOD("get_torque"), &PartData::get_turning_momentum);
	ClassDB::bind_method(D_METHOD("get_thrust"), &PartData::get_thrust);
	ClassDB::bind_method(D_METHOD("get_size"), &PartData::get_size);
	ClassDB::bind_method(D_METHOD("get_size_px"), &PartData::get_size_px);
	ClassDB::bind_method(D_METHOD("get_code"), &PartData::get_code);
	ClassDB::bind_method(D_METHOD("get_name"), &PartData::get_name);
	ClassDB::bind_method(D_METHOD("get_tab"), &PartData::get_tab);
	ClassDB::bind_method(D_METHOD("get_image"), &PartData::get_image);
	ClassDB::bind_method(D_METHOD("get_texture"), &PartData::get_texture);
	ClassDB::bind_method(D_METHOD("get_desc"), &PartData::get_desc);
	ClassDB::bind_method(D_METHOD("set_cost", "new_cost"), &PartData::set_cost);
	ClassDB::bind_method(D_METHOD("set_mass", "new_mass"), &PartData::set_mass);
	ClassDB::bind_method(D_METHOD("set_hp", "new_hp"), &PartData::set_hp);
	ClassDB::bind_method(D_METHOD("set_size", "new_size"), &PartData::set_size);
	ClassDB::bind_method(D_METHOD("set_name", "new_name"), &PartData::set_name);
	ClassDB::bind_method(D_METHOD("set_tab", "new_tab"), &PartData::set_tab);
	ClassDB::bind_method(D_METHOD("set_image_path", "local_path"), &PartData::set_image_path);
	ClassDB::bind_method(D_METHOD("set_desc", "new_desc"), &PartData::set_desc);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "cost"), "set_cost", "get_cost");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "hp"), "set_hp", "get_hp");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "mass"), "set_mass", "get_mass");
	ADD_PROPERTY(PropertyInfo(Variant::VECTOR2I, "size"), "set_size", "get_size");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "desc"), "set_desc", "get_desc");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "name"), "set_name", "get_name");
}
void PartManager::_bind_methods() {
	BIND_CONSTANT(CODE_LENGTH)
	ClassDB::bind_method(D_METHOD("count_parts"), &PartManager::count_parts);
	ClassDB::bind_method(D_METHOD("load_csv", "path"), &PartManager::load_csv);
	ClassDB::bind_method(D_METHOD("save_csv", "path"), &PartManager::save_csv);
	ClassDB::bind_method(D_METHOD("load_json", "path"), &PartManager::load_unique_data);
	ClassDB::bind_method(D_METHOD("save_json", "path"), &PartManager::save_unique_data);
	ClassDB::bind_method(D_METHOD("new_atlas"), &PartManager::new_atlas);
	ClassDB::bind_method(D_METHOD("remove_part", "part"), &PartManager::remove_part);
	ClassDB::bind_method(D_METHOD("new_part", "code", "subtype"), &PartManager::new_part);
	ClassDB::bind_method(D_METHOD("lookup_id", "atlas_id"), &PartManager::lookup_id);
	ClassDB::bind_method(D_METHOD("lookup_code", "code"), &PartManager::lookup_code);
	ClassDB::bind_method(D_METHOD("get_unique", "code"), &PartManager::get_unique_data);
	ClassDB::bind_method(D_METHOD("get_parts_folder_path"), &PartManager::get_parts_folder_path);
	ClassDB::bind_method(D_METHOD("set_unique", "code", "new_data"), &PartManager::set_unique_data);
	ClassDB::bind_method(D_METHOD("set_parts_folder_path", "new_parts_folder_path"), &PartManager::set_parts_folder_path);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "parts_folder_path"), "set_parts_folder_path", "get_parts_folder_path");
}
void WeaponData::_bind_methods() {

}
void WeaponModifierData::_bind_methods() {

}
void WeaponMountData::_bind_methods() {

}
void Weapon::_bind_methods() {

}
void ResizableSprite2D::_bind_methods() {
	ClassDB::bind_method(D_METHOD("resize", "new_size"), &ResizableSprite2D::resize);
}
void Part::_bind_methods() {
	ClassDB::bind_static_method("Part", D_METHOD("create_from", "part_data"), &Part::create_from);
	ClassDB::bind_method(D_METHOD("get_data"), &Part::get_data);
}
void PartGrouping::_bind_methods() {
	BIND_CONSTANT(CLOCKWISE);
	BIND_CONSTANT(COUNTER_CLOCKWISE);
	ClassDB::bind_method(D_METHOD("clone"), &PartGrouping::clone);
	ClassDB::bind_method(D_METHOD("is_dragging"), &PartGrouping::is_dragging);
	ClassDB::bind_method(D_METHOD("flip_parts"), &PartGrouping::flip_parts);
	ClassDB::bind_method(D_METHOD("rotate_parts", "quarter_turns", "duration"), &PartGrouping::rotate_parts);
	ClassDB::bind_method(D_METHOD("spawn_part", "part_data"), &PartGrouping::spawn_part);
	ClassDB::bind_method(D_METHOD("select_parts", "parts"), &PartGrouping::select_parts);
	ClassDB::bind_method(D_METHOD("clear_parts"), &PartGrouping::clear_parts);
	ClassDB::bind_method(D_METHOD("delete_parts"), &PartGrouping::delete_parts);
	ClassDB::bind_method(D_METHOD("snap_to_grid"), &PartGrouping::snap_to_grid);
	ADD_SIGNAL(MethodInfo("parts_deleted"));
	ADD_SIGNAL(MethodInfo("parts_rotated", PropertyInfo(Variant::INT, "quarter_turns"), PropertyInfo(Variant::FLOAT, "duration")));
	ADD_SIGNAL(MethodInfo("parts_flipped"));
	ADD_SIGNAL(MethodInfo("dragging_started"));
	ADD_SIGNAL(MethodInfo("dragging_ended", PropertyInfo(Variant::ARRAY, "selected"), PropertyInfo(Variant::RECT2, "region")));
}
void ShipData::_bind_methods() {
	BIND_CONSTANT(GRID_PADDING);
	BIND_CONSTANT(NULL_PART_ID);
	BIND_CONSTANT(NUM_NULL_PARTS);
	BIND_CONSTANT(MAX_NAME_LENGTH);
	BIND_ENUM_CONSTANT(EDGE_BOTTOM);
	BIND_ENUM_CONSTANT(EDGE_TOP);
	BIND_ENUM_CONSTANT(EDGE_LEFT);
	BIND_ENUM_CONSTANT(EDGE_RIGHT);
	BIND_ENUM_CONSTANT(FULL_PERIMETER);
	BIND_ENUM_CONSTANT(ROT_0_DEG);
	BIND_ENUM_CONSTANT(ROT_90_DEG);
	BIND_ENUM_CONSTANT(ROT_180_DEG);
	BIND_ENUM_CONSTANT(ROT_270_DEG);
	BIND_ENUM_CONSTANT(FLIPPED_ROT_0_DEG);
	BIND_ENUM_CONSTANT(FLIPPED_ROT_90_DEG);
	BIND_ENUM_CONSTANT(FLIPPED_ROT_180_DEG);
	BIND_ENUM_CONSTANT(FLIPPED_ROT_270_DEG);
	BIND_ENUM_CONSTANT(OKAY);
	BIND_ENUM_CONSTANT(OVERLAP);
	BIND_ENUM_CONSTANT(OUT_OF_BOUNDS);
	BIND_ENUM_CONSTANT(IS_NULL);
	ClassDB::bind_static_method("ShipData", D_METHOD("create", "width", "height"), &ShipData::create);
	ClassDB::bind_static_method("ShipData", D_METHOD("encode_rotation", "radians", "flipped"), &ShipData::encode_rotation);
	ClassDB::bind_method(D_METHOD("count_parts"), &ShipData::count_parts);
	ClassDB::bind_method(D_METHOD("is_empty"), &ShipData::is_empty);
	ClassDB::bind_method(D_METHOD("is_connected"), &ShipData::is_connected);
	ClassDB::bind_method(D_METHOD("get_cost"), &ShipData::get_cost);
	ClassDB::bind_method(D_METHOD("get_grid_region"), &ShipData::get_grid_region);
	ClassDB::bind_method(D_METHOD("get_ship_region"), &ShipData::get_ship_region);
	ClassDB::bind_method(D_METHOD("get_max_warp"), &ShipData::get_max_warp);
	ClassDB::bind_method(D_METHOD("get_max_hp"), &ShipData::get_max_hp);
	ClassDB::bind_method(D_METHOD("get_max_shield"), &ShipData::get_max_shield);
	ClassDB::bind_method(D_METHOD("get_max_energy"), &ShipData::get_max_energy);
	ClassDB::bind_method(D_METHOD("get_warp_per_sec"), &ShipData::get_warp_per_sec);
	ClassDB::bind_method(D_METHOD("get_shield_per_sec"), &ShipData::get_shield_per_sec);
	ClassDB::bind_method(D_METHOD("get_energy_per_sec"), &ShipData::get_energy_per_sec);
	ClassDB::bind_method(D_METHOD("get_thrust"), &ShipData::get_thrust);
	ClassDB::bind_method(D_METHOD("get_turnrate"), &ShipData::get_turnrate);
	ClassDB::bind_method(D_METHOD("get_center_of_mass"), &ShipData::get_center_of_mass);
	ClassDB::bind_method(D_METHOD("get_image"), &ShipData::get_image);
	ClassDB::bind_method(D_METHOD("get_unique_parts"), &ShipData::get_unique_parts);
	ClassDB::bind_method(D_METHOD("get_part_data", "part_id"), &ShipData::get_part_data);
	ClassDB::bind_method(D_METHOD("get_part_center", "part_id"), &ShipData::get_part_center);
	ClassDB::bind_method(D_METHOD("get_part_region", "part_id"), &ShipData::get_part_region);
	ClassDB::bind_method(D_METHOD("set_image", "new_image"), &ShipData::set_image);
	ClassDB::bind_method(D_METHOD("has_part", "part_id"), &ShipData::has_part);
	ClassDB::bind_method(D_METHOD("add_part", "part", "center", "rotation_state"), &ShipData::add_part);
	ClassDB::bind_method(D_METHOD("add_part_node", "part"), &ShipData::add_part_node);
	ClassDB::bind_method(D_METHOD("collision_check", "point"), &ShipData::add_part_node);
	ClassDB::bind_method(D_METHOD("find_neighbors", "part_id", "boundary_flags"), &ShipData::find_neighbors);
}
void ShipManager::_bind_methods() {
   BIND_CONSTANT(NULL_PART_ATLAS_ID);
	ClassDB::bind_method(D_METHOD("set_part_manager", "new_parts_manager"), &ShipManager::set_part_manager);

	ClassDB::bind_method(D_METHOD("save_ship_image", "ship", "path"), &ShipManager::save_ship_image);
	ClassDB::bind_method(D_METHOD("save_ship_csv", "ship", "path"), &ShipManager::save_ship_csv);
	ClassDB::bind_method(D_METHOD("load_ship_image", "path"), &ShipManager::load_ship_image);
	ClassDB::bind_method(D_METHOD("load_ship_csv", "size", "path"), &ShipManager::load_ship_csv);
	ClassDB::bind_method(D_METHOD("save_ship_string"), &ShipManager::save_ship_string);
}
void Star::_bind_methods() {
	ClassDB::bind_static_method("Star", D_METHOD("set_star_shader", "shader"), &Star::set_star_shader);
	ClassDB::bind_static_method("Star", D_METHOD("set_black_hole_shader", "shader"), &Star::set_black_hole_shader);
	ClassDB::bind_method(D_METHOD("is_black_hole"), &Star::is_black_hole);
	ClassDB::bind_method(D_METHOD("set_mass", "new_mass"), &Star::set_mass);
	ClassDB::bind_method(D_METHOD("set_radius", "new_radius"), &Star::set_radius);
}
void Map::_bind_methods() {
	// Nothing to bind
}
void MapLayer::_bind_methods() {
	BIND_CONSTANT(SECTOR_LIMIT);
	BIND_CONSTANT(ORBIT_LIMIT);
	ClassDB::bind_method(D_METHOD("get_submap"), &MapLayer::get_submap);
	ClassDB::bind_method(D_METHOD("count_orbits"), &MapLayer::count_orbits);
	ClassDB::bind_method(D_METHOD("count_sectors"), &MapLayer::count_sectors);
	ClassDB::bind_method(D_METHOD("get_orbit_spacing"), &MapLayer::get_orbit_spacing);
	ClassDB::bind_method(D_METHOD("get_start_distance"), &MapLayer::get_start_distance);
	ClassDB::bind_method(D_METHOD("set_submap", "new_submap"), &MapLayer::set_submap);
	ClassDB::bind_method(D_METHOD("set_num_orbits", "new_num_orbits"), &MapLayer::set_num_orbits);
	ClassDB::bind_method(D_METHOD("set_num_sectors", "new_num_sectors"), &MapLayer::set_num_sectors);
	ClassDB::bind_method(D_METHOD("set_orbit_spacing", "new_orbit_spacing"), &MapLayer::set_orbit_spacing);
	ClassDB::bind_method(D_METHOD("set_start_distance", "new_start_distance"), &MapLayer::set_start_distance);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "num_orbits"), "set_num_orbits", "count_orbits");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "num_sectors"), "set_num_sectors", "count_sectors");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "orbit_spacing"), "set_orbit_spacing", "get_orbit_spacing");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "start_distance"), "set_start_distance", "get_start_distance");
}
void System::_bind_methods() {
	ClassDB::bind_static_method("System", D_METHOD("set_default_name", "new_default_name"), &System::set_default_name);
	ClassDB::bind_static_method("System", D_METHOD("set_default_texture", "new_default_texture"), &System::set_default_texture);
	ClassDB::bind_method(D_METHOD("get_energy_density"), &System::get_energy_density);
	ClassDB::bind_method(D_METHOD("get_alloy_density"), &System::get_alloy_density);
	ClassDB::bind_method(D_METHOD("get_names"), &System::get_names);
	ClassDB::bind_method(D_METHOD("get_textures"), &System::get_textures);
	ClassDB::bind_method(D_METHOD("get_layer"), &System::get_layer);
	ClassDB::bind_method(D_METHOD("set_mass_range", "new_min_mass", "new_max_mass"), &System::set_mass_range);
	ClassDB::bind_method(D_METHOD("set_radius_range", "new_min_radius", "new_max_radius"), &System::set_radius_range);
	ClassDB::bind_method(D_METHOD("set_energy_density", "new_energy_density"), &System::set_energy_density);
	ClassDB::bind_method(D_METHOD("set_alloy_density", "new_alloy_density"), &System::set_alloy_density);
	ClassDB::bind_method(D_METHOD("set_names", "new_names"), &System::set_names);
	ClassDB::bind_method(D_METHOD("set_textures", "new_textures"), &System::set_textures);
	ClassDB::bind_method(D_METHOD("new_layer", "layer"), &System::new_layer);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "alloy_density"), "set_alloy_density", "get_alloy_density");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "energy_density"), "set_energy_density", "get_energy_density");
	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "names"), "set_names", "get_names");
	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "textures"), "set_textures", "get_textures");
}
void StarSystem::_bind_methods() {
	// Nothing to bind
}
void Fleet::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_num_slots", "type"), &Fleet::get_num_slots);
    ClassDB::bind_method(D_METHOD("get_slot", "type", "slot"), &Fleet::get_slot);
    ClassDB::bind_method(D_METHOD("get_name"), &Fleet::get_name);
    ClassDB::bind_method(D_METHOD("set_num_slots", "type", "new_num_slots"), &Fleet::set_num_slots);
    ClassDB::bind_method(D_METHOD("set_slot", "type", "slot", "new_ship"), &Fleet::set_slot);
    ClassDB::bind_method(D_METHOD("set_name", "new_name"), &Fleet::set_name);
	ClassDB::bind_method(D_METHOD("resize"),&Fleet::resize);
    BIND_ENUM_CONSTANT(CAPITAL_SHIP);
    BIND_ENUM_CONSTANT(SHIP);
    BIND_ENUM_CONSTANT(TURRET);
    BIND_ENUM_CONSTANT(NUM_SHIP_TYPES);
    
    BIND_CONSTANT(MIN_NAME_LENGTH);
}

void FleetManager::_bind_methods() {
    ClassDB::bind_method(D_METHOD("fleet_exists", "fleet_name"), &FleetManager::fleet_exists);
    ClassDB::bind_method(D_METHOD("set_fleet_folder", "user_path"), &FleetManager::set_fleet_folder, DEFVAL("user://fleets"));
    ClassDB::bind_method(D_METHOD("save_fleet", "fleet"), &FleetManager::save_fleet);
    ClassDB::bind_method(D_METHOD("save_fleet_type", "fleet", "type"), &FleetManager::save_fleet_type);
    ClassDB::bind_method(D_METHOD("save_fleet_slot", "fleet", "type", "slot"), &FleetManager::save_fleet_slot);
    ClassDB::bind_method(D_METHOD("load_fleet", "name"), &FleetManager::load_fleet);
    ClassDB::bind_method(D_METHOD("load_fleet_type", "fleet", "type"), &FleetManager::load_fleet_type);
    ClassDB::bind_method(D_METHOD("load_fleet_slot", "fleet", "type", "slot"), &FleetManager::load_fleet_slot);
    ClassDB::bind_method(D_METHOD("delete_fleet", "fleet"), &FleetManager::delete_fleet);
    ClassDB::bind_method(D_METHOD("delete_fleet_type", "fleet", "type"), &FleetManager::delete_fleet_type);
    ClassDB::bind_method(D_METHOD("delete_fleet_slot", "fleet", "type", "slot"), &FleetManager::delete_fleet_slot);
}
void ProjectileData::_bind_methods() {

}
void Target::_bind_methods() {

}
void StaticTarget::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_speed"), &StaticTarget::get_speed);
	ClassDB::bind_method(D_METHOD("get_position"), &StaticTarget::get_position);
	ClassDB::bind_method(D_METHOD("get_velocity"), &StaticTarget::get_velocity);
	ClassDB::bind_method(D_METHOD("get_future_position"), &StaticTarget::get_future_position);
	ClassDB::bind_method(D_METHOD("set_position", "new_position"), &StaticTarget::set_position);
}
void Detection::_bind_methods() {

}

void initialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;

	GDREGISTER_CLASS(Unit);
	GDREGISTER_ABSTRACT_CLASS(Target);
	GDREGISTER_CLASS(StaticTarget);
	GDREGISTER_CLASS(Detection);
	GDREGISTER_CLASS(Unit::RadarSignature);
	GDREGISTER_CLASS(ResizableSprite2D);
	
	// GDREGISTER_CLASS(Projectile);
	GDREGISTER_CLASS(Ship);
	GDREGISTER_CLASS(UnitFormation);
	GDREGISTER_CLASS(MouseSelection);
	GDREGISTER_CLASS(Battle);
	GDREGISTER_CLASS(Player);
	GDREGISTER_CLASS(Team)
	GDREGISTER_CLASS(Celestial);
	GDREGISTER_CLASS(Orbit);
	GDREGISTER_CLASS(Star);
	GDREGISTER_CLASS(PartData);
	GDREGISTER_CLASS(PartManager);
	GDREGISTER_CLASS(Part);
	GDREGISTER_CLASS(PartGrouping);
	GDREGISTER_CLASS(ShipData);
	GDREGISTER_CLASS(ShipManager);
	GDREGISTER_CLASS(Map);
	GDREGISTER_CLASS(MapLayer);
	GDREGISTER_CLASS(System);
	GDREGISTER_CLASS(StarSystem);
	GDREGISTER_CLASS(Fleet);
	GDREGISTER_CLASS(FleetManager);

	GDREGISTER_CLASS(Weapon);
	GDREGISTER_CLASS(ProjectileData);
	GDREGISTER_CLASS(WeaponData);
	GDREGISTER_CLASS(WeaponModifierData);
	GDREGISTER_CLASS(WeaponMountData);

	UtilityFunctions::print("Loaded Unit from unit.cpp");
	UtilityFunctions::print("Loaded Command from unit.cpp");
	UtilityFunctions::print("Loaded RadarSignature from unit.cpp");
	UtilityFunctions::print("Loaded Projectile from projectile.cpp");
	UtilityFunctions::print("Loaded Ship from ship.cpp");
	UtilityFunctions::print("Loaded UnitFormation from mouse_commands.cpp");
	UtilityFunctions::print("Loaded MouseSelection from mouse_selection.cpp");
	UtilityFunctions::print("Loaded Battle from battle.cpp");
	UtilityFunctions::print("Loaded Celestial from celestial.cpp");
}
void uninitialize_module(ModuleInitializationLevel p_level) {}

extern "C" {

GDExtensionBool GDE_EXPORT example_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
	init_obj.register_initializer(initialize_module);
	init_obj.register_terminator(uninitialize_module);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
	return init_obj.init();
}

}