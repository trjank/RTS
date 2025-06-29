#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "register_types.h"
#include "unit.hpp"
#include "ship.hpp"
#include "projectile.hpp"
#include "mouse_commands.hpp"
#include "mouse_selection.hpp"
#include "battle.hpp"
#include "part_data.hpp"
#include "part.hpp"
#include "resizable_sprite_2d.hpp"
#include "ship_data.hpp"
#include "celestial.hpp"
#include "star.hpp"
#include "map.hpp"

void Unit::_bind_methods() {
	// ClassDB::bind_static_method("Unit", D_METHOD("set_warp_visual", "new_warp_visual"), &Unit::set_warp_visual);
	ClassDB::bind_method(D_METHOD("get_HP"), &Unit::get_hp);
	ClassDB::bind_method(D_METHOD("get_radar_signature"), &Unit::get_radar_signature);
	ClassDB::bind_method(D_METHOD("kill"), &Unit::kill);
	ClassDB::bind_method(D_METHOD("get_forward_direction"), &Unit::get_forward_direction);
	ClassDB::bind_method(D_METHOD("cloak"), &Unit::cloak);
	ClassDB::bind_method(D_METHOD("decloak"), &Unit::decloak);
	ClassDB::bind_method(D_METHOD("stop_moving"), &Unit::stop_moving);
	ClassDB::bind_method(D_METHOD("stop_targeting"), &Unit::stop_targeting);
	ClassDB::bind_method(D_METHOD("queue_move", "command"), &Unit::queue_move);
	ClassDB::bind_method(D_METHOD("set_target"), &Unit::set_target);
	ClassDB::bind_method(D_METHOD("hit", "damage"), &Unit::hit);
}
void Unit::RadarSignature::_bind_methods() {
	// Nothing to bind
}
void Unit::Command::_bind_methods() {
	// Nothing to bind
}
void Ship::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_stunlocked"), &Ship::is_stunlocked);
	ClassDB::bind_method(D_METHOD("fire"), &Ship::fire);
	ClassDB::bind_method(D_METHOD("get_owner"), &Ship::get_owner);
	ClassDB::bind_method(D_METHOD("get_cost"), &Ship::get_cost);
	ClassDB::bind_method(D_METHOD("get_energy"), &Ship::get_energy);
	ClassDB::bind_method(D_METHOD("get_shield"), &Ship::get_shield);
	ClassDB::bind_method(D_METHOD("get_data"), &Ship::get_data);
	ClassDB::bind_method(D_METHOD("set_owner", "new_owner"), &Ship::set_owner);
	ClassDB::bind_method(D_METHOD("set_data", "new_data"), &Ship::set_data);
	ClassDB::bind_method(D_METHOD("copy_data_from", "other_ship"), &Ship::copy_data_from);
	ClassDB::bind_method(D_METHOD("hit_shield", "damage"), &Ship::hit_shield);
	ClassDB::bind_method(D_METHOD("hit", "damage", "shield_penetration"), &Ship::hit);
	ADD_SIGNAL(MethodInfo("fire"));
}
void MouseCommands::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_action"), &MouseCommands::get_action);
	ClassDB::bind_method(D_METHOD("get_formation"), &MouseCommands::get_formation);
	ClassDB::bind_method(D_METHOD("bind_cursor_to_action", "image", "action"), &MouseCommands::bind_cursor_to_action);
	ClassDB::bind_method(D_METHOD("set_command_icon", "image"), &MouseCommands::set_command_icon);
	ClassDB::bind_method(D_METHOD("select_units", "selection"), &MouseCommands::select_units);
	BIND_ENUM_CONSTANT(LINE);
	BIND_ENUM_CONSTANT(V);
	BIND_ENUM_CONSTANT(SMOOTH);
	BIND_ENUM_CONSTANT(PRECISE);
	BIND_ENUM_CONSTANT(NONE);
	BIND_ENUM_CONSTANT(MOVE);
	BIND_ENUM_CONSTANT(TARGET);
}
void MouseSelection::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_enabled"), &MouseSelection::is_enabled);
	ClassDB::bind_method(D_METHOD("get_color"), &MouseSelection::get_color);
	ClassDB::bind_method(D_METHOD("get_selected"), &MouseSelection::get_selected);
	ClassDB::bind_method(D_METHOD("set_enabled", "enable"), &MouseSelection::set_enabled);
	ClassDB::bind_method(D_METHOD("set_color", "new_color"), &MouseSelection::set_color);
	ClassDB::bind_method(D_METHOD("set_visibility", "visibility"), &MouseSelection::set_visibility);
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "color"), "set_color", "get_color");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enabled"), "set_enabled", "is_enabled");
	ADD_SIGNAL(MethodInfo("selection_started"));
	ADD_SIGNAL(MethodInfo("selection_ended", PropertyInfo(Variant::ARRAY, "selected")));
}
void Battle::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_seed"), &Battle::get_seed);
	ClassDB::bind_method(D_METHOD("get_map"), &Battle::get_map);
	ClassDB::bind_method(D_METHOD("get_state"), &Battle::get_state);
	ClassDB::bind_method(D_METHOD("get_winner"), &Battle::get_winner);
	ClassDB::bind_method(D_METHOD("get_seconds_left"), &Battle::get_seconds_left);
	ClassDB::bind_method(D_METHOD("get_minutes_left"), &Battle::get_minutes_left);
	ClassDB::bind_method(D_METHOD("get_time_left_sec"), &Battle::get_time_left_sec);
	ClassDB::bind_method(D_METHOD("get_duration_sec"), &Battle::get_duration_sec);
	ClassDB::bind_method(D_METHOD("get_countdown_sec"), &Battle::get_countdown_sec);
	ClassDB::bind_method(D_METHOD("set_seed", "new_seed"), &Battle::set_seed);
	ClassDB::bind_method(D_METHOD("set_map", "new_map"), &Battle::set_map);
	ClassDB::bind_method(D_METHOD("set_duration_sec", "new_duration_sec"), &Battle::set_duration_sec);
	ClassDB::bind_method(D_METHOD("set_countdown_sec", "new_countdown_sec"), &Battle::set_countdown_sec);
	ClassDB::bind_method(D_METHOD("new_team", "name"), &Battle::new_team);
	ClassDB::bind_method(D_METHOD("new_player"), &Battle::new_player);
	ClassDB::bind_method(D_METHOD("start"), &Battle::start);
	ClassDB::bind_method(D_METHOD("start_countdown"), &Battle::start_countdown);
	ClassDB::bind_method(D_METHOD("stop"), &Battle::stop);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "seed"), "set_seed", "get_seed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "duration_sec"), "set_duration_sec", "get_duration_sec");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "countdown_sec"), "set_countdown_sec", "get_countdown_sec");
}
void Player::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_energy"), &Player::get_energy);
	ClassDB::bind_method(D_METHOD("get_alloy"), &Player::get_alloy);
	ClassDB::bind_method(D_METHOD("get_color"), &Player::get_color);
	ClassDB::bind_method(D_METHOD("get_name"), &Player::get_name);
	ClassDB::bind_method(D_METHOD("get_clan"), &Player::get_clan);
	ClassDB::bind_method(D_METHOD("get_team"), &Player::get_team);
	ClassDB::bind_method(D_METHOD("set_color", "new_color"), &Player::set_color);
	ClassDB::bind_method(D_METHOD("set_name", "new_name"), &Player::set_name);
	ClassDB::bind_method(D_METHOD("set_clan", "new_clan"), &Player::set_clan);
	ClassDB::bind_method(D_METHOD("set_team", "new_team"), &Player::set_team);
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "color"), "set_color", "get_color");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "name"), "set_name", "get_name");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "clan"), "set_clan", "get_clan");
}
void Team::_bind_methods() {

}
void Orbit::_bind_methods() {
	ClassDB::bind_static_method("Orbit", D_METHOD("get_time_scale"), &Orbit::get_time_scale);
	ClassDB::bind_static_method("Orbit", D_METHOD("set_time_scale", "new_time_scale"), &Orbit::set_time_scale);
	ClassDB::bind_method(D_METHOD("get_angular_velocity"), &Orbit::get_angular_velocity);
	ClassDB::bind_method(D_METHOD("get_distance"), &Orbit::get_distance);
	ClassDB::bind_method(D_METHOD("set_distance", "new_distance"), &Orbit::set_distance);
	ClassDB::bind_method(D_METHOD("orbit", "celestial"), &Orbit::orbit);
	ClassDB::bind_method(D_METHOD("add", "orbiter", "angle"), &Orbit::add);
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
	ClassDB::bind_method(D_METHOD("new_part", "code"), &PartManager::new_part);
	ClassDB::bind_method(D_METHOD("lookup_id", "atlas_id"), &PartManager::lookup_id);
	ClassDB::bind_method(D_METHOD("lookup_code", "code"), &PartManager::lookup_code);
	ClassDB::bind_method(D_METHOD("get_unique", "code"), &PartManager::get_unique_data);
	ClassDB::bind_method(D_METHOD("get_parts_folder_path"), &PartManager::get_parts_folder_path);
	ClassDB::bind_method(D_METHOD("set_unique", "code", "new_data"), &PartManager::set_unique_data);
	ClassDB::bind_method(D_METHOD("set_parts_folder_path", "new_parts_folder_path"), &PartManager::set_parts_folder_path);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "parts_folder_path"), "set_parts_folder_path", "get_parts_folder_path");
}
void TurretMountData::_bind_methods() {

}
void ResizableSprite2D::_bind_methods() {
	ClassDB::bind_method(D_METHOD("resize_scaled", "new_size"), &ResizableSprite2D::resize_scaled);
	ClassDB::bind_method(D_METHOD("resize_region", "new_size"), &ResizableSprite2D::resize_region);
}
void Part::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_data"), &Part::get_data);
	ClassDB::bind_method(D_METHOD("set_data", "new_data"), &Part::set_data);
}
void PartGrouping::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_dragging"), &PartGrouping::is_dragging);
	ClassDB::bind_method(D_METHOD("spawn_part", "part_data"), &PartGrouping::spawn_part);
	ClassDB::bind_method(D_METHOD("select_parts", "parts"), &PartGrouping::select_parts);
	ClassDB::bind_method(D_METHOD("clear_parts"), &PartGrouping::clear_parts);
	ClassDB::bind_method(D_METHOD("delete_parts"), &PartGrouping::delete_parts);
	ClassDB::bind_method(D_METHOD("get_mirroring"), &PartGrouping::get_mirroring);
	ClassDB::bind_method(D_METHOD("set_mirroring"), &PartGrouping::set_mirroring);
	ClassDB::bind_method(D_METHOD("snap_to_grid"), &PartGrouping::snap_to_grid);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "mirroring"), "set_mirroring", "get_mirroring");
	ADD_SIGNAL(MethodInfo("dragging_started"));
	ADD_SIGNAL(MethodInfo("dragging_ended"));
}
void ShipData::_bind_methods() {
	BIND_CONSTANT(NULL_PART_ID);
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
	ClassDB::bind_static_method("ShipData", D_METHOD("get_grid_padding"), &ShipData::get_grid_padding);
	ClassDB::bind_static_method("ShipData", D_METHOD("assemble", "grid_size", "parts"), &ShipData::assemble);
	ClassDB::bind_method(D_METHOD("count_parts"), &ShipData::count_parts);
	ClassDB::bind_method(D_METHOD("is_empty"), &ShipData::is_empty);
	ClassDB::bind_method(D_METHOD("is_connected"), &ShipData::is_connected);
	ClassDB::bind_method(D_METHOD("get_cost"), &ShipData::get_cost);
	ClassDB::bind_method(D_METHOD("get_size"), &ShipData::get_size);
	ClassDB::bind_method(D_METHOD("get_size_px"), &ShipData::get_size_px);
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
	ClassDB::bind_method(D_METHOD("save_ship_image", "ship", "path"), &ShipManager::save_ship_image);
	ClassDB::bind_method(D_METHOD("save_ship_csv", "ship", "path"), &ShipManager::save_ship_csv);
	ClassDB::bind_method(D_METHOD("load_ship_image", "path"), &ShipManager::load_ship_image);
	ClassDB::bind_method(D_METHOD("load_ship_csv", "path"), &ShipManager::load_ship_csv);
}
void Star::_bind_methods() {
	ClassDB::bind_static_method("Star", D_METHOD("set_star_shader", "shader"), &Star::set_star_shader);
	ClassDB::bind_static_method("Star", D_METHOD("set_black_hole_shader", "shader"), &Star::set_black_hole_shader);
	ClassDB::bind_method(D_METHOD("is_black_hole"), &Star::is_black_hole);
	ClassDB::bind_method(D_METHOD("set_mass", "new_mass"), &Star::set_mass);
	ClassDB::bind_method(D_METHOD("set_radius", "new_radius"), &Star::set_radius);
}
void Map::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_distance"), &Map::get_distance);
}
void MapLayer::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_preset"), &MapLayer::get_preset);
	ClassDB::bind_method(D_METHOD("get_num_orbits"), &MapLayer::get_num_orbits);
	ClassDB::bind_method(D_METHOD("get_num_sectors"), &MapLayer::get_num_sectors);
	ClassDB::bind_method(D_METHOD("get_orbit_spacing"), &MapLayer::get_orbit_spacing);
	ClassDB::bind_method(D_METHOD("get_start_distance"), &MapLayer::get_start_distance);
	ClassDB::bind_method(D_METHOD("set_preset", "new_preset"), &MapLayer::set_preset);
	ClassDB::bind_method(D_METHOD("set_num_orbits", "new_num_orbits"), &MapLayer::set_num_orbits);
	ClassDB::bind_method(D_METHOD("set_num_sectors", "new_num_sectors"), &MapLayer::set_num_sectors);
	ClassDB::bind_method(D_METHOD("set_orbit_spacing", "new_orbit_spacing"), &MapLayer::set_orbit_spacing);
	ClassDB::bind_method(D_METHOD("set_start_distance", "new_start_distance"), &MapLayer::set_start_distance);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "num_orbits"), "set_num_orbits", "get_num_orbits");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "num_sectors"), "set_num_sectors", "get_num_sectors");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "orbit_spacing"), "set_orbit_spacing", "get_orbit_spacing");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "start_distance"), "set_start_distance", "get_start_distance");
	BIND_CONSTANT(SECTOR_LIMIT);
	BIND_CONSTANT(ORBIT_LIMIT);
}
void System::_bind_methods() {
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
	ClassDB::bind_method(D_METHOD("load_names_from_file", "path"), &System::load_names_from_file);
	ClassDB::bind_method(D_METHOD("load_textures_from_folder", "path"), &System::load_textures_from_folder);
	ClassDB::bind_method(D_METHOD("new_layer", "layer"), &System::new_layer);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "alloy_density"), "set_alloy_density", "get_alloy_density");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "energy_density"), "set_energy_density", "get_energy_density");
	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "names"), "set_names", "get_names");
}
void StarSystem::_bind_methods() {
	// Nothing to bind
}

void initialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
	GDREGISTER_CLASS(Unit);
	GDREGISTER_CLASS(Unit::Command);
	GDREGISTER_CLASS(Unit::RadarSignature);
	GDREGISTER_CLASS(ResizableSprite2D);
	// GDREGISTER_CLASS(Projectile);
	GDREGISTER_CLASS(Ship);
	GDREGISTER_CLASS(MouseCommands);
	GDREGISTER_CLASS(MouseSelection);
	GDREGISTER_CLASS(Battle);
	GDREGISTER_CLASS(Player);
	GDREGISTER_CLASS(Team)
	GDREGISTER_CLASS(Celestial);
	GDREGISTER_CLASS(Orbit);
	GDREGISTER_CLASS(Star);
	GDREGISTER_CLASS(PartData);
	GDREGISTER_CLASS(PartManager);
	GDREGISTER_CLASS(TurretMountData);
	GDREGISTER_CLASS(Part);
	GDREGISTER_CLASS(PartGrouping);
	GDREGISTER_CLASS(ShipData);
	GDREGISTER_CLASS(ShipManager);
	GDREGISTER_CLASS(Map);
	GDREGISTER_CLASS(MapLayer);
	GDREGISTER_CLASS(System);
	GDREGISTER_CLASS(StarSystem);
	UtilityFunctions::print("Loaded Unit from unit.cpp");
	UtilityFunctions::print("Loaded Command from unit.cpp");
	UtilityFunctions::print("Loaded RadarSignature from unit.cpp");
	UtilityFunctions::print("Loaded Projectile from projectile.cpp");
	UtilityFunctions::print("Loaded Ship from ship.cpp");
	UtilityFunctions::print("Loaded MouseCommands from mouse_commands.cpp");
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