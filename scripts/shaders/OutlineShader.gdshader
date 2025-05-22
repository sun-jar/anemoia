shader_type canvas_item;

uniform bool show_outline = false;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_thickness = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float base_alpha = tex_color.a;

    if (show_outline) {
        bool is_edge = false;

        for (int x = -1; x <= 1 && !is_edge; x++) {
            for (int y = -1; y <= 1 && !is_edge; y++) {
                vec2 offset = vec2(float(x), float(y)) * outline_thickness / TEXTURE_PIXEL_SIZE;
                if (texture(TEXTURE, UV + offset).a > 0.1) {
                    is_edge = true;
                }
            }
        }

        if (is_edge) {
            COLOR = outline_color;
        } else {
            discard;
        }
    } else {
        COLOR = tex_color;
    }
}
