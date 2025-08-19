#ifndef MAP_HPP
#define MAP_HPP

#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "star.hpp"

namespace godot {

class Map: public RefCounted {
   GDCLASS(Map, RefCounted)
public:
   struct Result;

   virtual Result generate(Ref<RandomNumberGenerator> rng, Node2D& parent, int max_depth = 10);
protected:
   static void _bind_methods();
};


struct Map::Result {
   int num_capturables;
   double distance;
   UNSAFE_PTR Node2D* map_root;
};


class MapLayer: public RefCounted {
   GDCLASS(MapLayer, RefCounted)
public:
   static constexpr int SECTOR_LIMIT = 1000;
   static constexpr int ORBIT_LIMIT = 50;

   Ref<Map> get_submap() const;
   int count_orbits() const;
   int count_sectors() const;
   double get_orbit_spacing() const;
   double get_start_distance() const;
   double get_sector_size_radians() const;
   void set_submap(Ref<Map> new_submap);
   void set_num_orbits(int new_num_orbits);
   void set_num_sectors(int new_num_sectors);
   void set_orbit_spacing(double new_orbit_spacing);
   void set_start_distance(double new_start_distance);
protected:
   static void _bind_methods();
private:
   Ref<Map> submap;
   int num_orbits = 0;
   int num_sectors = 0;
   double orbit_spacing = 0.0;
   double start_distance = 0.0;
   double sector_size_radians = Math_TAU;
};


class System: public Map {
   GDCLASS(System, Map)
public:
   static void set_default_name(String new_default_name);
   static void set_default_texture(Ref<Texture2D> new_default_texture);

   double get_energy_density();
   double get_alloy_density();
   NEVER_EMPTY TypedArray<String> get_names();
   NEVER_EMPTY TypedArray<Texture2D> get_textures();
   NO_ERROR_CHECK Ref<MapLayer> get_layer(int index);
   void set_mass_range(double new_min_mass, double new_max_mass);
   void set_radius_range(double new_min_radius, double new_max_radius);
   void set_energy_density(double new_energy_density);
   void set_alloy_density(double new_alloy_density);
   void set_names(TypedArray<String> new_names);
   void set_textures(TypedArray<Texture2D> new_textures);
   int new_layer(Ref<MapLayer> layer);
   Result generate(Ref<RandomNumberGenerator> rng, Node2D& parent, int max_depth = 10) override;
protected:
   static void _bind_methods();

   Vector<NEVER_NULL Ref<MapLayer>> layers;
   NEVER_EMPTY TypedArray<String> names = get_default_names();
   NEVER_EMPTY TypedArray<Texture2D> textures = get_default_textures();

   virtual Celestial* create_correct_type() const;
   Celestial* create_celestial(Ref<RandomNumberGenerator> rng);
private:
   static NEVER_EMPTY TypedArray<String>& get_default_names();
   static NEVER_EMPTY TypedArray<Texture2D>& get_default_textures();

   double min_mass = 0.0;
   double max_mass = 0.0;
   double min_radius = 0.0;
   double max_radius = 0.0;
   double energy_density = 0.0;
   double alloy_density = 0.0;

   void create_sector(Ref<RandomNumberGenerator> rng, Orbit& orbit, Ref<MapLayer> layer, int sector_num, Result& out_result, int max_depth);
   void create_orbit(Ref<RandomNumberGenerator> rng, Celestial& parent, Ref<MapLayer> layer, Result& out_result, int max_depth);
   void create_layer(Ref<RandomNumberGenerator> rng, Celestial& parent, Ref<MapLayer> layer, Result& out_result, int max_depth);
};


class StarSystem: public System {
   GDCLASS(StarSystem, System)
protected:
   static void _bind_methods();
   Celestial* create_correct_type() const override;
};

}

#endif // MAP_HPP