#ifndef SHIP_HPP
#define SHIP_HPP

#include <godot_cpp/templates/vector.hpp>
#include "unit.hpp"

using godot::Vector;

class Ship: public Unit {
   GDCLASS(Ship, Unit)
public:
   static constexpr float ENERGY_PER_WARP = 0.0;
   static constexpr int MAX_N_TURRETS = 100;
   class Turret;
   float get_shield();
   float get_energy();
   float hit_shield(float damage);
   void hit(float damage, float shield_penetration);
   int make_turret();
   Turret& get_turret(int ID);
   void _physics_process(double dt) override;
protected:
   float max_warp = 1000.0;
   float warp_per_sec = 100.0;
   float max_HP = 100.0;
   float shield = 0.0;
   float max_shield = 100.0;
   float shield_per_sec = 0.0;
   float energy = 0.0;
   float max_energy = 100.0;
   float energy_per_sec = 10.0;
   float shield_threshold = 1.0;
   static void _bind_methods();
private:
   Vector<Turret> turrets;
};

class Ship::Turret {
   float min_angle;
   float max_angle;
   void fire();
};

#endif