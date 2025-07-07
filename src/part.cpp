#include "part.hpp"

using namespace godot;

constexpr double PI_2 = 0.5 * Math_PI;

Part* PartData::new_blank_part() {
	return memnew(Part);
}


Part* Part::create_from(Ref<PartData> part_data) {
	if (part_data.is_null()) return nullptr;

	Part* part = part_data->new_blank_part();

	part->data = part_data;
	part->create_hitbox();
	part->create_image();
	return part;
}
Ref<PartData> Part::get_data() const {
	return data;
}
void Part::_ship_init(const Ship& parent_ship, int part_id) {
	/*------------------------------------------------------|
	| This will never run for static parts. This is for     |
	| unique parts, which become actual nodes on the ship.  |
	|------------------------------------------------------*/
}
void Part::create_image() {
	ResizableSprite2D* image = memnew(ResizableSprite2D);

	add_child(image, false, INTERNAL_MODE_FRONT);
	image->set_texture( data->get_texture() );
	image->resize( data->get_size_px() );
}
void Part::create_hitbox() {
	CollisionShape2D* shape = memnew(CollisionShape2D);

	add_child(shape, false, INTERNAL_MODE_FRONT);
	hitbox->set_size( data->get_size_px() );
	shape->set_shape(hitbox);
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
	set_scale( { -get_scale().x, 1.0} );
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

	ERR_FAIL_NULL_MSG(parent,
	"<PartGrouping> PartGrouping has no parent (failed to clear parts)");

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

	set_global_position( get_global_mouse_position() );
	set_global_rotation(0.0);
	set_region_rect( {TEXTURE_OFFSET, part_data->get_size_px()} );

	begin_dragging();
	return true;
}
void PartGrouping::select_parts(TypedArray<Node2D> selection, Rect2 region) {
	clear_parts();

	region.expand_to( grid_snap_floor(region.position) );
	region.expand_to( grid_snap_ceil( region.get_end() ) );

	set_global_position( region.get_center() );
	set_global_rotation(0.0);
	set_region_rect( {TEXTURE_OFFSET, region.size} );
	/*------------------------------------------------------|
	| Non-parts get casted to nullptr. We can easily filter |
	| out nodes that are not parts.                         |
	|------------------------------------------------------*/
	for (int n = 0; n < selection.size(); ++n) {
		add_part( Object::cast_to<Part>( selection[n] ) );
	}
}
void PartGrouping::snap_to_grid() {
	Rect2 rect    = get_transform().xform( get_rect() );
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
Vector2 PartGrouping::grid_snap_floor(Vector2 vector) {
	return vector - vector.posmod(PartData::PX_PER_GRID_SQUARE);
}
Vector2 PartGrouping::grid_snap_ceil(Vector2 vector) {
	return grid_snap_floor(vector) + GRID_SQUARE;
}