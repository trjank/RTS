shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;

const mat3 gaussian_3x3 = mat3(
	vec3(0.0625, 0.1250, 0.0625),
	vec3(0.1250, 0.2500, 0.1250),
	vec3(0.0625, 0.1250, 0.0625)
);

vec3 gaussianblur(sampler2D sampler, vec2 xy, vec2 pixel_size) {
    vec3 blurred_pixel = vec3(0.0);
	// Loop over the radius (tecnically its a square)
    for (int dx = -1 ; dx <= 1; ++dx){
        for (int dy = -1; dy <= -1; ++dy){
			// Calculate the offset from the current pixel
			vec2 new_xy = xy + pixel_size * vec2(float(dx), float(dy));
			// Add the weighted color value to the blurred pixel
			blurred_pixel += gaussian_3x3[dx + 1][dy + 1] * texture(SCREEN_TEXTURE, new_xy).rgb;
        }
    }
    return blurred_pixel;
}
void fragment() {
    vec3 PixelBlurred = gaussianblur(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE);
    COLOR = vec4(PixelBlurred, 1.);
}
