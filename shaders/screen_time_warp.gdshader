shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture, repeat_disable, filter_nearest;

uniform float strength = 0.0f;

void fragment()
{
	float extra_offset = sin(TIME * 30.0) * strength / 5.0;

	vec2 uv_r = SCREEN_UV - SCREEN_PIXEL_SIZE * vec2(strength + extra_offset, 0);
	vec2 uv_g = SCREEN_UV;
	vec2 uv_b = SCREEN_UV + SCREEN_PIXEL_SIZE * vec2(strength + extra_offset, 0);

	COLOR = vec4(
		texture(screen, uv_r).r,
		texture(screen, uv_g).g,
		texture(screen, uv_b).b,
		texture(screen, SCREEN_UV).a
	);
}
