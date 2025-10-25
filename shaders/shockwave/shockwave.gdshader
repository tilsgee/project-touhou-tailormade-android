shader_type canvas_item;

uniform bool preview_atlas;
uniform vec2 rect_size = vec2(1024, 1024);
uniform vec2 position;
uniform float size;
uniform float feather : hint_range(0.0,0.8,0.01);
uniform float gap : hint_range(0.0,0.5,0.01);
uniform float force : hint_range(0.0,0.5,0.01);
uniform bool chromatic_abberation;
uniform float chromatic_offset : hint_range(0.0,0.5,0.01);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 center_point = position / rect_size;
	float mask_in = smoothstep(size - feather - gap, size - gap, length(UV - center_point));
	float mask_out = smoothstep(size - feather, size, length(UV - center_point));
	float mask = mask_in - mask_out;
	
	vec2 shift = normalize(UV - center_point) * force * mask;
	
	COLOR = texture(screen_texture, SCREEN_UV - shift);
	
	if (chromatic_abberation){
		vec3 chromatic_effect;
		chromatic_effect.r = 1.0;
		chromatic_effect.g = 1.0 + chromatic_offset;
		chromatic_effect.b = 1.0 - chromatic_offset;
		
		COLOR.r = texture(screen_texture, SCREEN_UV - shift * chromatic_effect.r).r;
		COLOR.g = texture(screen_texture, SCREEN_UV - shift * chromatic_effect.g).g;
		COLOR.b = texture(screen_texture, SCREEN_UV - shift * chromatic_effect.b).b;
	}
	
	// ATLAS
	if (preview_atlas){
		COLOR.rgb = vec3(mask);
	}
}

