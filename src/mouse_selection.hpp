#ifndef MOUSE_SELECTION_HPP
#define MOUSE_SELECTION_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/rectangle_shape2d.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include "defaults.hpp"

namespace godot {

class MouseSelection: public Area2D {
   GDCLASS(MouseSelection, Area2D)
public:
   MouseSelection();
   bool is_enabled() const;
   bool is_selecting() const;
   Color get_color() const;
   Rect2 get_region() const;
   TypedArray<Node2D> get_selected();
   void set_enabled(bool enable);
   void set_color(Color new_color);
   void _draw() override;
   void _process(double _dt) override;
   void _unhandled_input(const Ref<InputEvent>& event) override;
protected:
   static void _bind_methods();
private:
   bool enabled = true;
   bool selecting = false;
   Color color = {1.0, 1.0, 1.0, 0.1};
   Rect2 region = {0.0, 0.0, 0.0, 0.0};
   TypedArray<Node2D> selected;
   NEVER_NULL Ref<RectangleShape2D> shape = memnew(RectangleShape2D);
   
   void resize_hitbox();
   void begin_selection();
   void stop_selection();
   void finish_selection();
};

}

#endif // MOUSE_SELECTION_HPP