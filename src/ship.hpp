#ifndef SHIP_HPP
#define SHIP_HPP

#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/math.hpp>
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
   /*------------------------------------------------------|
   | Dropoffs can be any positive number: 1.0 means a      |
   | linear dropoff of regeneration with energy; a number  |
   | less than 1.0 means a very gradual dropoff; a number  |
   | greater than 1.0 means a very steep dropoff.          |
   |------------------------------------------------------*/
   static constexpr double WARP_RECHARGE_DROPOFF = 1.0;
   static constexpr double SHIELD_RECHARGE_DROPOFF = 1.0;
   static constexpr double WARP_ENERGY_USE = 0.0;
   static constexpr double SHIELD_ENERGY_USE = 0.0;
   static constexpr double STUNLOCK_ENERGY_LIMIT = 1.0;
   static constexpr double STUNLOCK_DRAIN = 1.0;

   Ship();
   bool is_stunlocked();
   void fire();
   void kill() override;
   Player* get_owner();
   int get_cost() override;
   double get_energy() override;
   double get_shield();
   Ref<ShipData> get_data();
   void set_owner(Player* new_owner);
   void set_data(Ref<ShipData> new_data);
   void copy_data_from(const Ship* other_ship);
   double hit_shield(double damage);
   void hit(double damage, double shield_penetration = 0.0);
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   double shield = 0.0;
   double energy = 0.0;
   double ratio_reserve_energy = 0.0;
   double ratio_recharge_warp = 0.0;
   double ratio_recharge_shield = 0.0;
   Ref<ShipData> data;
   Vector<Part*> unique_parts;
   Vector<Vector<Part*>> action_groups;
   ResizableSprite2D* image;
   bool selected = false;
   Player* owner = nullptr;

   Part* create_unique_part(int part_id);
   void calculate_reserve_ratios();
};

}

#endif