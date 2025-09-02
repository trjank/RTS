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

   Part();
   bool is_flipped() const;
   PartData::Orientation get_orientation() const;
   Rect2 get_rect() const;
   Rect2i get_grid_rect() const;
   Ref<PartData> get_data() const;
   void set_orientation(PartData::Orientation new_orientation);
   void snap_to_grid();
   virtual InitStatus _ship_init(const Ship& _parent_ship, int _part_id);
protected:
   static void _bind_methods();
private:
   NEVER_NULL Ref<PartData> data = get_default<PartData>();
   NEVER_NULL Ref<RectangleShape2D> hitbox = memnew(RectangleShape2D);
	NEVER_NULL SAFE_PTR ResizableSprite2D* image = memnew(ResizableSprite2D);
   NEVER_NULL SAFE_PTR CollisionShape2D* collider = memnew(CollisionShape2D);

   double get_true_rotation(bool flipped) const;
};


class PartGrouping: public Sprite2D {
   GDCLASS(PartGrouping, Sprite2D)
public:
   static constexpr int CLOCKWISE = 1;
   static constexpr int COUNTER_CLOCKWISE = -1;

   bool contains_mouse() const;
   void resize(Vector2 new_size);
   void flip_parts();
   void rotate_parts(int quarter_turns, float duration);
   void clear_parts();
   void delete_parts();
   bool spawn_part_at(Vector2 position, Ref<PartData> part_data);
   bool spawn_part_at_mouse(Ref<PartData> part_data);
   void select_parts(TypedArray<Node2D> selection, Rect2 region);
   void snap_to_grid();
protected:
   static void _bind_methods();
private:
   const Vector2 GRID_SQUARE = {PartData::PX_PER_GRID_SQUARE, PartData::PX_PER_GRID_SQUARE};

   void add_part(Part* part);
   Vector2 grid_snap_floor(Vector2 xy);
   Vector2 grid_snap_ceil(Vector2 xy);
};

}

#endif // PART_HPP