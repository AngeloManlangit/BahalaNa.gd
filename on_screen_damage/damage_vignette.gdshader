shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.8, 0.0, 0.0, 1.0); // Red
uniform float radius = 0.8;
uniform float softness = 0.5;
uniform float effect_strength : hint_range(0.0, 1.0) = 0.0; 
uniform float pulse_speed = 0.0;
uniform sampler2D noise_texture; // The "Veins"

void fragment() {
	float dist = distance(UV, vec2(0.5));
	float vignette = smoothstep(radius, radius - softness, dist);
	
	float pulse = sin(TIME * pulse_speed) * 0.1;
	
	float noise_value = texture(noise_texture, UV).r;
	
	float alpha = (1.0 - vignette) * noise_value * (effect_strength + pulse) * 3.0;
	
	COLOR = vec4(vignette_color.rgb, clamp(alpha, 0.0, 1.0));
}