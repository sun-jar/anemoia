shader_type canvas_item;

uniform vec4 outline_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    COLOR = outline_color;
}