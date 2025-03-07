#ifndef MOUSE_COMMANDS_HPP
#define MOUSE_COMMANDS_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include "unit.hpp"

/*------------------------------------------------------*
|                                                       |
|              __ ___ _  ___ ___ _  _ __ ___            |
|             (__` | / \ |__)|  \|  |(__` |             |
|             .__) |/```\|  \|__/!__!.__) |             |
|                                                       |
|                  mouse_commands.hpp                   |
|                                                       |
*------------------------------------------------------*/

using godot::Ref;
using godot::Variant;
using godot::Vector2;
using godot::Vector2i;
using godot::Node2D;
using godot::Input;
using godot::InputEvent;
using godot::Texture2D;
using godot::Vector;
using godot::TypedArray;

class MouseCommands: public Node2D {
   GDCLASS(MouseCommands, Node2D)
public:
   /*------------------------------------------------------*
   | NOTE: Do NOT set custom values for the Action enum;   |
   | the Action enum is used to index an array (see        |
   | cursor_bindings below).                               |
   |                                                       |
   | NOTE: NUM_OF_ACTIONS is not exposed to the editor and |
   | should not be passed as an argument to any of the     |
   | functions here.                                       |
   |                                                       |
   | NOTE: The Formation enum values correspond to the     |
   | number of waypoints used to construct a path from     |
   | mouse movement. You can add more or modify SMOOTH and |
   | PRECISE so long as the value is greater than 1.       |
   *------------------------------------------------------*/
   enum Action { NONE, MOVE, TARGET, NUM_OF_ACTIONS };
   enum Formation { LINE = 2, V = 3, SMOOTH = 10, PRECISE = 30 };
   static constexpr float DIST_BETWEEN_WAYPOINTS = 1.0;
   static constexpr int MAX_UNITS_SELECTED = 10;
   static inline Vector2i CURSOR_SIZE = { 32, 32 };
   static inline Vector2i CURSOR_CENTER = { 16, 16 };
   
   MouseCommands();
   Action get_action();
   Formation get_formation();
   Ref<Unit::Command> new_command(Vector2 pos = { 0.0, 0.0 });
   void set_command_icon(Ref<Texture2D> new_image);
   void bind_cursor_to_action(Ref<Texture2D> image, Action action);
   void select_units(TypedArray<Node2D> selection);
   void _process(double _dt) override;
   void _unhandled_input(const Ref<InputEvent>& event) override;
protected:
   static void _bind_methods();
private:
   bool queue_move = true;
   Action action = NONE;
   Formation formation = LINE;
   float path_length = 0.0;
   Ref<Unit::Command> target;
   Vector<Vector2> waypoints;
   Vector<Ref<Unit::Command>> commands;
   Vector<Ref<Unit::RadarSignature>> units;
   Ref<Texture2D> move_icon_image;
   Ref<Texture2D> cursor_bindings[NUM_OF_ACTIONS];
   
   template<typename T> struct MoveOrder;
   typedef MoveOrder<Ref<Unit::RadarSignature>> UnitMoveOrder;
   typedef MoveOrder<Ref<Unit::Command>> CommandMoveOrder;
   
   Vector2 get_point(float parametric_dist);
   void begin_path();
   void update_path();
   void update_target();
   void update_commands();
   void select_unit(Variant unit);
   void order_unit_to_move(Ref<Unit::RadarSignature> unit, Ref<Unit::Command> command);
   void order_units_to_move();
   void stop_unit(Ref<Unit::RadarSignature> signature);
   void stop_all_units();
   void set_action_with_cursor(Action new_action);
};

template<typename T>
struct MouseCommands::MoveOrder {
   /*------------------------------------------------------*
   | MoveOrder is the custom comparator used to sort units |
   | and commands. Sorting is necessary to ensure units    |
   | move sensibly as to reduce travel distance and        |
   | intersections with other units.                       |
   *------------------------------------------------------*/
   static Vector2 get_center(Vector<T> objects);
   Vector2 axis;
   Vector2 center;
   bool operator()(const T& A, const T& B) const;
};

VARIANT_ENUM_CAST(MouseCommands::Action);
VARIANT_ENUM_CAST(MouseCommands::Formation);

#endif // MOUSE_COMMANDS_HPP