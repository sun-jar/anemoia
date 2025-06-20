shader_type canvas_item;

uniform float glow_size = 8.0;
uniform float base_strength = 0.7;
uniform vec4 glow_color : source_color = vec4(1.0);
uniform float pulse_speed = 3.0;
uniform float pulse_amplitude = 0.4;

void fragment() {
    vec2 square_min = vec2(16.0 / 96.0);
    vec2 square_max = vec2(80.0 / 96.0);

    bool in_square = UV.x >= square_min.x && UV.x <= square_max.x &&
                     UV.y >= square_min.y && UV.y <= square_max.y;

    float dx = max(square_min.x - UV.x, UV.x - square_max.x);
    float dy = max(square_min.y - UV.y, UV.y - square_max.y);
    float edge_dist = max(dx, dy);

    float glow = 1.0 - smoothstep(0.0, glow_size / 96.0, edge_dist);

    // 🔁 Add pulsing to glow strength
    float pulse = base_strength + sin(TIME * pulse_speed) * pulse_amplitude;
    vec4 glow_effect = glow_color * glow * pulse;

    if (in_square) {
        COLOR = vec4(1.0);
    } else {
        COLOR = glow_effect;
    }
}
