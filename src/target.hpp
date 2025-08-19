#ifndef TARGET_HPP
#define TARGET_HPP

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include "defaults.hpp"

namespace godot {

class Target: public RefCounted {
   GDCLASS(Target, RefCounted)
public:
   struct Prediction;

   Prediction predict_lazy(NEVER_NULL Ref<Target> target) const;
   Prediction predict(NEVER_NULL Ref<Target> target) const;
   Prediction predict_lazy_from(Vector2 position, double speed) const;
   Prediction predict_from(Vector2 position, double speed) const;
   virtual double get_speed() const = 0;
   virtual Vector2 get_position() const = 0;
   virtual Vector2 get_velocity() const = 0;
   virtual Vector2 get_future_position() const = 0;
   virtual void set_position(Vector2 new_position) = 0;
protected:
   static void _bind_methods();
};


struct Target::Prediction {
   bool will_intersect;
   double time_to_intersect;
   Vector2 intersection;
};


class StaticTarget: public Target {
   GDCLASS(StaticTarget, Target)
public:
   static Ref<StaticTarget> create_at(Vector2 position);

   double get_speed() const override;
   Vector2 get_position() const override;
   Vector2 get_velocity() const override;
   Vector2 get_future_position() const override;
   void set_position(Vector2 new_position) override;
protected:
   static void _bind_methods();
private:
   Vector2 position = {0.0, 0.0};
};

}

#endif // PREDICT_TARGET_HPP