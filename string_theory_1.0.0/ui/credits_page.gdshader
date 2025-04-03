shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float easeOutCubic(float x) {
	return 1.0 - pow(1.0 - x, 3.0);
}

void fragment() {
	const float height = 1.0 / SCREEN_PIXEL_SIZE.y;
	const float midpoint = height / 2.0;
	float dist = abs(midpoint - FRAGCOORD.y);
	float normalized_dist = dist / height;
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);

    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    COLOR *= c;
	COLOR.a = mix( 0.0, COLOR.a, smoothstep(1.0, 0.0, easeOutCubic( 2.0 * normalized_dist ) ) );
}
