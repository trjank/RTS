#ifndef MOUSE_SELECTION_HPP
#define MOUSE_SELECTION_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/rectangle_shape2d.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/variant/typed_array.hpp>

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                  mouse_selection.hpp                  |
|                                                       |
*------------------------------------------------------*/

using godot::Ref;
using godot::Color;
using godot::Vector2;
using godot::Node2D;
using godot::Area2D;
using godot::CollisionShape2D;
using godot::RectangleShape2D;
using godot::Input;
using godot::InputEvent;
using godot::TypedArray;

class MouseSelection: public Area2D {
   GDCLASS(MouseSelection, Area2D)
public:
   static constexpr float OPACITY = 0.1;

   MouseSelection();
   bool is_enabled();
   Color get_color();
   TypedArray<Node2D> get_selected();
   void set_enabled(bool enable);
   void set_color(Color new_color);
   void set_visibility(Input::MouseMode visibility);
   void _draw() override;
   void _unhandled_input(const Ref<InputEvent>& event) override;
   void _process(double _dt) override;
protected:
   static void _bind_methods();
private:
   bool enabled = true;
   bool selecting = false;
   Color color = Color(1.0, 1.0, 1.0, OPACITY);
   Vector2 start_pos;
   Ref<RectangleShape2D> shape;
   TypedArray<Node2D> selected;
   
   void begin_selection();
   void end_selection();
   void resize(Vector2 new_size);
};

#endif // MOUSE_SELECTION_HPP