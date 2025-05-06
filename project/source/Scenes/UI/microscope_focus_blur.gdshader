shader_type canvas_item;

uniform float blur_amount: hint_range(0.0, 1.0);
uniform float brightness: hint_range(-1.0, 1.0);

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE,0));
	vec2 uv = UV;

	if (blur_amount < 0.01) {
		COLOR = texture(TEXTURE, uv);
	} else {
		float blur_radius = blur_amount * 8.0;

		const int samples = 9;

		float kernel[9] = float[9](
			0.077847, 0.123317, 0.077847,
			0.123317, 0.195346, 0.123317,
			0.077847, 0.123317, 0.077847
		);

		vec2 offsets[9] = vec2[9](
			vec2(-1.0, -1.0), vec2(0.0, -1.0), vec2(1.0, -1.0),
			vec2(-1.0,  0.0), vec2(0.0,  0.0), vec2(1.0,  0.0),
			vec2(-1.0,  1.0), vec2(0.0,  1.0), vec2(1.0,  1.0)
		);

		vec4 blurred_color = vec4(0.0);

		for (int i = 0; i < samples; i++){
			vec2 offset = offsets[i] * blur_radius / tex_size;
			blurred_color += texture(TEXTURE, uv + offset) * kernel[i];
		}

		vec4 original_color = texture(TEXTURE, uv);
		COLOR = mix(original_color, blurred_color, blur_amount);
	}

	COLOR.rgb += vec3(brightness);
}
