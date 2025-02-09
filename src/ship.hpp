#ifndef SHIP_HPP
#define SHIP_HPP

#include "unit.hpp"

class Ship: public Unit {
   GDCLASS(Ship, Unit)
protected:
   static void _bind_methods() {};
};

#endif