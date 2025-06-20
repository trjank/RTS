#ifndef SHIP_HPP
#define SHIP_HPP

#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include "resizable_sprite_2d.hpp"
#include "unit.hpp"
#include "battle.hpp"
#include "destructable.hpp"
#include "ship_data.hpp"
#include "part.hpp"

namespace godot {

class Ship: public Unit, public Destructable {
   GDCLASS(Ship, Unit)
public:
   static constexpr float ENERGY_PER_WARP = 0.0;
   static constexpr int MAX_N_TURRETS = 100;

   Ship();
   int get_cost() override;
   float get_energy() override;
   float get_shield();
   Ref<ShipData> get_data();
   void set_data(Ref<ShipData> new_data);
   float hit_shield(float damage);
   void hit(float damage, float shield_penetration = 0.0);
   void fire();
   void kill() override;
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   float shield = 0.0;
   float energy = 0.0;
   float warp = 0.0;
   Ref<ShipData> stats;
   ResizableSprite2D* image;
   bool selected = false;
   Player* owner = nullptr;
   // Vector<TurretMount*> turrets;
};

}

#endif