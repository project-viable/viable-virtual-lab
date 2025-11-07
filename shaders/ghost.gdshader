// Used to show a "ghost" version of an object where it will be placed.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment()
{
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);

	// Basic pulsating effect.
	c.rgb *= vec3(0.5, 0.5, 1.0);
	c *= mix(0.7, 1.0, (cos(TIME * 5.0) + 1.0) / 4.0);

	// For `CanvasGroup`.
	if (c.a > 0.0001)
	{
		c.rgb /= c.a;
	}

	COLOR *= c;
}
