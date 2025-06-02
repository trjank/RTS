#ifndef SHIP_HPP
#define SHIP_HPP

#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include "unit.hpp"
#include "battle.hpp"
#include "destructable.hpp"
#include "part.hpp"

using godot::Ref;
using godot::RefCounted;
using godot::Vector;
using godot::String;

class Ship: public Unit, public Destructable {
   GDCLASS(Ship, Unit)
public:
   static constexpr float ENERGY_PER_WARP = 0.0;
   static constexpr int MAX_N_TURRETS = 100;
   int get_cost() override;
   float get_energy() override;
   float get_shield();
   float hit_shield(float damage);
   void hit(float damage, float shield_penetration = 0.0);
   // int make_turret();
   // Turret& get_turret(int ID);
   void kill() override;
   void _physics_process(double dt) override;
protected:
   int cost;
   float max_warp = 5000.0;
   float warp_per_sec = 200.0;
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
   bool selected = false;
   Battle::Player* owner = nullptr;
   // Vector<TurretMount*> turrets;
};

#endif