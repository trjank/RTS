#ifndef PROJECTILE_HPP
#define PROJECTILE_HPP

#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/rectangle_shape2d.hpp>
#include "unit.hpp"
#include "unique_part_data.hpp"

namespace godot {

class Projectile: public Unit {
   GDCLASS(Projectile, Unit)
public:
   Projectile();
   Ref<ProjectileData> get_data();
   void set_data(Ref<ProjectileData> new_data);
protected:
   static void _bind_methods();
private:
   Ref<ProjectileData> data;
   CollisionShape2D* shape;
   Ref<RectangleShape2D> hitbox; 
};

}

#endif