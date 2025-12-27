shader_type canvas_item;

uniform bool is_locked = false;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (is_locked) {
		COLOR = vec4(0.0, 0.0, 0.0, tex_color.a);
	} else {
		COLOR = tex_color;
	}
}