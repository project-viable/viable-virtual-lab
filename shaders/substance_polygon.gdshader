shader_type canvas_item;

// Y coordinate of the top of each substance layer, from top to bottom. This is
// in the direction of `down_direction`.
uniform float depth_offsets[10];
uniform vec4 substance_colors[10]: source_color;
uniform int substance_count;
// The direction of gravity in local coordinates.
uniform vec2 down_direction;

varying mat4 screen_to_local;

void vertex()
{
	screen_to_local = inverse(CANVAS_MATRIX * MODEL_MATRIX);
}

void fragment()
{
	vec2 local_pos = (screen_to_local * FRAGCOORD).xy;
	float local_y_coord = dot(normalize(down_direction), local_pos);

	COLOR = vec4(0);
	for (int i = 0; i < substance_count; ++i)
	{
		if (local_y_coord > depth_offsets[i])
		{
			COLOR = substance_colors[i];
			break;
		}
	}
}
