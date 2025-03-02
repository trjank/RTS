#ifndef CELESTIAL_HPP
#define CELESTIAL_HPP

#include <godot_cpp/classes/sprite2d.hpp>
#include "capturable.hpp"

using godot::Sprite2D;
using godot::Vector2;

class Celestial: public Sprite2D, public Capturable {
   GDCLASS(Celestial, Sprite2D)
public:
   static constexpr double G = 6.674e-11;
   static constexpr double SOLAR_MASS = 1.0;
   static constexpr double MIN_GRAVITY_SCALE = 0.1;
   static constexpr double MAX_GRAVITY_SCALE = 5.0;
   static constexpr double MIN_TIME_SCALE = 0.0;
   static constexpr double MAX_TIME_SCALE = 5.0;
   static constexpr double MIN_ORBIT_RADIUS = 0.1;

   static double get_time_scale();
   static double get_gravity_scale();
   static void set_gravity_scale(double new_gravity_scale);
   static void set_time_scale(double new_time_scale);
   
   double get_mass();
   float get_speed();
   float get_orbit_radius();
   void set_orbit_radius(float new_radius);
   void orbit(Celestial& celestial);
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   static inline Vector2 UNIT_RADIAL = { 0.0, 1.0 };
   static double gravity_scale;
   static double time_scale;
   double mass = 0.0;
   double central_celestial_mass = 0.0;
   float orbit_radius = MIN_ORBIT_RADIUS;
   // Ref<Team> owner;
};

double Celestial::gravity_scale = G;

#endif // CELESTIAL_HPP