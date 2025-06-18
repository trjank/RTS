#ifndef MAP_HPP
#define MAP_HPP

#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/dir_access.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "star.hpp"

namespace godot {

typedef RandomNumberGenerator RNG;

class Map: public RefCounted {
   GDCLASS(Map, RefCounted)
public:
   static constexpr int STANDARD_DEPTH_LIMIT = 10;
   virtual Node2D* generate(Ref<RNG> rng, Node2D* parent, int max_depth);
   double get_distance();
protected:
   double distance = 0.0;
   static void _bind_methods();
};

class MapLayer: public RefCounted {
   GDCLASS(MapLayer, RefCounted)
public:
   static constexpr int SECTOR_LIMIT = 1000;
   static constexpr int ORBIT_LIMIT = 50;
   Ref<Map> get_preset();
   int get_num_orbits();
   int get_num_sectors();
   double get_orbit_spacing();
   double get_start_distance();
   void set_preset(Ref<Map> new_preset);
   void set_num_orbits(int new_num_orbits);
   void set_num_sectors(int new_num_sectors);
   void set_orbit_spacing(double new_orbit_spacing);
   void set_start_distance(double new_start_distance);
protected:
   static void _bind_methods();
private:
   Ref<Map> preset;
   int num_orbits = 0;
   int num_sectors = 0;
   double orbit_spacing = 0.0;
   double start_distance = 0.0;
};

class System: public Map {
   GDCLASS(System, Map)
public:
   double get_energy_density();
   double get_alloy_density();
   TypedArray<String> get_names();
   TypedArray<Texture2D> get_textures();
   Ref<MapLayer> get_layer(int index);
   void set_mass_range(double new_min_mass, double new_max_mass);
   void set_radius_range(double new_min_radius, double new_max_radius);
   void set_energy_density(double new_energy_density);
   void set_alloy_density(double new_alloy_density);
   void set_names(TypedArray<String> new_names);
   void set_textures(TypedArray<Texture2D> new_textures);
   void load_names_from_file(String path);
   void load_textures_from_folder(String path);
   int new_layer(Ref<MapLayer> layer);
   Node2D* generate(Ref<RNG> rng, Node2D* parent, int max_depth) override;
protected:
   static void _bind_methods();
   Vector<Ref<MapLayer>> layers;
   TypedArray<String> names;
   TypedArray<Texture2D> textures;
   virtual Celestial* create_correct_type();
   Celestial* create_celestial(Ref<RNG> rng);
   void create_orbit(Ref<RNG> rng, Celestial* parent, Ref<MapLayer> layer_num, int max_depth);
   void create_layer(Ref<RNG> rng, Celestial* parent, int layer, int max_depth);
private:
   double min_mass = 0.0;
   double max_mass = 0.0;
   double min_radius = 0.0;
   double max_radius = 0.0;
   double energy_density = 0.0;
   double alloy_density = 0.0;
};

class StarSystem: public System {
   GDCLASS(StarSystem, System)
protected:
   static void _bind_methods();
   Celestial* create_correct_type() override;
};

}

#endif // MAP_HPP