#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "register_types.h"
#include "unit.hpp"
#include "ship.hpp"
#include "projectile.hpp"
#include "mouse_commands.hpp"

#define bind_method ClassDB::bind_method
#define bind_enum ClassDB::bind_integer_constant
#define println UtilityFunctions::print

void Unit::_bind_methods() {
	bind_method(D_METHOD("get_HP"), &Unit::get_HP);
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
	BIND_VIRTUAL_METHOD(MouseCommands, _finish_selection);
	BIND_VIRTUAL_METHOD(MouseCommands, _reset_selection_box);
	BIND_VIRTUAL_METHOD(MouseCommands, _update_selection_box);
	bind_method(D_METHOD("bind_cursor_to_action", "image", "action"), &MouseCommands::bind_cursor_to_action);
	bind_method(D_METHOD("set_command_icon", "image"), &MouseCommands::set_command_icon);
	bind_method(D_METHOD("clear_units"), &MouseCommands::clear_units);
	bind_method(D_METHOD("select_unit", "unit"), &MouseCommands::select_unit);
	bind_enum("MouseCommands", "Formation", "LINE", LINE);
	bind_enum("MouseCommands", "Formation", "V", V);
	bind_enum("MouseCommands", "Formation", "SMOOTH", SMOOTH);
	bind_enum("MouseCommands", "Formation", "PRECISE", PRECISE);
	bind_enum("MouseCommands", "Action", "NONE", NONE);
	bind_enum("MouseCommands", "Action", "SELECT", SELECT);
	bind_enum("MouseCommands", "Action", "MOVE", MOVE);
	bind_enum("MouseCommands", "Action", "TARGET", TARGET);
}

void initialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
	GDREGISTER_CLASS(Unit);
	GDREGISTER_CLASS(Unit::Command);
	GDREGISTER_CLASS(Unit::RadarSignature);
	GDREGISTER_CLASS(Projectile);
	GDREGISTER_CLASS(Ship);
	GDREGISTER_CLASS(MouseCommands);
	println("Loaded Unit from unit.cpp");
	println("Loaded Command from unit.cpp");
	println("Loaded RadarSignature from unit.cpp");
	println("Loaded Projectile from projectile.cpp");
	println("Loaded Ship from ship.cpp");
	println("Loaded MouseCommands from mouse_commands.cpp");
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