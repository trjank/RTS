#ifndef MOUSE_COMMANDS_HPP
#define MOUSE_COMMANDS_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "unit.hpp"

using godot::Ref;
using godot::Vector2;
using godot::Node2D;
using godot::InputEvent;
using godot::Vector;

class MouseCommands: public Node2D {
   GDCLASS(MouseCommands, Node)
public:
   enum Mode { MOVE, FOLLOW, TRACK, FIRE, MANUAL_FIRE };
   enum Formation { LINE = 2, V = 3, SMOOTH = 10, PRECISE = 30 };
   static const int MAX_LINE_WAYPOINTS = 30;
   static const int MAX_UNITS_SELECTED = 10;
   void set_mode(Mode new_mode);
   void set_formation(Formation new_formation);
   void _unhandled_input(const Ref<InputEvent>& event) override;
protected:
   float horizontal_priority = 0.1;
   float path_length = 0;
   Mode mode = MOVE;
   Formation formation = LINE;
   Vector<Ref<Unit::RadarSignature>> units;
   Vector<Ref<Unit::Command>> commands;
   Vector<Vector2> waypoints;
   void create_waypoints();
   void order_units_to_move();
   void begin_path_at(Vector2 start_pos);
   void move_path_end_to(Vector2 new_pos);
   void update_commands();
   Vector2 get_point(float parametric_dist);
   static void _bind_methods();
};

#endif