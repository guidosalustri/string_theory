shader_type canvas_item;

// blurs the background
uniform float blur_amount: hint_range(0.0, 10.0) = 0.0;
// adds a tint. Only useful if tint_amount > 0
uniform vec4 tint : source_color;
// how much the chosen color colors the background
uniform float tint_amount : hint_range(0.0, 1.0);
// The closer to 0, the less saturated
uniform float saturation : hint_range(0.0, 1.0) = 1.0;
// necessary in Godot 4 to obtain the screen texture
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 blurred = texture(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	vec3 desaturated = mix(vec3(dot(blurred.rgb, vec3(0.299, 0.587, 0.114))), blurred.rgb, saturation);
	vec4 tinted = mix(vec4(desaturated.rgb, 1.0), tint, tint_amount);
	COLOR = vec4(tinted.rgb, 1.0);
}