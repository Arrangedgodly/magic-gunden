shader_type canvas_item;

uniform float mix_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);

    float grayscale = dot(texture_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grayscale_vec = vec3(grayscale);

    vec3 final_color = mix(texture_color.rgb, grayscale_vec, mix_amount);

    COLOR = vec4(final_color, texture_color.a);
}
