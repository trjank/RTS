#ifndef MOUSE_COMMANDS_HPP
#define MOUSE_COMMANDS_HPP

#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/input.hpp>
#include "unit.hpp"

using godot::Ref;
using godot::Vector2;
using godot::Vector2i;
using godot::Node2D;
using godot::InputEvent;
using godot::Vector;
using godot::Texture2D;
using godot::Input;

class MouseCommands: public Node2D {
   GDCLASS(MouseCommands, Node2D)
public:
   /*-------------------------------------------------------*
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
    *-------------------------------------------------------*/
   enum Action { NONE, SELECT, MOVE, TARGET, NUM_OF_ACTIONS };
   enum Formation { LINE = 2, V = 3, SMOOTH = 10, PRECISE = 30 };
   const int MAX_UNITS_SELECTED = 10;
   const Vector2i CURSOR_SIZE;
   const Vector2i CURSOR_CENTER;

   MouseCommands();
   Action get_action();
   Formation get_formation();
   void bind_cursor_to_action(Ref<Texture2D> image, Action action);
   void clear_units();
   void select_unit(Unit* unit);
   void set_command_icon(Ref<Texture2D> new_image);
   Ref<Unit::Command> new_command(Vector2 pos = { 0, 0 });

   void _process(double _dt) override;
   void _unhandled_input(const Ref<InputEvent>& event) override;
   /*-------------------------------------------------------*
    | NOTE: _finish_selection, _reset_selection_box, and    |
    | _update_selection_box are left unimplemented in favor |
    | of a gdscript implementation. Casting from Variant or |
    | Node2D to Unit and managing the selection box is far  |
    | easier in the editor.                                 |
    *-------------------------------------------------------*/
   virtual void _finish_selection() {};
   virtual void _reset_selection_box(Vector2 start) {};
   virtual void _update_selection_box(Vector2 start, Vector2 end) {};
protected:
   static void _bind_methods();
private:
   Action action = NONE;
   Formation formation = LINE;
   float path_length = 0;
   Vector2 selection_start;
   Vector2 selection_end;
   Vector<Vector2> waypoints;
   Vector<Ref<Unit::RadarSignature>> units;
   Vector<Ref<Unit::Command>> commands;
   Ref<Unit::Command> target;
   Ref<Texture2D> move_icon_image;
   Ref<Texture2D> cursor_bindings[NUM_OF_ACTIONS];

   /*-------------------------------------------------------*
    | MoveOrder is the custom comparator used to sort units |
    | and commands. Sorting is necessary to ensure units    |
    | move sensibly as to reduce travel distance and        |
    | intersections with other units.                       |
    *-------------------------------------------------------*/
   template<typename T> struct MoveOrder;
   typedef MoveOrder<Ref<Unit::RadarSignature>> UnitMoveOrder;
   typedef MoveOrder<Ref<Unit::Command>> CommandMoveOrder;

   Vector2 get_point(float parametric_dist);
   void begin_path();
   void update_path();
   void reset_selection();
   void update_selection();
   void update_target();
   void update_commands();
   void order_units_to_move();
   void stop_all_units();
   void set_action_with_cursor(Action new_action, Input& input);

   void choose_formation(Input& input);
   void choose_action(Input& input);
   void maybe_end_targeting(Input& input);
   void maybe_end_selection(Input& input);
   void maybe_end_move(Input& input);
};

template<typename T>
struct MouseCommands::MoveOrder {
   static Vector2 get_center(Vector<T> objects);
   Vector2 axis;
   Vector2 center;
   bool operator()(const T& A, const T& B) const;
};

VARIANT_ENUM_CAST(MouseCommands::Formation);
VARIANT_ENUM_CAST(MouseCommands::Action);

#endif // MOUSE_COMMANDS_HPP