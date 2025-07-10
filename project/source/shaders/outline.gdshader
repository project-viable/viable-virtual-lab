shader_type canvas_item;

uniform vec3 outline_color : source_color = vec3(1, 1, 0);
uniform bool enabled = false;
uniform int radius = 5;

void fragment()
{
	if (texture(TEXTURE, UV).a < 0.001)
	{
		if (enabled)
		{
			float amount_nearby = 0.0;
			for (int i = -radius; i <= radius; ++i)
			{
				for (int j = -radius; j <= radius; ++j)
				{
					vec2 pixel_offset = vec2(float(i), float(j));
					vec2 offset_uv = UV + pixel_offset * TEXTURE_PIXEL_SIZE;
					if (texture(TEXTURE, offset_uv).a > 0.001)
					{
						amount_nearby += 1.0 - min(1.0, length(pixel_offset) / float(radius));
					}
				}
			}

			amount_nearby /= float((2 * radius + 1) * (2 * radius + 1));
			COLOR = vec4(outline_color, sqrt(amount_nearby));
		}
	}
}