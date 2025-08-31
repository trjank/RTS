#ifndef STAR_HPP
#define STAR_HPP

#include <godot_cpp/classes/shader_material.hpp>
#include <godot_cpp/classes/ref.hpp>
#include "celestial.hpp"

namespace godot {

class Star: public Celestial {
   GDCLASS(Star, Celestial)
public:
   static void set_star_shader(Ref<ShaderMaterial> shader);
   static void set_black_hole_shader(Ref<ShaderMaterial> shader);

   bool is_black_hole();
   bool can_capture() const override;
   void set_mass(double new_mass) override;
   void set_radius(double new_radius) override;
protected:
   static void _bind_methods();
private:
   static constexpr double STABILITY = 0.0001;

   static Ref<ShaderMaterial>& get_star_shader();
   static Ref<ShaderMaterial>& get_black_hole_shader();

   bool collapsed = false;

   void check_for_black_hole();
};

}

#endif // STAR_HPP