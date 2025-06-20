#include "projectile.hpp"

using namespace godot;

Projectile::Projectile() {
   add_child(shape = memnew(CollisionShape2D));
   hitbox.instantiate();
   shape->set_shape(hitbox);
}