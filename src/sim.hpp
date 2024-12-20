#ifndef SIM_HPP
#define SIM_HPP

#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/ref.hpp>
#include <string>
#include <map>

// Body.state flags
#define DEFAULT   0
#define CANT_TURN 1 << 0
#define CANT_MOVE 1 << 1
#define CANT_FIRE 1 << 2

using godot::Node2D;
using godot::Vector2;
using godot::RefCounted;
using godot::Ref;
using std::unordered_map;
using std::string;

namespace sim {

class StaticBody : public Node2D {
   GDCLASS(StaticBody, Node2D);
public:
   float get_mass();
   void set_mass(float new_mass);
   virtual Vector2 get_velocity();
   Vector2 get_direction();
   void generate_hitbox(/* image or something */);
protected:
   float mass = 1;
   float hitbox_radius = 0;
   int hitbox_width = 0;
   int hitbox_height = 0;
	static void _bind_methods();
};

class Body : public StaticBody {
   GDCLASS(Body, StaticBody);
public:
   float get_friction();
   float get_turnrate();
   float get_angular_velocity();
   Vector2 get_velocity() override;
   void set_velocity(Vector2 new_velocity);
   void set_angular_velocity(float new_angular_vel);
   void set_turnrate(float new_turnrate);
   void set_friction(float new_friction);
   void apply_force(Vector2 new_force);
   void apply_constant_force(Vector2 new_force);
   void set_constant_force(Vector2 new_force);
   void _physics_process(double dt) override;
protected:
   float turnrate;
   float angular_velocity;
   float friction = 1;
   short state = DEFAULT;
   Vector2 velocity;
   Vector2 force;
   Vector2 constant_force;
   void process_movement(double dt);
   void process_rotation(double dt);
   static void _bind_methods();
};

class Projectile : public Body {
   GDCLASS(Projectile, Body);
public:
   StaticBody *get_target();
   void set_target(StaticBody* new_target = nullptr);
   void set_speed(float new_speed);
   float get_speed();
   Projectile copy();
   void _physics_process(double dt) override;
protected:
   float speed;
   StaticBody *target = nullptr;
   void turn_to_dir(Vector2 dir);
   static void _bind_methods();
};

// TODO: finish this class
// class ProjectileManager : public RefCounted {
//    GDCLASS(ProjectileManager, RefCounted);
// public:
//    Projectile& get(string name);
//    void add(string name, Projectile projectile);
//    void remove(string name);
//    void clear();
// protected:
//    unordered_map<string, Projectile> name_to_proj;
// };

// every new kind of projectile stores an instance of Projectile
// since the position is useless, we actually set the position here
// then, we use the projectile's built-in prediction system to handle the heavy lifting
class Turret : public Body {
   GDCLASS(Turret, Body);
public:
   StaticBody *get_target();
   void set_target(StaticBody* new_target = nullptr);
   void set_ammo(Projectile* ammo_type = nullptr);
   bool fire();
   void _physics_process(double dt) override;
protected:
   float min_angle = 0;
   float max_angle = 0;
   double reload;
   double reload_timer = 0;
   Projectile *ammo;
   StaticBody *target;
   static void _bind_methods();
};

class Unit : public Body {
   GDCLASS(Unit, Body);
public:
   int HP;
   int shield;
   int max_shield;
   int shield_gen;
   int energy;
   int max_energy;
   int energy_gen;
   void hit(int damage, float penetration = 0);
   float get_top_speed();
   void set_mass(float new_mass);
   float get_thrust();
   void set_thrust(float new_thrust);
   void set_friction(float new_friction);
   StaticBody* get_target();
   void set_target(StaticBody* new_target);
   // void add_turret(Turret new_turret);
   // void remove_all_turrets();
   Unit copy();
   void _physics_process(double dt) override;
protected:
   float thrust = 0;
   float top_speed = 0;
   float arcing = .1;
   StaticBody* target;
   static void _bind_methods();
private:
   void calculate_top_speed();
   void face_target();
};

}

#endif