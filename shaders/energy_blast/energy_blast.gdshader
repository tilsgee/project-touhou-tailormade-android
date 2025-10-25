shader_type canvas_item;
render_mode unshaded;

const vec2 rect_size = vec2(1280, 1280);
const vec2 position = vec2(640, 640);

uniform float opacity: hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float size: hint_range(0.0, 2.0, 0.01) = 0.05;
uniform float speed = 0.3;
uniform float gap: hint_range(0.0, 1.0, 0.01) = 0.01;
uniform float feather: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float noise_strength: hint_range(0.0, 1.0, 0.01) = 0.02;

uniform sampler2D gradient_texture: repeat_enable;
uniform sampler2D noise_texture: repeat_enable;

float calculate_mask(vec2 uv) {
	vec2 center_point = position / rect_size;
	vec2 mult = vec2(cos(TIME), sin(TIME)) * speed;
	float noise = texture(noise_texture, uv + mult).b * (noise_strength / 10.0);
	float n_feather = feather / 10.0;
	float mask_in = smoothstep(size + noise - n_feather, size + noise, length(uv - center_point));
	float mask_out = smoothstep(size + (gap / 10.0) + noise - n_feather, size + (gap / 10.0) + noise, length(uv - center_point)) ;
	
	float mask_delta = (mask_in - mask_out);
	float mask = mask_delta;
	
	return clamp(mask, 0.0, 1.0);
}

void fragment() {
	vec2 mult = vec2(cos(TIME), sin(TIME)) * speed;
	float mask = calculate_mask(UV);
	vec3 color = texture(gradient_texture, vec2(mask - 0.01, 0.0)).rgb;
	
	COLOR = vec4(color, mask - (1.0 - opacity));
}