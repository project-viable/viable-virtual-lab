shader_type canvas_item;

// Global y coordinate of the top of each substance layer, from top to bottom.
uniform float depth_offsets[10];
uniform vec4 substance_colors[10]: source_color;
uniform int substance_count;

varying mat4 screen_to_world;

void vertex()
{
	screen_to_world = inverse(CANVAS_MATRIX);
}

void fragment()
{
	float global_y_coord = (screen_to_world * FRAGCOORD).y;

	COLOR = vec4(0);
	for (int i = 0; i < substance_count; ++i)
	{
		if (global_y_coord > depth_offsets[i])
		{
			COLOR = substance_colors[i];
			break;
		}
	}
}
