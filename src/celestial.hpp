#ifndef CELESTIAL_HPP
#define CELESTIAL_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/circle_shape2d.hpp>
#include "capturable.hpp"
#include "battle.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                     celestial.hpp                     |
|                                                       |
*------------------------------------------------------*/

using godot::Color;
using godot::Node2D;
using godot::Sprite2D;
using godot::Vector2;
using godot::Area2D;
using godot::CollisionShape2D;
using godot::CircleShape2D;

class Celestial;

class Orbit: public Node2D {
   GDCLASS(Orbit, Node2D)
public:
   static constexpr double G = 6.674e-11;
   static constexpr double MIN_DISTANCE = 0.1;
   static constexpr double MIN_TIME_SCALE = 0.0;
   static constexpr double MAX_TIME_SCALE = 5.0;
   static constexpr double MIN_GRAVITY_SCALE = 0.1;
   static constexpr double MAX_GRAVITY_SCALE = 5.0;
   static inline Color COLOR = { 1.0, 1.0, 1.0, 0.3 };

   static double get_time_scale();
   static double get_gravity_scale();
   static void set_time_scale(double new_time_scale);
   static void set_gravity_scale(double new_gravity_scale);

   double get_angular_velocity();
   double get_distance();
   void set_distance(double new_distance);
   void orbit(Celestial* celestial);
   void _physics_process(double dt) override;
   void _draw() override;
protected:
   static void _bind_methods();
private:
   static double gravity_scale;
   static double time_scale;

   double distance = MIN_DISTANCE;
   Vector2 unit_radial = { 0.0, 1.0 };
   Celestial* orbiting = nullptr;
};

class Celestial: public Sprite2D, public Capturable {
   GDCLASS(Celestial, Sprite2D)
public:
   static constexpr double SOLAR_MASS = 1.0;
   
   Celestial();
   bool can_capture() override;
   double get_mass();
   double get_radius();
   double get_angular_velocity();
   double get_alloy_per_sec() override;
   double get_energy_per_sec() override;
   void set_radius(double new_radius);
   void set_angular_velocity(float new_angular_velocity);
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   bool selected = false;
   double mass = 0.0;
   double radius = 0.0;
   double angular_velocity;
   Ref<CircleShape2D> hitbox;
   Ref<Battle::Team> owner;
};

#endif // CELESTIAL_HPP