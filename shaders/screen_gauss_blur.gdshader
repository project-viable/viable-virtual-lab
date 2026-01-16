shader_type canvas_item;

const float SQRT2PI = sqrt(2.0 * PI);

uniform sampler2D screen : hint_screen_texture, repeat_disable, filter_nearest;

uniform ivec2 axes = ivec2(0, 0);
uniform vec2 stds = vec2(1.0, 1.0);

float gauss(float std, float x)
{
	return exp(-x * x / (2.0 * std * std)) / (SQRT2PI * std);
}

void fragment()
{
	COLOR = vec4(0);
	float total_weight = 0.0;
	
	for (int x = -axes.x; x <= axes.x; ++x)
	{
		for (int y = -axes.y; y <= axes.y; ++y)
		{
			vec2 uv = SCREEN_UV + vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE;
			float weight = gauss(stds.x, float(x)) * gauss(stds.y, float(y));
			total_weight += weight;
			COLOR += texture(screen, uv) * weight;
		}
	}

	COLOR /= total_weight;
}
