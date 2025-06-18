#include "part.hpp"

using namespace godot;

Part::Part() {
	hitbox.instantiate();
	add_child(shape = memnew(CollisionShape2D));
	add_child(image = memnew(ResizableSprite2D));
	shape->set_shape(hitbox);
}
Ref<PartData> Part::get_data() {
	return data;
}
bool Part::keep_as_node() {
	return false;
}
void Part::set_data(Ref<PartData> part_data) {
	ERR_FAIL_COND(part_data.is_null());

	Vector2i size = part_data->get_size_px();
	image->set_texture(part_data->get_texture());
	image->resize_scaled(size);
	hitbox->set_size(size);
	data = part_data;
}
Rect2 Part::get_global_rect() {
	return image->get_global_transform().xform(image->get_rect());
}


void PartGrouping::set_mirroring(bool mirroring) {
	this->mirroring = mirroring;
}
bool PartGrouping::get_mirroring() {
	return mirroring;
}
bool PartGrouping::is_dragging() {
	return dragging;
}
bool PartGrouping::contains_mouse() {
	return get_rect().has_point(get_local_mouse_position());
}
void PartGrouping::clear_parts() {
	Node* parent = get_parent();
	for (Part* part: parts) {
		part->reparent(parent);
	}
	parts.clear();
}
void PartGrouping::delete_parts() {
	for (Part* part: parts) {
		part->queue_free();
	}
	parts.clear();
	region = {0.0, 0.0, 0.0, 0.0};
	update_region();
	if (mirrored) mirrored->delete_parts();
}
void PartGrouping::spawn_part(Ref<PartData> part_data) {
	ERR_FAIL_COND(part_data.is_null());

	Part* part = memnew(Part);
	get_parent()->add_child(part);
	part->set_data(part_data);
	part->set_global_position(get_global_mouse_position());
	clear_parts();
	add_part(part);
	update_region();
}
void PartGrouping::select_parts(TypedArray<Node2D> selection) {
	clear_parts();
	region = {0.0, 0.0, 0.0, 0.0};
	for (int n = 0; n < selection.size(); ++n) {
		add_part(Object::cast_to<Part>( selection[n] ));
	}
	set_rotation(0.0);
	update_region();
	for (Part* part: parts) {
		part->reparent(this);
	}
}
void PartGrouping::add_part(Part* part) {
	if (part == nullptr) return;

	Rect2 rect = part->get_global_rect();
	region = parts.is_empty() ? rect : region.merge(rect);
	parts.push_back(part);
}
void PartGrouping::update_region() {
	resize_region(region.size);
	set_global_position(region.get_center());
}
void PartGrouping::rotate_smoothly(int quarter_turns, float duration) {
	Ref<Tween> tween = create_tween();
	float start = Math::snapped(get_rotation(), M_PI_2);
	float end = start + M_PI_2 * quarter_turns;
	tween->tween_property(this, "rotation", end, duration)->from(start);
	if (mirrored) mirrored->rotate_smoothly(-quarter_turns, duration);
}
void PartGrouping::create_mirrored() {
	if ( !mirroring) return;

	if (mirrored) mirrored->queue_free();
	mirrored = Object::cast_to<PartGrouping>(duplicate());
	mirrored->set_scale( {-1.0, 1.0} );
	get_parent()->add_child(mirrored);
	reposition_mirrored();
}
void PartGrouping::reposition_mirrored() {
	if ( !mirrored) return;

	Vector2 position = get_position();
	position.x = -position.x;
	mirrored->set_position(position);
}
void PartGrouping::_process(double _dt) {
	if ( !dragging) return;

	set_global_position(get_global_mouse_position() - mouse_offset);
	reposition_mirrored();
}
void PartGrouping::_unhandled_input(const Ref<InputEvent>& event) {
	if (event->is_action_released("delete"))
		delete_parts();
	if (event->is_action_pressed("select") && contains_mouse()) {
		mouse_offset = get_global_mouse_position() - get_global_position();
		create_mirrored();
		dragging = true;
	}
	if ( !dragging) return;
	if (event->is_action_released("select"))
		dragging = false;
	if (event->is_action_pressed("rotate cw"))
		rotate_smoothly(CLOCKWISE);
	if (event->is_action_pressed("rotate ccw"))
		rotate_smoothly(COUNTER_CLOCKWISE);
}