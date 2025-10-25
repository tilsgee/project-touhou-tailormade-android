shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap_anisotropic;

uniform float intensity : hint_range(0.0, 5.0) = 4.0;
uniform float contrast : hint_range(0, 3, 0.1) = 1.1;
uniform float saturation : hint_range(0, 3, 0.1) = 1.1;

void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, intensity);

	color.rgb = mix(vec3(0.5), color.rgb, contrast);
    color.rgb = mix(vec3(dot(vec3(1.0), color.rgb) * 0.33333), color.rgb, saturation);
	
	COLOR = color;
}