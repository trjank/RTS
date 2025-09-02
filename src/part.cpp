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
	part->image->set_texture( part_data->get_texture() );
	part->image->resize( part_data->get_size_px() );
	part->hitbox->set_size( part_data->get_size_px() );
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
Rect2i Part::get_grid_rect() const {
	Rect2i rect = get_rect();

	rect.position /= PartData::PX_PER_GRID_SQUARE;
	rect.size     /= PartData::PX_PER_GRID_SQUARE;
	return rect;
}
bool Part::is_flipped() const {
	/*------------------------------------------------------|
   | While we are flipping horizontally, Godot only stores |
	| negative scales in the y direction.                   |
   |------------------------------------------------------*/
	return get_scale().y < 0;
}
PartData::Orientation Part::get_orientation() const {
	bool flipped = is_flipped();
	double theta = Math::snapped(get_true_rotation(flipped), PI_2);

	return PartData::to_orientation(theta / PI_2, flipped);
}
void Part::set_orientation(PartData::Orientation new_orientation) {
	Vector2 scale = get_scale();
	scale.x = Math::abs(scale.x);
	scale.x = PartData::is_flipped(new_orientation) ? -scale.x : scale.x;
	set_scale(scale);
	set_rotation(PartData::get_rotation(new_orientation) * PI_2);
}
void Part::snap_to_grid() {
	const Vector2 GRID_SQUARE_SIZE = PartData::PX_PER_GRID_SQUARE * Vector2(1.0, 1.0);
	set_position( get_position().snapped(GRID_SQUARE_SIZE) );
}
Ref<PartData> Part::get_data() const {
	return data;
}
Part::InitStatus Part::_ship_init(const Ship& _parent_ship, int _part_id) {
	WARN_PRINT_ED("<Part::_ship_init> _ship_init does nothing for static parts");
	return OKAY_KEEP_PART;
}
double Part::get_true_rotation(bool flipped) const {
	// x flip is equivalent to y flip with 180 degree rotation
	return get_rotation() + Math_PI * is_flipped();
}


bool PartGrouping::contains_mouse() const {
	return get_rect().has_point( get_local_mouse_position() );
}
void PartGrouping::resize(Vector2 new_size) {
	Rect2 rect = get_region_rect();

	rect.size = new_size;
	set_region_rect(rect);
}
void PartGrouping::flip_parts() {
	Vector2 scale = get_scale();

	scale.x *= -1;
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

	resize( {0.0, 0.0} );

	/*------------------------------------------------------|
	| Iterate backwards through the children because we are |
	| removing them. We will miss parts otherwise.          |
	|------------------------------------------------------*/
	for (int n = get_child_count() - 1; 0 <= n; --n) {
		get_child(n)->reparent(parent, true);
	}
}
void PartGrouping::delete_parts() {
	resize( {0.0, 0.0} );
	
	for (int n = 0; n < get_child_count(); ++n) {
		get_child(n)->queue_free();
	}
	emit_signal("parts_deleted");
}
bool PartGrouping::spawn_part_at_mouse(Ref<PartData> part_data) {
	return spawn_part_at(get_global_mouse_position(), part_data);
}
bool PartGrouping::spawn_part_at(Vector2 position, Ref<PartData> part_data) {
	Part* part = Part::create_from(part_data);

	if ( !part) return false;

	clear_parts();
	add_child(part);

	resize( part_data->get_size_px() );
	set_global_position(position);
	set_global_rotation(0.0);
	return true;
}
void PartGrouping::select_parts(TypedArray<Node2D> selection, Rect2 region) {
	clear_parts();

	region.expand_to( grid_snap_floor(region.position) );
	region.expand_to( grid_snap_ceil( region.get_end() ) );

	set_global_rotation(0.0);
	set_global_position( region.get_center() );
	resize(region.size);

	for (int n = 0; n < selection.size(); ++n) {
		add_part( Object::cast_to<Part>( selection[n] ) );
	}
}
void PartGrouping::snap_to_grid() {
	Rect2 rect = get_transform().xform( get_rect() );

	rect.position = rect.position.snapped(GRID_SQUARE);
	set_position( rect.get_center() );
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