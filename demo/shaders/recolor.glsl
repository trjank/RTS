#[compute]
#version 460

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) restrict uniform image2D image;

layout(set = 0, binding = 1) restrict readonly buffer Colors {
   vec4 recolor;
} colors;

const float RECOLOR_STRENGTH = 2.0;

void main() {
   ivec2 xy = ivec2(gl_GlobalInvocationID.xy);
   vec4 color = imageLoad(image, xy);
   // NOTE: These definitions are not based on HSL
   float luminosity = (color.r + color.g + color.b) / 3;
   float saturation = length(color.xyz - vec3(luminosity));
   saturation = min(1.0, saturation * RECOLOR_STRENGTH);
   // Low saturation (grayscale) preserves the original color
   // High saturation introduces more of the recolor color
   imageStore(image, xy, mix(color, colors.recolor, saturation));
}