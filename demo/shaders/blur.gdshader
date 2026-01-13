shader_type canvas_item;
// Hi! This is my first shader, so maybe its not the best at performance, but it makes the job.
//
// Used the following sites to know how the gaussian blur works:
// https://en.wikipedia.org/wiki/Gaussian_blur
// https://www.w3.org/Talks/2012/0125-HTML-Tehran/Gaussian.xhtml <- Helped a lot!

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture,repeat_disable, filter_nearest;

const float STD = 3.0;

float gaussian(float x) {
	return exp(-(x * x) / (2. * STD * STD)) / (sqrt(2. * PI) * STD);
}

vec3 gaussian_blur(sampler2D sampler, vec2 pos, vec2 pixel_size, int radius){
	vec3 blurred_pixel = vec3(0.0);
	float total_weight = 0.0;
	// Loop over the radius (tecnically its a square)
	for (int dx = -radius; dx <= radius; ++dx){
		for (int dy = -radius; dy <= radius; ++dy){
			// Calculate the offset from the current pixel
			vec2 offset = vec2(float(dx), float(dy)) * pixel_size;
			vec2 changedPos = pos + offset;
			// Calculate the weight based on the Gaussian distribution multiplying both dimentions (how far are X and Y form the center (pos))
			float weight = gaussian(float(dx)) * gaussian(float(dy));
			// Add the weighted color value to the blurred pixel
			blurred_pixel += weight * texture(SCREEN_TEXTURE, changedPos).rgb;
			total_weight += weight;
		}
	}
	// Normalize the blurred pixel color by the total weight
	blurred_pixel /= total_weight;
    return blurred_pixel;
}
void fragment() {
    vec3 PixelBlurred = gaussian_blur(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE,  int(round(3.0 * STD)));
    // The radius is 3*Sigma because it is the point where the Gaussian weight is near zero.
    COLOR = vec4(PixelBlurred, 1.);
}
