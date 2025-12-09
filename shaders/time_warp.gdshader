shader_type canvas_item;

uniform float strength = 0.0f;

void fragment()
{
	float extra_offset = sin(TIME * 30.0) * strength / 5.0;

	vec2 uv_r = UV - TEXTURE_PIXEL_SIZE * vec2(strength + extra_offset, 0);
	vec2 uv_g = UV;
	vec2 uv_b = UV + TEXTURE_PIXEL_SIZE * vec2(strength + extra_offset, 0);

	COLOR = vec4(
		texture(TEXTURE, uv_r).r,
		texture(TEXTURE, uv_g).g,
		texture(TEXTURE, uv_b).b,
		texture(TEXTURE, UV).a
	);
}
