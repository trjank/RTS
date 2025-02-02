#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "register_types.h"
#include "sim.hpp"

using namespace godot;

using sim::StaticBody;
using sim::Body;
using sim::Projectile;
using sim::Turret;
using sim::Unit;

void StaticBody::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_mass"), &Body::get_mass);
	ClassDB::bind_method(D_METHOD("set_mass"), &Body::set_mass);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "mass"), "set_mass", "get_mass");
}
void Body::_bind_methods() {
	ClassDB::bind_method(D_METHOD("apply_force"), &Body::apply_force);
   ClassDB::bind_method(D_METHOD("apply_constant_force"), &Body::apply_constant_force);
   ClassDB::bind_method(D_METHOD("set_constant_force"), &Body::apply_force);
	ClassDB::bind_method(D_METHOD("get_friction"), &Body::get_friction);
	ClassDB::bind_method(D_METHOD("set_friction"), &Body::set_friction);
   ClassDB::bind_method(D_METHOD("get_velocity"), &Body::get_velocity);
	ClassDB::bind_method(D_METHOD("set_velocity"), &Body::set_velocity);
   ClassDB::bind_method(D_METHOD("get_turnrate"), &Body::get_turnrate);
	ClassDB::bind_method(D_METHOD("set_turnrate"), &Body::set_turnrate);
   ClassDB::bind_method(D_METHOD("get_angular_velocity"), &Body::get_angular_velocity);
	ClassDB::bind_method(D_METHOD("set_angular_velocity"), &Body::set_angular_velocity);
   ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "velocity"), "set_velocity", "get_velocity");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "angular_velocity"), "set_angular_velocity", "get_angular_velocity");
   ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "turnrate"), "set_turnrate", "get_turnrate");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "friction"), "set_friction", "get_friction");
}

void Projectile::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_target"), &Projectile::get_target);
	ClassDB::bind_method(D_METHOD("set_target"), &Projectile::set_target);
	ClassDB::bind_method(D_METHOD("get_speed"), &Projectile::get_speed);
	ClassDB::bind_method(D_METHOD("set_speed"), &Projectile::set_speed);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "speed"), "set_speed", "get_speed");
}
void Turret::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_target"), &Turret::get_target);
	ClassDB::bind_method(D_METHOD("set_target"), &Turret::set_target);
	ClassDB::bind_method(D_METHOD("fire"), &Turret::fire);
}
void Unit::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_top_speed"), &Unit::get_top_speed);
	ClassDB::bind_method(D_METHOD("get_target"), &Unit::get_target);
	ClassDB::bind_method(D_METHOD("set_target"), &Unit::set_target);
   ClassDB::bind_method(D_METHOD("get_thrust"), &Unit::get_thrust);
	ClassDB::bind_method(D_METHOD("set_thrust"), &Unit::set_thrust);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "thrust"), "set_thrust", "get_thrust");
}

void initialize_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
	ClassDB::register_class<StaticBody>();
	UtilityFunctions::print("Loaded sim::StaticBody from sim.cpp");
	ClassDB::register_class<Body>();
	UtilityFunctions::print("Loaded sim::Body from sim.cpp");
	ClassDB::register_class<Unit>();
	UtilityFunctions::print("Loaded sim::Unit from sim.cpp");
	ClassDB::register_class<Projectile>();
	UtilityFunctions::print("Loaded sim::Projectile from sim.cpp");
	ClassDB::register_class<Turret>();
	UtilityFunctions::print("Loaded sim::Turret from sim.cpp");
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