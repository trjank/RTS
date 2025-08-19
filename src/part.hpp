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
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/core/math.hpp>
#include "part_data.hpp"
#include "resizable_sprite_2d.hpp"
#include "defaults.hpp"

namespace godot {

class Ship;

class Part: public StaticBody2D {
   GDCLASS(Part, StaticBody2D)
public:
   enum InitStatus {OKAY_KEEP_PART, FAILURE_NO_MOUNT};

   static Part* create_from(Ref<PartData> part_data);

   Ref<PartData> get_data() const;
   virtual InitStatus _ship_init(const Ship& parent_ship, int part_id);
protected:
   static void _bind_methods();
private:
   NEVER_NULL Ref<RectangleShape2D> hitbox = memnew(RectangleShape2D);
   NEVER_NULL Ref<PartData> data = get_default<PartData>();

   void create_image();
   void create_hitbox();
};


class PartGrouping: public Sprite2D {
   GDCLASS(PartGrouping, Sprite2D)
public:
   static constexpr int CLOCKWISE = 1;
   static constexpr int COUNTER_CLOCKWISE = -1;

   PartGrouping* clone() const;
   bool is_dragging() const;
   bool contains_mouse() const;
   void flip_parts();
   void rotate_parts(int quarter_turns, float duration = 0.15);
   void clear_parts();
   void delete_parts();
   bool spawn_part(Ref<PartData> part_data);
   void select_parts(TypedArray<Node2D> selection, Rect2 region);
   void snap_to_grid();
   void _input(const Ref<InputEvent>& event) override;
   void _process(double _dt) override;
protected:
   static void _bind_methods();
private:
   bool dragging = false;
   Vector2 mouse_offset = {0.0, 0.0};
   const Vector2 TEXTURE_OFFSET = {0.0, 0.0};
   const Vector2 GRID_SQUARE = {PartData::PX_PER_GRID_SQUARE, PartData::PX_PER_GRID_SQUARE};

   void stop_dragging();
   void begin_dragging();
   void add_part(Part* part);
   Vector2 grid_snap_floor(Vector2 vector);
   Vector2 grid_snap_ceil(Vector2 vector);
};

}

#endif // PART_HPP