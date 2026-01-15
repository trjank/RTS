#[compute]
#version 460

const int TILE_SIZE = 32;
const int ATLAS_LOD = 0;

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

layout(set = 0, binding = 0) uniform sampler2D atlas;
layout(rgba8, set = 0, binding = 1) restrict writeonly uniform image2D ship;

struct Part {
   ivec2 top_left_corner;
   ivec2 atlas_offset;
   // ivec2 size;
   // uint rotation;
};
layout(std430, set = 0, binding = 2) readonly buffer Parts { Part parts[]; } parts;
layout(std430, set = 0, binding = 3) readonly buffer Grid { int ids[]; } grid;

void main() {
   ivec2 px_xy = ivec2(gl_GlobalInvocationID.xy);
   ivec2 tile_xy = px_xy / TILE_SIZE;
   int px_width = int(gl_NumWorkGroups.x);
   int part_id = grid.ids[px_xy.x + px_width * px_xy.y];
   Part part = parts.parts[part_id];
   ivec2 dx = px_xy - part.top_left_corner;
   // TODO: apply rotation and flip
   ivec2 atlas_xy = part.atlas_offset + dx;
   imageStore(ship, px_xy, texelFetch(atlas, atlas_xy, ATLAS_LOD) );
}