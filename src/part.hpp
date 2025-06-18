#ifndef PART_HPP
#define PART_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/classes/static_body2d.hpp>
#include <godot_cpp/variant/color.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/tween.hpp>
#include <godot_cpp/classes/property_tweener.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/rectangle_shape2d.hpp>
#include <godot_cpp/core/math.hpp>
#include "part_data.hpp"
#include "resizable_sprite_2d.hpp"

namespace godot {

class Part: public StaticBody2D {
   GDCLASS(Part, StaticBody2D)
public:
   Part();
   Rect2 get_global_rect();
   Ref<PartData> get_data();
   virtual void set_data(Ref<PartData> part_data);
   virtual bool keep_as_node();
protected:
   static void _bind_methods();
private:
   Ref<PartData> data;
   Ref<RectangleShape2D> hitbox;
   CollisionShape2D* shape = nullptr;
   ResizableSprite2D* image = nullptr;
};

class PartGrouping: public ResizableSprite2D {
   GDCLASS(PartGrouping, Sprite2D)
public:
   void set_mirroring(bool mirroring);
   bool get_mirroring();
   bool is_dragging();
   void clear_parts();
   void delete_parts();
   void spawn_part(Ref<PartData> part_data);
   void select_parts(TypedArray<Node2D> selection);
   void snap_to_grid();
   void begin_dragging();
   void _input(const Ref<InputEvent>& event) override;
   void _process(double _dt) override;
protected:
   static void _bind_methods();
private:
   static constexpr int CLOCKWISE = 1;
   static constexpr int COUNTER_CLOCKWISE = -1;
   void update_region();
   void create_mirrored();
   void reposition_mirrored();
   void add_part(Part* part);
   void rotate_smoothly(int quarter_turns, float duration = 0.15);
   bool contains_mouse();
   bool dragging = false;
   bool mirroring = false;
   Vector<Part*> parts;
   Rect2 region = {0.0, 0.0, 0.0, 0.0};
   Vector2 mouse_offset;
   PartGrouping* mirrored = nullptr;
};

}

#endif // PART_HPP