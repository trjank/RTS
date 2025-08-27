#include "part.hpp"
// needed to use math primitives on visual studio compiler...
#define _USE_MATH_DEFINES
#include <cmath>
#include <math.h>
using namespace godot;

constexpr double PI_2 = 0.5 * Math_PI;

Part* PartData::new_blank_part() {
	return memnew(Part);
}


Part* Part::create_from(Ref<PartData> part_data) {
	if (part_data.is_null()) return nullptr;

	Part* part = part_data->new_blank_part();

	Vector2i size = PartData::to_world_vec( part_data->get_size() );

	part->data = part_data;
	part->image->set_texture( part_data->get_texture() );
	part->image->resize(size);
	part->hitbox->set_size(size);
	return part;
}
Part::Part() {
	collider->set_shape(hitbox);
	add_child(image, false, INTERNAL_MODE_FRONT);
	add_child(collider, false, INTERNAL_MODE_FRONT);
}
Rect2 Part::get_rect() const {
	return get_transform().xform( hitbox->get_rect() );
}
bool Part::is_flipped() const {
	return get_scale().y < 0;
}
PartData::Rotation Part::get_rotation_state() const {
	double rotation = get_rotation() + Math_PI * is_flipped();
	rotation = Math::snapped(rotation, PI_2);
	int quadrant = Math::posmod(rotation / PI_2, 4);
	return static_cast<PartData::Rotation>(quadrant);
}
Ref<PartData> Part::get_data() const {
	return data;
}
Part::InitStatus Part::_ship_init(const Ship& _parent_ship, int _part_id) {
	WARN_PRINT_ED("<Part::_ship_init> _ship_init does nothing for static parts");
	return OKAY_KEEP_PART;
}


PartGrouping* PartGrouping::clone() const {
	return Object::cast_to<PartGrouping>( duplicate(0) );
}
bool PartGrouping::is_dragging() const {
	return dragging;
}
bool PartGrouping::contains_mouse() const {
	return get_rect().has_point( get_local_mouse_position() );
}
void PartGrouping::flip_parts() {
	Vector2 scale = get_scale();

	scale.x = -scale.x;
	set_scale(scale);
	emit_signal("parts_flipped");
}
void PartGrouping::rotate_parts(int quarter_turns, float duration) {
	Ref<Tween> tween = create_tween();

	double start = Math::snapped(get_rotation(), PI_2);
	double end   = start + PI_2 * quarter_turns;

	tween->tween_property(this, "rotation", end, duration)->from(start);
	emit_signal("parts_rotated", quarter_turns, duration);
}
void PartGrouping::clear_parts() {
	Node* parent = get_parent();

	ERR_FAIL_NULL_MSG(parent, "<PartGrouping::clear_parts> PartGrouping has no parent");

	set_region_rect( {0.0, 0.0, 0.0, 0.0} );

	/*------------------------------------------------------|
	| Iterate backwards through the children because we are |
	| removing them. We will miss parts otherwise.          |
	|------------------------------------------------------*/
	for (int n = get_child_count() - 1; 0 <= n; --n) {
		get_child(n)->reparent(parent, true);
	}
}
void PartGrouping::delete_parts() {
	set_region_rect( {0.0, 0.0, 0.0, 0.0} );
	
	for (int n = 0; n < get_child_count(); ++n) {
		get_child(n)->queue_free();
	}
	emit_signal("parts_deleted");
}
bool PartGrouping::spawn_part(Ref<PartData> part_data) {
	Part* part = Part::create_from(part_data);

	if ( !part) return false;

	clear_parts();
	add_child(part);

	set_global_rotation(0.0);
	set_global_position( get_global_mouse_position() );
	set_region_rect( {TEXTURE_OFFSET, PartData::to_world_vec( part_data->get_size() )} );

	begin_dragging();
	return true;
}
void PartGrouping::select_parts(TypedArray<Node2D> selection, Rect2 region) {
	clear_parts();

	region.expand_to( grid_snap_floor(region.position) );
	region.expand_to( grid_snap_ceil( region.get_end() ) );

	set_global_rotation(0.0);
	set_global_position( region.get_center() );
	set_region_rect( {TEXTURE_OFFSET, region.size} );

	for (int n = 0; n < selection.size(); ++n) {
		add_part( Object::cast_to<Part>( selection[n] ) );
	}
}
void PartGrouping::snap_to_grid() {
	Rect2 rect = get_transform().xform( get_rect() );

	rect.position = rect.position.snapped(GRID_SQUARE);
	set_position( rect.get_center() );
}
void PartGrouping::_process(double _dt) {
	if (dragging) set_global_position(get_global_mouse_position() - mouse_offset);
}
void PartGrouping::_input(const Ref<InputEvent>& event) {
	if (event->is_action_released("delete"))
		delete_parts();
	if (event->is_action_pressed("select") && contains_mouse() && get_child_count() > 0)
		begin_dragging();

	if ( !dragging) return;

	if (event->is_action_released("select"))
		stop_dragging();
	if (event->is_action_pressed("flip"))
		flip_parts();
	if (event->is_action_pressed("rotate cw"))
		rotate_parts(CLOCKWISE);
	if (event->is_action_pressed("rotate ccw"))
		rotate_parts(COUNTER_CLOCKWISE);
}
void PartGrouping::begin_dragging() {
	dragging = true;

	mouse_offset = get_global_mouse_position() - get_global_position();
	emit_signal("dragging_started");
	Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_HIDDEN);
}
void PartGrouping::stop_dragging() {
	dragging = false;

	snap_to_grid();
	emit_signal("dragging_ended");
	Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_VISIBLE);
}
void PartGrouping::add_part(Part* part) {
	if (part) part->reparent(this);
}
Vector2 PartGrouping::grid_snap_floor(Vector2 xy) {
	return xy - xy.posmod(PartData::PX_PER_GRID_SQUARE);
}
Vector2 PartGrouping::grid_snap_ceil(Vector2 xy) {
	return grid_snap_floor(xy) + GRID_SQUARE;
}