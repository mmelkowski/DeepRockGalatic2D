shader_type canvas_item;

// --- Includes --- //
//#include "res://shaders/includes/generic_functions.gdshaderinc"

//"""
//Shine Color: The color of the shine
//
//Line Width: How wide the shine is
//Angle: The angle of the shine
//
//Speed: How fast the shine moves across the texture
//Wait Cycles: How many “cycles” to wait until the next shine appears
//"""

// --- Uniforms --- //
uniform vec4 shine_color: source_color = vec4(5.0, 1.0, 1.0, 0.2);

uniform float line_width: hint_range(0.0, 2.0, 0.01) = 0.1;
uniform float angle: hint_range(0.0, 6.28318530718, 0.1308996939) = 0.785398163397;

uniform float speed: hint_range(0.0, 10.0, 0.1) = 1.3;
uniform float wait_cycles: hint_range(0.0, 10.0, 0.1) = 1.5;

// --- Functions --- //
vec2 rotate_precalculated(vec2 _pos, float _sine, float _cosine) {
	return vec2(_pos.x * _cosine + _pos.y * -_sine, _pos.x * _sine + _pos.y * _cosine);
}

void fragment() {
	float sine = sin(angle);
	float cosine = cos(angle);
	float len = 1.5 - max(abs(sine), abs(cosine)) + line_width;
	float line = smoothstep(-line_width, line_width, 
			rotate_precalculated((UV - vec2(0.5)), sine, cosine).y - mod(TIME * speed, (len * 2.0) * wait_cycles) + len);
	COLOR.rgb += shine_color.rgb * shine_color.a * vec3(line * (1.0 - line) * 4.0);
}
