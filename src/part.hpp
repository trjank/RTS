#ifndef PART_HPP
#define PART_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/vector2i.hpp>
#include <godot_cpp/classes/static_body2d.hpp>
#include <godot_cpp/classes/node2d.hpp>

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                  mouse_commands.hpp                   |
|                                                       |
*------------------------------------------------------*/

using godot::Ref;
using godot::RefCounted;
using godot::String;
using godot::Vector2i;
using godot::StaticBody2D;
using godot::Node2D;

struct PartData: public RefCounted {
   int ID;
   String name;
   Vector2i size;
   String to_string();
};

class Part: public StaticBody2D {
   Ref<PartData> data;
   String to_string();
};

class PartGroup: public Node2D {

};

#endif // PART_HPP