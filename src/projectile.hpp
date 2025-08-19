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
   static Projectile* create_from(Ref<ProjectileData> data);

   Projectile();
   Ref<ProjectileData> get_data() const;
   /*------------------------------------------------------|
   | Using the default scale property with collision       |
   | shapes is discouraged. Use these methods instead.     |
   |------------------------------------------------------*/
   double get_lifespan_sec() const;
   double get_time_lived_sec() const;
   double get_safe_scale() const;
   void set_lifespan_sec(double new_lifespan_sec);
   void set_safe_scale(double new_safe_scale);
   void _physics_process(double dt) override;
protected:
   static void _bind_methods();
private:
   double lifespan_sec = 0.0;
   double time_lived_sec = 0.0;
   double safe_scale = 1.0;
   NEVER_NULL Ref<ProjectileData> data = get_default<ProjectileData>();
   NEVER_NULL Ref<RectangleShape2D> hitbox = memnew(RectangleShape2D);
   NEVER_NULL SAFE_PTR CollisionShape2D* collision_shape = memnew(CollisionShape2D);
};

}

#endif