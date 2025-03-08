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
#include "hitbox.hpp"
#include "battle.hpp"
#include "fleet.hpp"

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
void Hitbox::_bind_methods() {
	bind_method(D_METHOD("lookup", "coords"), &Hitbox::lookup);
	bind_method(D_METHOD("insert", "coords", "value"), &Hitbox::insert);
	bind_method(D_METHOD("merge", "hitbox"), &Hitbox::merge);
	bind_method(D_METHOD("remove", "hitbox"), &Hitbox::remove);
	bind_method(D_METHOD("get_size"), &Hitbox::get_size);
	bind_method(D_METHOD("calculate_size"), &Hitbox::calculate_size);
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
	println("Loaded Unit from unit.cpp");
	println("Loaded Command from unit.cpp");
	println("Loaded RadarSignature from unit.cpp");
	println("Loaded Projectile from projectile.cpp");
	println("Loaded Ship from ship.cpp");
	println("Loaded MouseCommands from mouse_commands.cpp");
	println("Loaded MouseSelection from mouse_selection.cpp");
	println("Loaded Battle from battle.cpp");
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