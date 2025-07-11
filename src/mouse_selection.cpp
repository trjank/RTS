#include "mouse_selection.hpp"

using namespace godot;

MouseSelection::MouseSelection() {
   CollisionShape2D* collision_shape = memnew(CollisionShape2D);

   collision_shape->set_shape(shape);
   add_child(collision_shape, false, INTERNAL_MODE_FRONT);
}
bool MouseSelection::is_enabled() const {
   return enabled;
}
bool MouseSelection::is_selecting() const {
   return selecting;
}
Color MouseSelection::get_color() const {
   return color;
}
Rect2 MouseSelection::get_region() const {
   return region.abs();
}
TypedArray<Node2D> MouseSelection::get_selected() {
   return selected;
}
void MouseSelection::set_enabled(bool enable) {
   enabled = enable;
   if ( !enable) stop_selection();
}
void MouseSelection::set_color(Color new_color) {
   color = new_color;
}
void MouseSelection::_draw() {
   draw_rect(shape->get_rect(), color);
}
void MouseSelection::_process(double _dt) {
   if ( !enabled || !selecting) return;

   region.set_end( get_global_mouse_position() );
   set_global_position( region.get_center() );
   resize_hitbox();
}
void MouseSelection::_unhandled_input(const Ref<InputEvent>& event) {
   if ( !enabled) return;

   if (event->is_action_pressed("select"))
      begin_selection();
   if (event->is_action_released("select") && selecting)
      finish_selection();
}
void MouseSelection::resize_hitbox() {
   shape->set_size( region.size.abs() );
   queue_redraw();
}
void MouseSelection::begin_selection() {
   selecting = true;

   region.position = get_global_mouse_position();
   selected.clear();
   resize_hitbox();
   emit_signal("selection_started");
   Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_HIDDEN);
}
void MouseSelection::stop_selection() {
   selecting = false;

   region.size = {0.0, 0.0};
   resize_hitbox();
   Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_VISIBLE);
}
void MouseSelection::finish_selection() {
   Rect2 final_region = region.abs();
   selected = get_overlapping_bodies();
   stop_selection();
   emit_signal("selection_ended", selected, final_region);
}