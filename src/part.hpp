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

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                   part_grouping.hpp                   |
|                                                       |
*------------------------------------------------------*/

using godot::Node2D;
using godot::Vector;
using godot::Vector2;
using godot::TypedArray;
using godot::StaticBody2D;
using godot::Rect2;
using godot::InputEvent;
using godot::Color;
using godot::Tween;
using godot::PropertyTweener;
using godot::RectangleShape2D;
using godot::CollisionShape2D;


class Part: public StaticBody2D {
   GDCLASS(Part, StaticBody2D)
public:
   static constexpr int SCALE_PX = 32;
   static Part* create_from(Ref<PartData> part_data, Node* parent);
   Part();
   void get_adjacent_parts();
   Rect2 get_global_rect();
protected:
   static void _bind_methods();
private:
   ResizableSprite2D* image;
   CollisionShape2D* shape;
   Ref<RectangleShape2D> hitbox;
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
   void _unhandled_input(const Ref<InputEvent>& event) override;
   void _process(double _dt) override;
protected:
   static void _bind_methods();
private:
   static constexpr int CLOCKWISE = 1;
   static constexpr int COUNTER_CLOCKWISE = -1;
   static const Rect2 EMPTY_REGION;
   void update_region();
   void create_mirrored();
   void reposition_mirrored();
   void add_part(Part* part);
   void rotate_smoothly(int quarter_turns, float duration = 0.15);
   bool contains_mouse();
   bool dragging = false;
   bool mirroring = false;
   Vector<Part*> parts;
   Rect2 region = EMPTY_REGION;
   Vector2 mouse_offset;
   PartGrouping* mirrored = nullptr;
};

#endif // PART_HPP