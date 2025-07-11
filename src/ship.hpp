#ifndef SHIP_HPP
#define SHIP_HPP

#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/math.hpp>
#include "resizable_sprite_2d.hpp"
#include "unit.hpp"
#include "destructable.hpp"
#include "ship_data.hpp"
#include "defaults.hpp"
#include "part.hpp"
#include "player.hpp"

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
   static constexpr double RATIO_MIN_ENERGY = -1.0;
   static constexpr double STUNLOCK_DRAIN = 1.0;

   static Ship* create_from(Ref<ShipData> ship_data);

   bool is_stunlocked() const;
   bool is_owned_by(Ref<Player> player) const;
   void fire();
   int get_cost() const override;
   double get_energy() const override;
   double get_shield() const;
   double get_ratio_reserve_energy() const;
   double get_ratio_recharge_warp() const;
   double get_ratio_recharge_shield() const;
   Ref<ShipData> get_data() const;
   Ref<Player> get_owner() const;
   void set_owner(Ref<Player> new_owner);
   void reset_stats();
   void kill() override;
   double hit_shield(double damage);
   void hit(double damage, double shield_penetration = 0.0);
   Ship* clone() const;
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   bool selected = false;
   double shield = 0.0;
   double energy = 0.0;
   double ratio_reserve_energy = 0.0;
   double ratio_recharge_warp = 0.0;
   double ratio_recharge_shield = 0.0;
   double min_energy = 0.0;
   NEVER_NULL Ref<Player> owner = get_default<Player>();
   NEVER_NULL Ref<ShipData> data = get_default<ShipData>();

   Part* create_unique_part(int part_id);
   void create_image();
   void calculate_reserve_ratios();
};

}

#endif