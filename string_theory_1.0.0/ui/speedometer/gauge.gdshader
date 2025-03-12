shader_type canvas_item;

uniform float begin = 240.0;
uniform float end = 300.0;

void fragment() {
vec4 tex = texture(TEXTURE, UV);
	
	// Center and scale the coordinates
	vec2 a = vec2(UV.x, 1.0 - UV.y);
	a += vec2(-0.5, -0.5);
	a *= 2.0;
	
	// Calculate angle properly using atan2 (handles all quadrants)
	float angle = atan(a.y, a.x);
	
	// Convert to degrees in range [0, 360]
	float deg = degrees(angle);
	deg = mod(deg + 360.0, 360.0); // Force into 0-360 range without branching
	
	// Standardize begin and end to 0-360 range
	float b = mod(begin, 360.0);
	float e = mod(end, 360.0);
	
	// Check if angle is in range without branching
	// For overlapping ranges (b <= e): we want (deg >= b && deg <= e)
	// For wrapped ranges (b > e): we want (deg >= b || deg <= e) which is the same as !(deg < b && deg > e)
	
	// For the overlapping case (e.g., 30-60 degrees):
	float in_normal_range = step(b, deg) * step(deg, e);
	
	// For the wrapped case (e.g., 300-30 degrees):
	float in_wrapped_range = 1.0 - step(e, deg) * step(deg, b);
	
	// Choose the right calculation based on whether b > e (wrapped range)
	float range_is_wrapped = step(e, b);
	float in_range = mix(in_normal_range, in_wrapped_range, range_is_wrapped);
	
	// Apply transparency based on whether angle is in range
	tex.a = tex.a * (1.0 - in_range);
	COLOR = tex;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
