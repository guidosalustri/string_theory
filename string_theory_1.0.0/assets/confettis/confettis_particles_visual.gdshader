shader_type canvas_item;

uniform sampler2D gradient_sampler : source_color;
varying vec4 custom;

void vertex(){
	custom = INSTANCE_CUSTOM;
	VERTEX.y *= sin(custom.z);
}

void fragment(){
	COLOR.rgb += max(0.0, sin(custom.z * 2.0 + PI)) * 0.2;
}