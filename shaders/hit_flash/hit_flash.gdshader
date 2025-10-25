shader_type canvas_item;
render_mode blend_mix;

uniform vec4 modulation_color: source_color = vec4(1.0);
uniform float max_modulation: hint_range(0.0, 1.0, 0.1) = 0.66;

float range_lerp(float value, float istart, float istop, float ostart, float ostop) {
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

void fragment() {
	vec4 color = modulation_color;
	vec3 tgt_color = vec3(
		range_lerp(max_modulation, 0.0, 1.0, COLOR.r, color.r),
		range_lerp(max_modulation, 0.0, 1.0, COLOR.g, color.g),
		range_lerp(max_modulation, 0.0, 1.0, COLOR.b, color.b)
	);
	COLOR.rgb = tgt_color;
}
