#ifndef SHIP_HPP
#define SHIP_HPP

#include "unit.hpp"

class Ship: public Unit {
   GDCLASS(Ship, Unit)
public:
   float get_shield();
   float get_energy();
   void hit(float damage, float shield_pen = 0.0);
   void _physics_process(double dt) override;
protected:
   float max_HP = 100.0;
   float shield = 0.0;
   float max_shield = 100.0;
   float shield_per_sec = 0.0;
   float energy = 0.0;
   float max_energy = 100.0;
   float energy_per_sec = 10.0;
   float shield_threshold = 1.0;
   static void _bind_methods();
};

#endif