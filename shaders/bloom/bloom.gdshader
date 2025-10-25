shader_type canvas_item;
render_mode blend_add;

uniform sampler2D t0 : hint_screen_texture;

uniform float brightness : hint_range(-1.0, 1.0, 0.05) = -0.1;
uniform float intensity : hint_range(0.0, 5.0) = 3.0;
uniform float alpha : hint_range(0.0, 1.0, 0.05) = 0.3;

vec4 blend(vec4 base, float a){
	return base + vec4(vec3(a), 0.0);
}

void fragment() {
	vec4 color_lod = textureLod(t0, SCREEN_UV, intensity);
	color_lod.a *= alpha;
	COLOR = blend(color_lod, brightness);
}
