shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec3 mixed_color = mix(texture_color.rgb, flash_color.rgb, flash_modifier);
	
	COLOR.rgb = mixed_color;
	COLOR.a = texture_color.a;
}