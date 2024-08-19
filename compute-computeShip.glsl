#[compute]
#version 460

// Invocations in the (x, y, z) dimension
layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer indexBuffer{
    int data[];
}
index_buffer;

layout(set = 0, binding = 1, std430) restrict buffer rotationBuffer{
    int data[];
}
rotation_buffer;

layout(rgba8, set = 0, binding = 2) restrict readonly uniform image2D textureAtlas;

layout(rgba8, set = 0, binding = 3) restrict uniform image2D ship;


// The code we want to execute in each invocation
void main() {
    int tileWidth = int(gl_WorkGroupSize.x);
    ivec2 coords = ivec2(gl_GlobalInvocationID.xy);
    uint i = gl_WorkGroupID.x+gl_WorkGroupID.y*(imageSize(ship).x/tileWidth);
    int index =  index_buffer.data[i];
    int rotation = rotation_buffer.data[i];
    ivec2 origt = (1-abs(sign(rotation)))*ivec2(gl_LocalInvocationID.xy);
    ivec2 onet = (1-abs(sign(rotation-1)))*ivec2(gl_LocalInvocationID.y,tileWidth-gl_LocalInvocationID.x);
    ivec2 twot = (1-abs(sign(rotation-2)))*ivec2(tileWidth-gl_LocalInvocationID.x,tileWidth-gl_LocalInvocationID.y);
    ivec2 threet = (1-abs(sign(rotation-3)))*ivec2(tileWidth-gl_LocalInvocationID.y,gl_LocalInvocationID.x);
    ivec2 rotatedCoords = origt+onet+twot+threet;
    ivec2 alteredCoords = ivec2(rotatedCoords.x+(index%tileWidth)*tileWidth,rotatedCoords.y+(index/tileWidth)*tileWidth);
    vec4 color = imageLoad(textureAtlas, alteredCoords);
    //vec4 color = vec4(1,1,1,1);
    imageStore(ship, coords, color);
}