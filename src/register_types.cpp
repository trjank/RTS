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
#include "celestial.hpp"
#include "battle.hpp"
#include "part_data.hpp"
#include "part.hpp"
#include "resizable_sprite_2d.hpp"
#include "ship_data.hpp"

#define bind_method ClassDB::bind_method
#define bind_enum ClassDB::bind_integer_constant
#define println UtilityFunctions::print

void Unit::_bind_methods() {
	ClassDB::bind_static_method("Unit", D_METHOD("set_warp_visual", "new_warp_visual"), &Unit::set_warp_visual);
	bind_method(D_METHOD("get_HP"), &Unit::get_HP);
	bind_method(D_METHOD("get_radar_signature"), &Unit::get_radar_signature);
	bind_method(D_METHOD("kill"), &Unit::kill);
	bind_method(D_METHOD("get_forward_direction"), &Unit::get_forward_direction);
	bind_method(D_METHOD("cloak"), &Unit::cloak);
	bind_method(D_METHOD("decloak"), &Unit::decloak);
	bind_method(D_METHOD("stop_moving"), &Unit::stop_moving);
	bind_method(D_METHOD("stop_targeting"), &Unit::stop_targeting);
	bind_method(D_METHOD("queue_move", "command"), &Unit::queue_move);
	bind_method(D_METHOD("set_target"), &Unit::set_target);
	bind_method(D_METHOD("hit", "damage"), &Unit::hit);
}
void Unit::RadarSignature::_bind_methods() {}
void Unit::Command::_bind_methods() {}
void Ship::_bind_methods() {
	bind_method(D_METHOD("get_shield"), &Ship::get_shield);
	bind_method(D_METHOD("get_energy"), &Ship::get_energy);
	bind_method(D_METHOD("hit", "damage", "shield_penetration"), &Ship::hit);
}
void MouseCommands::_bind_methods() {
	bind_method(D_METHOD("get_action"), &MouseCommands::get_action);
	bind_method(D_METHOD("get_formation"), &MouseCommands::get_formation);
	bind_method(D_METHOD("bind_cursor_to_action", "image", "action"), &MouseCommands::bind_cursor_to_action);
	bind_method(D_METHOD("set_command_icon", "image"), &MouseCommands::set_command_icon);
	bind_method(D_METHOD("select_units", "selection"), &MouseCommands::select_units);
	bind_enum("MouseCommands", "Formation", "LINE", LINE);
	bind_enum("MouseCommands", "Formation", "V", V);
	bind_enum("MouseCommands", "Formation", "SMOOTH", SMOOTH);
	bind_enum("MouseCommands", "Formation", "PRECISE", PRECISE);
	bind_enum("MouseCommands", "Action", "NONE", NONE);
	bind_enum("MouseCommands", "Action", "MOVE", MOVE);
	bind_enum("MouseCommands", "Action", "TARGET", TARGET);
}
void MouseSelection::_bind_methods() {
	bind_method(D_METHOD("is_enabled"), &MouseSelection::is_enabled);
	bind_method(D_METHOD("get_color"), &MouseSelection::get_color);
	bind_method(D_METHOD("get_selected"), &MouseSelection::get_selected);
	bind_method(D_METHOD("set_enabled", "enable"), &MouseSelection::set_enabled);
	bind_method(D_METHOD("set_color", "new_color"), &MouseSelection::set_color);
	bind_method(D_METHOD("set_visibility", "visibility"), &MouseSelection::set_visibility);
	ADD_PROPERTY(PropertyInfo(Variant::COLOR, "color"), "set_color", "get_color");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enabled"), "set_enabled", "is_enabled");
	ADD_SIGNAL(MethodInfo("selection_started"));
	ADD_SIGNAL(MethodInfo("selection_ended", PropertyInfo(Variant::ARRAY, "selected")));
}
void Battle::_bind_methods() {
	bind_method(D_METHOD("get_state"), &Battle::get_state);
	bind_method(D_METHOD("get_winner"), &Battle::get_winner);
	bind_method(D_METHOD("new_team", "name"), &Battle::new_team);
	bind_method(D_METHOD("get_seconds_left"), &Battle::get_seconds_left);
	bind_method(D_METHOD("get_minutes_left"), &Battle::get_minutes_left);
	bind_method(D_METHOD("get_time_left_sec"), &Battle::get_time_left_sec);
	bind_method(D_METHOD("get_duration_sec"), &Battle::get_duration_sec);
	bind_method(D_METHOD("get_countdown_sec"), &Battle::get_countdown_sec);
	bind_method(D_METHOD("set_duration_sec", "new_duration_sec"), &Battle::set_duration_sec);
	bind_method(D_METHOD("set_countdown_sec", "new_countdown_sec"), &Battle::set_countdown_sec);
	bind_method(D_METHOD("start"), &Battle::start);
	bind_method(D_METHOD("start_countdown"), &Battle::start_countdown);
	bind_method(D_METHOD("stop"), &Battle::stop);
}
void Orbit::_bind_methods() {
	ClassDB::bind_static_method("Celestial", D_METHOD("get_time_scale"), &Orbit::get_time_scale);
	ClassDB::bind_static_method("Celestial", D_METHOD("get_gravity_scale"), &Orbit::get_gravity_scale);
	ClassDB::bind_static_method("Celestial", D_METHOD("set_time_scale", "new_time_scale"), &Orbit::set_time_scale);
	ClassDB::bind_static_method("Celestial", D_METHOD("set_gravity_scale", "new_gravity_scale"), &Orbit::set_gravity_scale);
	bind_method(D_METHOD("get_angular_velocity"), &Orbit::get_angular_velocity);
	bind_method(D_METHOD("get_distance"), &Orbit::get_distance);
	bind_method(D_METHOD("set_distance", "new_distance"), &Orbit::set_distance);
}
void Celestial::_bind_methods() {
	bind_method(D_METHOD("can_capture"), &Celestial::can_capture);
	bind_method(D_METHOD("get_mass"), &Celestial::get_mass);
	bind_method(D_METHOD("get_radius"), &Celestial::get_radius);
	bind_method(D_METHOD("get_angular_velocity"), &Celestial::get_angular_velocity);
	bind_method(D_METHOD("get_alloy_per_sec"), &Celestial::get_alloy_per_sec);
	bind_method(D_METHOD("get_energy_per_sec"), &Celestial::get_energy_per_sec);
	bind_method(D_METHOD("set_radius", "new_radius"), &Celestial::set_radius);
	bind_method(D_METHOD("set_angular_velocity", "new_angular_velocity"), &Celestial::set_angular_velocity);
}
void PartData::_bind_methods() {
	BIND_CONSTANT(MIN_WIDTH);
	BIND_CONSTANT(MIN_HEIGHT);
	BIND_CONSTANT(PX_PER_GRID_SQUARE);
	BIND_CONSTANT(MAX_NAME_LENGTH);
	BIND_CONSTANT(MAX_DESC_LENGTH);
	BIND_CONSTANT(NUM_CSV_COLUMNS);
	bind_method(D_METHOD("get_cost"), &PartData::get_cost);
	bind_method(D_METHOD("get_hp"), &PartData::get_hp);
	bind_method(D_METHOD("get_mass"), &PartData::get_mass);
	bind_method(D_METHOD("get_size"), &PartData::get_size);
	bind_method(D_METHOD("get_size_px"), &PartData::get_size_px);
	bind_method(D_METHOD("get_code"), &PartData::get_code);
	bind_method(D_METHOD("get_name"), &PartData::get_name);
	bind_method(D_METHOD("get_tab"), &PartData::get_tab);
	bind_method(D_METHOD("get_texture"), &PartData::get_texture);
	bind_method(D_METHOD("get_desc"), &PartData::get_desc);
	bind_method(D_METHOD("set_cost", "new_cost"), &PartData::set_cost);
	bind_method(D_METHOD("set_mass", "new_mass"), &PartData::set_mass);
	bind_method(D_METHOD("set_hp", "new_hp"), &PartData::set_hp);
	bind_method(D_METHOD("set_size", "new_size"), &PartData::set_size);
	bind_method(D_METHOD("set_name", "new_name"), &PartData::set_name);
	bind_method(D_METHOD("set_tab", "new_tab"), &PartData::set_tab);
	bind_method(D_METHOD("set_texture_path"), &PartData::set_texture_path);
}
void PartManager::_bind_methods() {
	BIND_CONSTANT(CODE_LENGTH)
	bind_method(D_METHOD("count_parts"), &PartManager::count_parts);
	bind_method(D_METHOD("load_csv", "path"), &PartManager::load_csv);
	bind_method(D_METHOD("save_csv", "path"), &PartManager::save_csv);
	bind_method(D_METHOD("load_json", "path"), &PartManager::load_json);
	bind_method(D_METHOD("save_json", "path"), &PartManager::save_json);
	bind_method(D_METHOD("copy_defaults", "path", "default_path"), &PartManager::copy_defaults);
	bind_method(D_METHOD("new_atlas"), &PartManager::new_atlas);
	bind_method(D_METHOD("remove_part", "part"), &PartManager::remove_part);
	bind_method(D_METHOD("new_part", "code"), &PartManager::new_part);
	bind_method(D_METHOD("lookup_id", "atlas_id"), &PartManager::lookup_id);
	bind_method(D_METHOD("lookup_code", "code"), &PartManager::lookup_code);
	bind_method(D_METHOD("get_unique", "code"), &PartManager::get_unique);
	bind_method(D_METHOD("set_unique", "code", "new_data"), &PartManager::set_unique);
}
void ResizableSprite2D::_bind_methods() {
	bind_method(D_METHOD("resize_scaled", "new_size"), &ResizableSprite2D::resize_scaled);
	bind_method(D_METHOD("resize_region", "new_size"), &ResizableSprite2D::resize_region);
}
void Part::_bind_methods() {
	bind_method(D_METHOD("get_data"), &Part::get_data);
	bind_method(D_METHOD("set_data", "new_data"), &Part::set_data);
}
void PartGrouping::_bind_methods() {
	bind_method(D_METHOD("is_dragging"), &PartGrouping::is_dragging);
	bind_method(D_METHOD("spawn_part", "part_data"), &PartGrouping::spawn_part);
	bind_method(D_METHOD("select_parts", "parts"), &PartGrouping::select_parts);
	bind_method(D_METHOD("clear_parts"), &PartGrouping::clear_parts);
	bind_method(D_METHOD("delete_parts"), &PartGrouping::delete_parts);
	bind_method(D_METHOD("get_mirroring"), &PartGrouping::get_mirroring);
	bind_method(D_METHOD("set_mirroring"), &PartGrouping::set_mirroring);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "mirroring"), "set_mirroring", "get_mirroring");
}
void ShipData::_bind_methods() {

}
void ShipManager::_bind_methods() {

}

void initialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
	GDREGISTER_CLASS(Unit);
	GDREGISTER_CLASS(Unit::Command);
	GDREGISTER_CLASS(Unit::RadarSignature);
	GDREGISTER_CLASS(Projectile);
	GDREGISTER_CLASS(Ship);
	GDREGISTER_CLASS(MouseCommands);
	GDREGISTER_CLASS(MouseSelection);
	GDREGISTER_CLASS(Battle);
	GDREGISTER_CLASS(Celestial);
	GDREGISTER_CLASS(PartData);
	GDREGISTER_CLASS(PartManager);
	GDREGISTER_CLASS(Part);
	GDREGISTER_CLASS(PartGrouping);
	GDREGISTER_CLASS(ResizableSprite2D);
	GDREGISTER_CLASS(ShipData);
	GDREGISTER_CLASS(ShipManager);
	println("Loaded Unit from unit.cpp");
	println("Loaded Command from unit.cpp");
	println("Loaded RadarSignature from unit.cpp");
	println("Loaded Projectile from projectile.cpp");
	println("Loaded Ship from ship.cpp");
	println("Loaded MouseCommands from mouse_commands.cpp");
	println("Loaded MouseSelection from mouse_selection.cpp");
	println("Loaded Battle from battle.cpp");
	println("Loaded Celestial from celestial.cpp");
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