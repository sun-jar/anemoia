shader_type canvas_item;

uniform vec2 r_displacement = vec2(4.0, 1.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-4.0, 1.0);

uniform float strength : hint_range(0.0, 0.1, 0.001) = 0.08;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 1.0, 0.001) = 0.25;

uniform float aberration : hint_range(0.0, 1.0, 0.001) = 0.425;
uniform float width : hint_range(0.0, 0.1, 0.0001) = 0.04;
uniform float feather : hint_range(0.0, 1.0, 0.001) = 0.135;

uniform float alpha = 1.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 st = SCREEN_UV;
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 scaled_st = (st - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0.0, 0.5); 
	vec2 dist_center = scaled_st - center;
	
	// Create a mask to modulate the effect around the center
	float mask = (1.0 - smoothstep(radius - feather, radius, length(dist_center))) 
	           * smoothstep(radius - width - feather, radius - width, length(dist_center));
	
	// Calculate offsets for distortion
	vec2 offset = normalize(dist_center) * strength * mask;
	vec2 biased_st = scaled_st - offset;
	
	// Chromatic aberration offset
	vec2 abber_vec = offset * aberration * mask;
	
	// Combine the distorted UVs with the mask
	vec2 final_st = st * (1.0 - mask) + biased_st * mask;

	// Sample the screen texture for each color channel
	vec4 red = texture(SCREEN_TEXTURE, final_st + abber_vec + vec2(SCREEN_PIXEL_SIZE*r_displacement));
	vec4 blue = texture(SCREEN_TEXTURE, final_st - abber_vec + vec2(SCREEN_PIXEL_SIZE*g_displacement));
	vec4 ori = texture(SCREEN_TEXTURE, final_st + vec2(SCREEN_PIXEL_SIZE*g_displacement));
	
	// Combine channels to create the final color
	COLOR = vec4(red.r, ori.g, blue.b, alpha);
}