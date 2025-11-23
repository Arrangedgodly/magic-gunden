shader_type canvas_item;


uniform sampler2D pattern_sampler : repeat_enable, filter_linear_mipmap;

// Background gradient colors
uniform vec3 background_gradient_start_color : source_color;
uniform vec3 background_gradient_end_color : source_color;


// Background gradient angle in radians
uniform float gradient_angle = 1.571;


// Pattern appearance
uniform float pattern_alpha = 0.4;
uniform float pattern_brightness_boost = 0.25;
uniform float tint_shift_strength = 0.08;

// Pattern transformation
uniform float pattern_scale = 256;

// Animation controls
uniform vec2 pattern_direction = vec2(1.0, 0.0); // normalized direction of movement
uniform float pattern_speed = 0.05;              // how fast it scrolls
uniform float pattern_rotation = 0.0;            // radians

void fragment() {
    // ---------------------------------------------------------
    // Compute base UV before transformations
    // ---------------------------------------------------------
    vec2 base_uv = FRAGCOORD.xy / pattern_scale;

    // ---------------------------------------------------------
    // Apply rotation
    // ---------------------------------------------------------
	float cos_angle = cos(pattern_rotation);
	float sin_angle = sin(pattern_rotation);

	mat2 rotation_matrix = mat2(
	    vec2(cos_angle, -sin_angle),
	    vec2(sin_angle,  cos_angle)
	);

	vec2 rotated_uv = rotation_matrix * base_uv;


    // ---------------------------------------------------------
    // Apply sliding animation
    // ---------------------------------------------------------
    vec2 movement_offset = pattern_direction * TIME * pattern_speed;
    vec2 animated_uv = rotated_uv + movement_offset;

    // ---------------------------------------------------------
    // Sample pattern intensity
    // ---------------------------------------------------------
	
	vec4 sample_rgba = texture(pattern_sampler, animated_uv);

	// Compute luminance from RGB
	float luminance = dot(sample_rgba.rgb, vec3(0.299, 0.587, 0.114));

	// Alpha-based intensity (for masks and SVG patterns)
	float alpha_intensity = sample_rgba.a;

	// Automatic blending:
	// - If alpha is not all-or-nothing, it wins.
	// - If alpha is near 0 or 1 everywhere, fall back to luminance.
	float pattern_intensity = mix(
	    luminance,
	    alpha_intensity,
	    step(0.02, alpha_intensity) * step(alpha_intensity, 0.98)
	);


    // ---------------------------------------------------------
    // Background gradient
    // ---------------------------------------------------------
    // Background gradient with configurable angle
	vec2 gradient_direction = vec2(cos(gradient_angle), sin(gradient_angle));
	float gradient_position = dot(SCREEN_UV, gradient_direction);
	
	gradient_position = clamp(gradient_position, 0.0, 1.0);
    
	vec3 background_color = mix(background_gradient_start_color, background_gradient_end_color, gradient_position);


    // ---------------------------------------------------------
    // Derive pattern color from background
    // ---------------------------------------------------------
    vec3 pattern_color = background_color;

    // Accent tint shift
    pattern_color = mix(pattern_color, vec3(1.0) - pattern_color, tint_shift_strength);

    // Brightness boost based on texture
    float brightness_factor = 1.0 + pattern_intensity * pattern_brightness_boost;
    pattern_color *= brightness_factor;

    // ---------------------------------------------------------
    // Composite pattern *over* background without changing background
    // ---------------------------------------------------------
    vec3 final_color = mix(
        background_color,
        pattern_color,
        pattern_intensity * pattern_alpha
    );

    COLOR.rgb = final_color;
    COLOR.a = 1.0;
}
