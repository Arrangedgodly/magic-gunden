shader_type canvas_item;

uniform float wave_amplitude = 30.0;
uniform float wave_frequency = 140.0;
uniform float movement_speed = 2.0;
uniform float movement_amplitude = 5.0;

void vertex() {
	VERTEX.y -= sin(VERTEX.x / wave_frequency) * wave_amplitude;
	VERTEX.y += sin(TIME * movement_speed) * movement_amplitude;
}