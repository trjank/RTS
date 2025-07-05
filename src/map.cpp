#include "map.hpp"

using namespace godot;

Map::Result Map::generate(Ref<RandomNumberGenerator> rng, Node2D& parent, int max_depth) {
   return {0, 0.0, nullptr};
}


Ref<Map> MapLayer::get_submap() const {
   return submap;
}
int MapLayer::get_num_orbits() const {
   return num_orbits;
}
int MapLayer::get_num_sectors() const {
   return num_sectors;
}
double MapLayer::get_orbit_spacing() const {
   return orbit_spacing;
}
double MapLayer::get_start_distance() const {
   return start_distance;
}
double MapLayer::get_sector_size_radians() const {
   return sector_size_radians;
}
void MapLayer::set_submap(Ref<Map> new_submap) {
   submap = new_submap;
}
void MapLayer::set_num_orbits(int new_num_orbits) {
   num_orbits = Math::clamp(new_num_orbits, 0, ORBIT_LIMIT);
}
void MapLayer::set_num_sectors(int new_num_sectors) {
   num_sectors = Math::clamp(new_num_sectors, 0, SECTOR_LIMIT);
   sector_size_radians = Math_TAU / num_sectors;
}
void MapLayer::set_orbit_spacing(double new_orbit_spacing) {
   orbit_spacing = Math::max(new_orbit_spacing, 0.0);
}
void MapLayer::set_start_distance(double new_start_distance) {
   start_distance = Math::max(new_start_distance, 0.0);
}


TypedArray<String>& System::get_default_names() {
   static TypedArray<String> names = TypedArray<String>::make("Unnamed");
   return names;
}
TypedArray<Texture2D>& System::get_default_textures() {
   static TypedArray<Texture2D> textures = TypedArray<Texture2D>::make(nullptr);
   return textures;
}
void System::set_default_name(String new_default_name) {
   get_default_names()[0] = new_default_name;
}
void System::set_default_texture(Ref<Texture2D> new_default_texture) {
   get_default_textures()[0] = new_default_texture;
}
double System::get_energy_density() {
   return energy_density;
}
double System::get_alloy_density() {
   return alloy_density;
}
TypedArray<String> System::get_names() {
   return names.duplicate();
}
TypedArray<Texture2D> System::get_textures() {
   return textures;
}
NO_ERROR_CHECK Ref<MapLayer> System::get_layer(int index) {
   return layers[index];
}
void System::set_mass_range(double new_min_mass, double new_max_mass) {
   min_mass = new_min_mass;
   max_mass = Math::max(min_mass, new_max_mass);
}
void System::set_radius_range(double new_min_radius, double new_max_radius) {
   min_radius = new_min_radius;
   max_radius = Math::max(min_mass, new_max_radius);
}
void System::set_energy_density(double new_energy_density) {
   energy_density = Math::max(new_energy_density, 0.0);
}
void System::set_alloy_density(double new_alloy_density) {
   alloy_density = Math::max(new_alloy_density, 0.0);
}
void System::set_names(TypedArray<String> new_names) {
   names = new_names.is_empty() ? get_default_names() : new_names.duplicate();
}
void System::set_textures(TypedArray<Texture2D> new_textures) {
   textures = new_textures.is_empty() ? get_default_textures() : new_textures.duplicate();
}
int System::new_layer(Ref<MapLayer> layer) {
   if (layer.is_null()) return -1;

   layers.push_back(layer);
   return layers.size() - 1;
}
Celestial* System::create_correct_type() const {
   return memnew(Celestial);
}
Celestial* System::create_celestial(Ref<RandomNumberGenerator> rng) {
   double mass       = rng->randf_range(min_mass, max_mass);
   double radius     = rng->randf_range(min_radius, max_radius);
   int name_index    = rng->randi_range(0, names.size() - 1);
   int texture_index = rng->randi_range(0, textures.size() - 1);

   Celestial* celestial = create_correct_type();

   celestial->set_texture(textures[texture_index]);
   celestial->set_mass(mass);
   celestial->set_radius(radius);
   celestial->set_energy_density(energy_density);
   celestial->set_alloy_density(alloy_density);
   celestial->set_custom_name(names[name_index]);
   return celestial;
}
void System::create_sector(Ref<RandomNumberGenerator> rng, Orbit& orbit, Ref<MapLayer> layer, int sector_num, Result& out_result, int max_depth) {
   /*------------------------------------------------------|
   | Recursively generate the submap. For simplicity, we   |
   | make sectors equally spaced apart.                    |
   |------------------------------------------------------*/
   Result submap = layer->get_submap()->generate(rng, orbit, max_depth);
   double angle  = layer->get_sector_size_radians() * sector_num;
   orbit.set_angle(submap.map_root, angle);
   out_result.num_capturables += submap.num_capturables;
}
void System::create_orbit(Ref<RandomNumberGenerator> rng, Celestial& parent, Ref<MapLayer> layer, Result& out_result, int max_depth) {
   Orbit& orbit = *memnew(Orbit);
   parent.add_child( &orbit);
   orbit.set_distance(out_result.distance);
   orbit.orbit( &parent);

   for (int sector_num = 0; sector_num < layer->get_num_sectors(); ++sector_num) {
      create_sector(rng, orbit, layer, sector_num, out_result, max_depth);
   }
   /*------------------------------------------------------|
   | Make sure orbit_spacing is large enough to prevent    |
   | orbits from clipping into each other.                 |
   |------------------------------------------------------*/
   out_result.distance += layer->get_orbit_spacing();
}
void System::create_layer(Ref<RandomNumberGenerator> rng, Celestial& parent, Ref<MapLayer> layer, Result& out_result, int max_depth) {
   out_result.distance += layer->get_start_distance();
   for (int n = 0; n < layer->get_num_orbits(); ++n) {
      create_orbit(rng, parent, layer, out_result, max_depth);
   }
}
Map::Result System::generate(Ref<RandomNumberGenerator> rng, Node2D& parent, int max_depth) {
   Result result = {1, 0.0, nullptr};

   /*------------------------------------------------------|
   | max_depth helps prevent infinite recursions, which    |
   | can occur if you use the same MapLayer twice.         |
   |------------------------------------------------------*/
   if (unlikely( rng.is_null() || max_depth-- <= 0 )) return result;
   
   Celestial* map_root = create_celestial(rng);
   parent.add_child(result.map_root = map_root);
   for (const Ref<MapLayer> layer: layers) {
      create_layer(rng, *map_root, layer, result, max_depth);
   }
   return result;
}


Celestial* StarSystem::create_correct_type() const {
   return memnew(Star);
}