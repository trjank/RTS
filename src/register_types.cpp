#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "register_types.h"
#include "unit.hpp"
#include "ship.hpp"
#include "projectile.hpp"
#include "mouse_commands.hpp"

using godot::ClassDB;
using godot::UtilityFunctions;

void Unit::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_forward_direction"), &Unit::get_forward_direction);
	ClassDB::bind_method(D_METHOD("cloak"), &Unit::cloak);
	ClassDB::bind_method(D_METHOD("decloak"), &Unit::decloak);
	ClassDB::bind_method(D_METHOD("hit"), &Unit::hit);
	ClassDB::bind_method(D_METHOD("stop_moving"), &Unit::stop_moving);
	ClassDB::bind_method(D_METHOD("stop_targeting"), &Unit::stop_targeting);
	ClassDB::bind_method(D_METHOD("queue_move"), &Unit::queue_move);
	ClassDB::bind_method(D_METHOD("set_target"), &Unit::set_target);
}
void Unit::RadarSignature::_bind_methods() {}
void Unit::Command::_bind_methods() {}
void MouseCommands::_bind_methods() {}

void initialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
	ClassDB::register_class<Unit>();
	ClassDB::register_class<Unit::Command>();
	ClassDB::register_class<Unit::RadarSignature>();
	ClassDB::register_class<Projectile>();
	ClassDB::register_class<Ship>();
	ClassDB::register_class<MouseCommands>();
	UtilityFunctions::print("Loaded Unit from unit.cpp");
	UtilityFunctions::print("Loaded Command from unit.cpp");
	UtilityFunctions::print("Loaded RadarSignature from unit.cpp");
	UtilityFunctions::print("Loaded Projectile from projectile.cpp");
	UtilityFunctions::print("Loaded Ship from ship.cpp");
	UtilityFunctions::print("Loaded MouseCommands from mouse_commands.cpp");
}

void uninitialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;	
}

extern "C" {

GDExtensionBool GDE_EXPORT example_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
	init_obj.register_initializer(initialize_module);
	init_obj.register_terminator(uninitialize_module);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
	return init_obj.init();
}

}