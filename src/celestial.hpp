#ifndef CELESTIAL_HPP
#define CELESTIAL_HPP

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/circle_shape2d.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/classes/label.hpp>
#include "capturable.hpp"
#include "resizable_sprite_2d.hpp"
#include "player.hpp"

namespace godot {

constexpr double GRAVITATIONAL_CONSTANT = 1000.0;

class Celestial;

class Orbit: public Node2D {
   GDCLASS(Orbit, Node2D)
public:
   static constexpr int NUM_SEGMENTS = 100;
   static constexpr double THICKNESS = 1.0;
   static constexpr double MIN_DISTANCE = 0.1;
   static constexpr double MIN_TIME_SCALE = 0.0;
   static constexpr double MAX_TIME_SCALE = 5.0;
   static inline Color COLOR = {1.0, 1.0, 1.0, 0.3};
   static double get_time_scale();
   static void set_time_scale(double new_scale);
   double get_angular_velocity();
   double get_distance();
   void set_distance(double new_distance);
   void set_path_visibility(bool visible);
   void set_angle(Node2D* orbiter, double angle);
   void orbit(Celestial* celestial);
   void add(Node2D* orbiter, double angle = 0.0);
   void _physics_process(double dt) override;
   void _draw() override;
protected:
   static void _bind_methods();
private:
   static double time_scale;
   bool path_visible = true;
   double distance = MIN_DISTANCE;
   Celestial* orbiting = nullptr;
   void fix_distance(Node2D* orbiter);
};

class Celestial: public Node2D, public Capturable {
   GDCLASS(Celestial, Node2D)
public:
   static constexpr int TEXT_SIZE = 50;
   static constexpr int DISPLAY_DECIMAL_PLACES = 1;
   static constexpr float LABEL_OFFSET = 100.0;
   Celestial();
   bool can_capture() override;
   double get_mass();
   double get_radius();
   double get_angular_velocity();
   double get_alloy_per_sec() override;
   double get_energy_per_sec() override;
   String get_custom_name();
   Ref<Texture2D> get_texture();
   void set_alloy_density(double density);
   void set_energy_density(double density);
   virtual void set_mass(double new_mass);
   virtual void set_radius(double new_radius);
   void set_custom_name(String new_custom_name);
   void set_texture(Ref<Texture2D> new_texture);
   void set_angular_velocity(double new_angular_velocity);
   void set_angular_offset(double angle);
   void _physics_process(double dt) override;
   void _draw() override;
   void _ready() override;
protected:
   static void _bind_methods();
private:
   static constexpr int NUM_SEGMENTS = 100;
   static constexpr double THICKNESS = 10.0;
   static double alloy_abundance;
   static double energy_abundance;
   double alloy_density = 0.0;
   double energy_density = 0.0;
   double mass = 0.0;
   double radius = 0.0;
   double angular_velocity = 0.0;
   double surface_area = 0.0;
   double capture_progress = 0.0;
   Area2D* capture_zone;
   Label* label;
   ResizableSprite2D* image;
   Ref<CircleShape2D> hitbox;
   Ref<Team> contestor;
   Ref<Team> owner;
   String custom_name;
   void reposition_label();
   void update_label_text();
   friend class Orbit;
};

}

#endif // CELESTIAL_HPP