#ifndef PROJECTILE_HPP
#define PROJECTILE_HPP

#include "unit.hpp"

class Projectile: public Unit {
   GDCLASS(Projectile, Unit)
protected:
   static void _bind_methods() {};
};

#endif