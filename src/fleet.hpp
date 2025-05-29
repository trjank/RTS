#ifndef FLEET_HPP
#define FLEET_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include "ship.hpp"

using godot::RefCounted;

class Fleet: public RefCounted {
   GDCLASS(Fleet, RefCounted)
public:
   static constexpr int FLEET_SIZE = 10;
   // Ref<Ship::Data> get_ship(int slot);
   void save_ship(int slot);
   void load_ship();
protected:
   static void _bind_methods();
private:
   // Ref<Ship::Data> ships[FLEET_SIZE];
};

#endif // FLEET_HPP