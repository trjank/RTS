#include "map.hpp"

using namespace godot;

double Map::get_distance() {
   return distance;
}
Node2D* Map::generate(Ref<RNG> rng, Node2D* parent, int max_depth) {
   return nullptr;
}


Ref<Map> MapLayer::get_preset() {
   return preset;
}
int MapLayer::get_num_orbits() {
   return num_orbits;
}
int MapLayer::get_num_sectors() {
   return num_sectors;
}
double MapLayer::get_orbit_spacing() {
   return orbit_spacing;
}
double MapLayer::get_start_distance() {
   return start_distance;
}
void MapLayer::set_preset(Ref<Map> new_preset) {
   preset = new_preset;
}
void MapLayer::set_num_orbits(int new_num_orbits) {
   num_orbits = Math::clamp(new_num_orbits, 0, ORBIT_LIMIT);
}
void MapLayer::set_num_sectors(int new_num_sectors) {
   num_sectors = Math::clamp(new_num_sectors, 0, SECTOR_LIMIT);
}
void MapLayer::set_orbit_spacing(double new_orbit_spacing) {
   orbit_spacing = Math::max(new_orbit_spacing, 0.0);
}
void MapLayer::set_start_distance(double new_start_distance) {
   start_distance = Math::max(new_start_distance, 0.0);
}


double System::get_energy_density() {
   return energy_density;
}
double System::get_alloy_density() {
   return alloy_density;
}
TypedArray<String> System::get_names() {
   return names;
}
TypedArray<Texture2D> System::get_textures() {
   return textures;
}
Ref<MapLayer> System::get_layer(int index) {
   return layers[index];
}
void System::set_mass_range(double new_min_mass, double new_max_mass) {
   ERR_FAIL_COND(new_min_mass > new_max_mass);

   min_mass = new_min_mass;
   max_mass = new_max_mass;
}
void System::set_radius_range(double new_min_radius, double new_max_radius) {
   ERR_FAIL_COND(new_min_radius > new_max_radius);

   min_radius = new_min_radius;
   max_radius = new_max_radius;
}
void System::set_energy_density(double new_energy_density) {
   energy_density = Math::max(new_energy_density, 0.0);
}
void System::set_alloy_density(double new_alloy_density) {
   alloy_density = Math::max(new_alloy_density, 0.0);
}
void System::set_names(TypedArray<String> new_names) {
   names = new_names;
}
void System::set_textures(TypedArray<Texture2D> new_textures) {
   textures = new_textures;
}
void System::load_names_from_file(String path) {
   ERR_FAIL_COND( !path.ends_with(".txt"));

   Ref<FileAccess> file = FileAccess::open(path, FileAccess::READ);

   ERR_FAIL_COND(file.is_null());

   names.clear();
   while ( !file->eof_reached()) {
      names.push_back(file->get_line());
   }
}
void System::load_textures_from_folder(String path) {
   Ref<DirAccess> directory = DirAccess::open(path);

   ERR_FAIL_COND(directory.is_null());

   ResourceLoader* loader = ResourceLoader::get_singleton();
   if ( !path.ends_with("/")) path += "/";
   for (String name: directory->get_files()) {
      if (name.ends_with(".import")) continue;
      textures.push_back(loader->load(path + name));
   }
}
int System::new_layer(Ref<MapLayer> layer) {
   layers.push_back(layer);
   return layers.size() - 1;
}
Celestial* System::create_correct_type() {
   return memnew(Celestial);
}
Celestial* System::create_celestial(Ref<RNG> rng) {
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
void System::create_orbit(Ref<RNG> rng, Celestial* parent, Ref<MapLayer> layer, int max_depth) {
   Orbit* orbit = memnew(Orbit);
   parent->add_child(orbit);
   orbit->set_distance(distance);
   orbit->orbit(parent);

   int num_sectors = layer->get_num_sectors();
   for (int sector = 0; sector < num_sectors; ++sector) {
      double angle    = sector * Math_TAU / num_sectors;
      Node2D* orbiter = layer->get_preset()->generate(rng, orbit, max_depth);
      orbit->set_angle(orbiter, angle);
   }
   distance += layer->get_orbit_spacing();
}
void System::create_layer(Ref<RNG> rng, Celestial* parent, int layer_num, int max_depth) {
   Ref<MapLayer> layer = layers[layer_num];
   distance += layer->get_start_distance();
   for (int n = 0; n < layer->get_num_orbits(); ++n) {
      create_orbit(rng, parent, layer, max_depth);
   }
}
Node2D* System::generate(Ref<RNG> rng, Node2D* parent, int max_depth) {
   if (rng.is_null() || !parent || max_depth-- <= 0) return nullptr;
   
   Celestial* celestial = create_celestial(rng);
   parent->add_child(celestial);
   distance = 0.0;
   for (int layer = 0; layer < layers.size(); ++layer) {
      create_layer(rng, celestial, layer, max_depth);
   }
   return celestial;
}


Celestial* StarSystem::create_correct_type() {
   return memnew(Star);
}