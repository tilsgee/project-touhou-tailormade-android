shader_type canvas_item;

uniform float opacity: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float speed: hint_range(0.0, 1.0, 0.1) = 1.0;

uniform sampler2D noise_texture: repeat_enable;

void fragment() {
	float alpha = texture(noise_texture, UV + (TIME * speed / 10.0)).b;
	COLOR.a = COLOR.a * alpha - (1.0 - opacity);
}