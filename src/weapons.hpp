#ifndef WEAPONS_HPP
#define WEAPONS_HPP

#include "part.hpp"
#include "projectile.hpp"

namespace godot {

// class Weapon: public Part {
//    GDCLASS(Weapon, Part)
// public:
//    void set_data(Ref<PartData> data) override;
// protected:
//    static void _bind_methods();
// private:
//    Projectile* projectile;
//    int shots_per_burst = 0;
//    double energy_per_shot = 0.0;
//    double burst_firerate = 0.0;
//    double net_firerate = 0.0;
//    double range = 0.0;
// };

// class TurretMount: public Part {
//    GDCLASS(TurretMount, Part)
// public:
//    bool keep_as_node() override;
//    void set_weapon(Weapon* weapon);
// protected:
//    static void _bind_methods();
// private:
//    Weapon* weapon = nullptr;
//    double min_angle;
//    double max_angle;
// };

}

#endif // WEAPONS_HPP