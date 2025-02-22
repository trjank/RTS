#ifndef HITBOX_HPP
#define HITBOX_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <bitset>

using godot::RefCounted;
using godot::Vector2i;
using godot::Ref;
using std::bitset;

class Hitbox: public RefCounted {
   GDCLASS(Hitbox, RefCounted)
public:
   static const int WIDTH = 64;
   static const int HEIGHT = 64;
   int get_size();
   bool contains(Vector2i coords);
   void insert(Vector2i coords, bool value = true);
   void merge(Ref<Hitbox> hitbox);
   void remove(Ref<Hitbox> hitbox);
   void calculate_size();
protected:
   static void _bind_methods();
private:
   bitset<WIDTH * HEIGHT> cells;
   int size = 0;
   bool inside_grid(Vector2i coords);
   int to_index_1D(Vector2i coords);
};

#endif // HITBOX_HPP