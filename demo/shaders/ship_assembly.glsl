#[compute]
#version 460

// Ensure this matches PartData::GRID_SQUARE_SIZE_PX
const int GRID_SQUARE_SIZE_PX = 32;
const int NULL_PART_ID = 0;
const vec2 CORRECTION = vec2(0.5, 0.5);

layout(local_size_x = GRID_SQUARE_SIZE_PX, local_size_y = GRID_SQUARE_SIZE_PX, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) restrict readonly uniform image2D atlas;
layout(rgba8, set = 0, binding = 1) restrict writeonly uniform image2D ship;

layout(set = 0, binding = 2, std430) restrict readonly buffer IndexGrid
{ int data[]; } index_grid;

layout(set = 0, binding = 3, std430) restrict readonly buffer RotationStates
{ int data[]; } rotation_states;

layout(set = 0, binding = 4, std430) restrict readonly buffer AtlasIDs
{ int data[]; } atlas_ids;

layout(set = 0, binding = 5, std430) restrict readonly buffer PartOffsets
{ vec2 data[]; } part_offsets;

layout(set = 0, binding = 6, std430) restrict readonly buffer AtlasOffsets
{ vec2 data[]; } atlas_offsets;

int bool_to_sign(bool value) {
   return 1 - 2 * int(value);
}

// RotationState enum as defined in ShipData.hpp:
// ROT_0_DEG           = 0
// ROT_90_DEG          = 1
// ROT_180_DEG         = 2
// ROT_270_DEG         = 3
// FLIPPED_ROT_0_DEG   = 4
// FLIPPED_ROT_90_DEG  = 5
// FLIPPED_ROT_180_DEG = 6
// FLIPPED_ROT_270_DEG = 7

void main() {
   // Get the section of the ship we are working on
   ivec2 grid_xy  = ivec2(gl_WorkGroupID.xy);
   int ship_width = int(gl_NumWorkGroups.x);
   int part_id    = index_grid.data[grid_xy.x + ship_width * grid_xy.y];
   if (part_id == NULL_PART_ID) return;
   // Get transform data for the current part
   int rotation = rotation_states.data[part_id];
   bool flipped = rotation >= 4;
   bool mod_180 = rotation % 2 == 1;
   bool mod_360 = rotation % 4 >= 2;
   // Find the correct (transformed) atlas position
   vec2 part_center = GRID_SQUARE_SIZE_PX * part_offsets.data[part_id];
   vec2 offset = vec2(gl_GlobalInvocationID.xy) + CORRECTION - part_center;
   offset.x *= bool_to_sign(flipped);
   offset   *= bool_to_sign(mod_360);
   if (mod_180) offset = vec2(-offset.y, offset.x);
   // Copy the correct part color without further processing
   ivec2 write_xy  = ivec2(gl_GlobalInvocationID.xy);
   ivec2 atlas_xy  = ivec2(atlas_offsets.data[atlas_ids.data[part_id]] + offset);
   vec4 part_color = imageLoad(atlas, atlas_xy);
   imageStore(ship, write_xy, part_color);
}