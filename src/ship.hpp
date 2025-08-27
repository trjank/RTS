#ifndef SHIP_HPP
#define SHIP_HPP

#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/rectangle_shape2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/core/math.hpp>
#include "resizable_sprite_2d.hpp"
#include "unit.hpp"
#include "destructable.hpp"
#include "ship_data.hpp"
#include "defaults.hpp"
#include "part.hpp"
#include "detection.hpp"

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

   Ship();
   Ship* clone() const;
   bool is_stunlocked() const;
   bool is_carrier() const;
   int get_cost() const override;
   double get_energy() const override;
   double get_shield() const;
   double get_ratio_reserve_energy() const;
   double get_ratio_recharge_warp() const;
   double get_ratio_recharge_shield() const;
   double get_share_min_energy() const;
   Ref<Unit::RadarSignature> get_manual_target() const;
   Ref<ShipData> get_data() const;
   void set_share_min_energy(double new_share_min_energy);
   void reset_stats();
   bool transfer_energy(double energy_transfer, Ref<Unit::RadarSignature> ship);
   void transfer_energy_radius(double energy_per_ship, double range);
   void set_kill_credit(Ref<Unit::RadarSignature> unit);
   void kill() override;
   // void target(Ref<Target> new_target) override;
   void update_detection();
   double hit_shield(double damage);
   // shield_penetration should be between 0.0 and 1.0
   void hit(double damage, double shield_penetration);
   void _physics_process(double dt) override;
   void _draw() override;
protected:
   static void _bind_methods();
private:
   double shield = 0.0;
   double energy = 0.0;
   double ratio_reserve_energy = 0.0;
   double ratio_recharge_warp = 0.0;
   double ratio_recharge_shield = 0.0;
   double min_energy = 0.0;
   double share_min_energy = 0.0;
   Ref<Unit::RadarSignature> kill_credit;
   Ref<Target> manual_target;
   NEVER_NULL Detection* detection = memnew(Detection);
   NEVER_NULL Ref<ShipData> data = get_default<ShipData>();
   NEVER_NULL Ref<RectangleShape2D> hitbox = memnew(RectangleShape2D);

   void create_unique_part(int part_id);
   void create_hitbox();
   void calculate_reserve_ratios();
};

}

#endif