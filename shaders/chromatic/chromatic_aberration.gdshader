shader_type canvas_item;
render_mode blend_disabled;

uniform bool circular_aberration = false;
uniform float feather = 1.0;
uniform vec2 strength = vec2(1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	vec2 offset = strength * SCREEN_PIXEL_SIZE;
	
	if (circular_aberration){
		offset *= smoothstep(0.0, feather, length(UV - vec2(0.5))) * 1.66;
	}
	
	float R = texture(SCREEN_TEXTURE, SCREEN_UV - offset).r;
	float G = texture(SCREEN_TEXTURE, SCREEN_UV ).g;
	float B = texture(SCREEN_TEXTURE, SCREEN_UV + offset).b;
	
	float value = distance(UV, vec2(0.5));
	COLOR = vec4(R, G, B, 1);
}