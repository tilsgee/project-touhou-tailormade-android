shader_type canvas_item;
render_mode blend_mix;

uniform bool preview_atlas;
uniform vec2 rect_size = vec2(1024, 1024);
uniform vec2 position;
uniform float size;
uniform float gap : hint_range(0.0,0.5,0.01);
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 center_point = position / rect_size;
	float mask_in = smoothstep(size, size, length(UV - center_point));
	float mask_out = smoothstep(size + gap, size + gap, length(UV - center_point));
	float mask = 1.0 - (mask_in - mask_out);
	
	vec4 result = texture(screen_texture, SCREEN_UV);
	COLOR = vec4(1.0 - result.rgb, mask);

	// ATLAS
	if (preview_atlas){
		COLOR.rgb = vec3(mask);
	}
}

