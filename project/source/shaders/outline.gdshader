shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec3 outline_color : source_color = vec3(1, 0.2, 0.1);
uniform float alpha_threshold: hint_range(0.0, 1.0) = 0.1;
uniform bool enabled = false;
uniform float radius = 5;

void fragment()
{
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);

	if (c.a < alpha_threshold)
	{
		if (enabled)
		{
			int r = int(ceil(radius));

			float amount_nearby = 0.0;
			for (int i = -r; i <= r; ++i)
			{
				for (int j = -r; j <= r; ++j)
				{
					vec2 pixel_offset = vec2(float(i), float(j));
					vec2 offset_uv = SCREEN_UV + pixel_offset * SCREEN_PIXEL_SIZE;
					if (textureLod(screen_texture, offset_uv, 0.0).a > alpha_threshold)
					{
						amount_nearby += 1.0 - min(1.0, length(pixel_offset) / radius);
					}
				}
			}

			amount_nearby /= float((2 * r + 1) * (2 * r + 1));
			c = vec4(outline_color, sqrt(amount_nearby));
		}
	}

	// For `CanvasGroup`.
	if (c.a > 0.0001)
	{
		c.rgb /= c.a;
	}

	COLOR *= c;
}
