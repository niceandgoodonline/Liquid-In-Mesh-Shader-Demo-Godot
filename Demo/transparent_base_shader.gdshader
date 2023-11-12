shader_type spatial;
render_mode cull_disabled;

uniform float AlphaAmount: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float Metallic: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float Roughness: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float Rim: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float RimTint: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float Specular: hint_range(0.0, 1.0, 0.001) = 0.5;

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA     = AlphaAmount;
	METALLIC  = Metallic;
	ROUGHNESS = Roughness;
	SPECULAR  = Specular;
	RIM       = Rim;
	RIM_TINT  = RimTint;
}
