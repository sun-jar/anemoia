shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform vec3 color_addition = vec3(0.1, 0.1, 0.1);

void fragment() {
	vec4 screen_col = texture(screen_texture, SCREEN_UV);
	float mask_alpha = texture(TEXTURE, UV).a;

	// Multiply RGB by modulate color and alpha
	COLOR.rgb = screen_col.rgb * COLOR.rgb + color_addition;

	// Multiply alpha by both mask and modulate
	COLOR.a = mask_alpha * COLOR.a;
}
