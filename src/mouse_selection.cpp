#include "mouse_selection.hpp"

using namespace godot;

MouseSelection::MouseSelection() {
   CollisionShape2D* selection_rect = memnew(CollisionShape2D);
   shape.instantiate();
   selection_rect->set_shape(shape);
   add_child(selection_rect);
}
bool MouseSelection::is_enabled() {
   return enabled;
}
Color MouseSelection::get_color() {
   return color;
}
TypedArray<Node2D> MouseSelection::get_selected() {
   return selected;
}
void MouseSelection::set_enabled(bool enable) {
   enabled = enable;
   if ( !enabled) stop_selection();
}
void MouseSelection::set_color(Color new_color) {
   color = new_color;
   color.a = OPACITY;
}
void MouseSelection::set_visibility(Input::MouseMode visibility) {
   Input::get_singleton()->set_mouse_mode(visibility);
}
void MouseSelection::begin_selection() {
   for (int n = 0; n < selected.size(); ++n) {
      selected[n].call("on_deselect");
   }
   selected.clear();
   selecting = true;
   resize( {0.0, 0.0} );
   start_pos = get_global_mouse_position();
   set_visibility(Input::MOUSE_MODE_HIDDEN);
   emit_signal("selection_started");
}
void MouseSelection::stop_selection() {
   resize( {0.0, 0.0} );
   selecting = false;
   set_visibility(Input::MOUSE_MODE_VISIBLE);
}
void MouseSelection::finish_selection() {
   selected = get_overlapping_bodies();
   for (int n = 0; n < selected.size(); ++n) {
      selected[n].call("on_select");
   }
   stop_selection();
   emit_signal("selection_ended", selected);
}
void MouseSelection::resize(Vector2 new_size) {
   shape->set_size(new_size);
   queue_redraw();
}
void MouseSelection::_draw() {
   draw_rect(shape->get_rect(), color);
}
void MouseSelection::_unhandled_input(const Ref<InputEvent>& event) {
   if ( !enabled) return;
   if (event->is_action_pressed("select"))
      begin_selection();
   if (event->is_action_released("select") && selecting)
      finish_selection();
}
void MouseSelection::_process(double _dt) {
   if ( !enabled || !selecting) return;

   Vector2 end_pos = get_global_mouse_position();
   set_global_position(0.5 * (start_pos + end_pos));
   resize((end_pos - start_pos).abs());
}