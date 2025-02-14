#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "register_types.h"
#include "unit.hpp"
#include "ship.hpp"
#include "projectile.hpp"
#include "mouse_commands.hpp"

#define register(class_name) ClassDB::register_class<class_name>()
#define bind(name, method)   ClassDB::bind_method(D_METHOD(name), method)
#define bind_enum            ClassDB::bind_integer_constant
#define println              UtilityFunctions::print

void Unit::_bind_methods() {
	bind("get_forward_direction", &Unit::get_forward_direction);
	bind("cloak", &Unit::cloak);
	bind("decloak", &Unit::decloak);
	bind("hit", &Unit::hit);
	bind("stop_moving", &Unit::stop_moving);
	bind("stop_targeting", &Unit::stop_targeting);
	bind("queue_move", &Unit::queue_move);
	bind("set_target", &Unit::set_target);
}
void Unit::RadarSignature::_bind_methods() {}
void Unit::Command::_bind_methods() {}
void MouseCommands::_bind_methods() {
	bind("set_formation", &MouseCommands::set_formation);
	bind_enum("MouseCommands", "Formation", "LINE", MouseCommands::Formation::LINE);
	bind_enum("MouseCommands", "Formation", "V", MouseCommands::Formation::V);
	bind_enum("MouseCommands", "Formation", "SMOOTH", MouseCommands::Formation::SMOOTH);
	bind_enum("MouseCommands", "Formation", "PRECISE", MouseCommands::Formation::PRECISE);
}

void initialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
	register(Unit);
	register(Unit::Command);
	register(Unit::RadarSignature);
	register(Projectile);
	register(Ship);
	register(MouseCommands);
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