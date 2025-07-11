shader_type canvas_item;

uniform vec3 outline_color : source_color = vec3(1, 0.2, 0.1);
uniform float alpha_threshold: hint_range(0.0, 1.0) = 0.1;
uniform bool enabled = false;
uniform int radius = 5;

/*
 * Hacky way to scale the outline radius to be in terms of screen pixel size instead of the sprite's
 * pixel size.
 */
uniform vec2 sprite_scale = vec2(1, 1);

void fragment()
{
	if (texture(TEXTURE, UV).a < alpha_threshold)
	{
		if (enabled)
		{
			float amount_nearby = 0.0;
			for (int i = -radius; i <= radius; ++i)
			{
				for (int j = -radius; j <= radius; ++j)
				{
					vec2 pixel_offset = vec2(float(i), float(j));
					vec2 offset_uv = UV + pixel_offset * TEXTURE_PIXEL_SIZE / sprite_scale;
					if (texture(TEXTURE, offset_uv).a > alpha_threshold)
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
