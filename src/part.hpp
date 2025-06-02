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
   static constexpr int SCALE_PX = 64;
   static Part* create_from(Ref<PartData> part_data, Node* parent);
   Part();
   void get_adjacent_parts();
   Rect2 get_global_rect();
protected:
   static void _bind_methods();
private:
   ResizableSprite2D* image = nullptr;
   CollisionShape2D* shape = nullptr;
   Ref<RectangleShape2D> hitbox;
};

// class Weapon: public Part {
//    GDCLASS(Weapon, Part)
// public:
// protected:
//    static void _bind_methods();
// private:
//    // Projectile* projectile;
//    int shots_per_burst;
//    double energy_per_shot;
//    double burst_firerate;
//    double net_firerate;
//    double range;
// };

// class TurretMount: public Part {
//    GDCLASS(TurretMount, Part)
// public:
//    void set_weapon(Weapon* weapon);
// protected:
//    static void _bind_methods();
// private:
//    Weapon* weapon = nullptr;
//    double min_angle;
//    double max_angle;
// };

// class WarpDrive: public Part {
//    double warp_mass_ratio;
//    double warp_recharge_rate;
// };

// class ShieldGenerator: public Part {
//    double max_shield;
//    double shield_recharge_rate;
// };

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

}

#endif // PART_HPP