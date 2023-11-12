shader_type spatial;
render_mode cull_disabled, shadows_disabled;

group_uniforms PhysicsSetByScript;
uniform vec2 coeff; // Coefficients of the linear function for the surface.
uniform float vel; // Rate of change of the coefficients.

group_uniforms Visuals;
uniform vec4 liquid_color     : source_color = vec4(0.7, 0.1, 0.6, 1.0);
uniform vec4 foam_color       : source_color = vec4(0.9f, 0.3, 0.8, 1.0);
uniform float foam_line       : hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float fill_amount     : hint_range(0.0, 1.0, 0.001) = 0.5;
uniform vec2 size             = vec2(1.0, 1.0);
uniform float glass_thickness = 0.05;
uniform float scale           = 1.0;
uniform float wave_intensity  = 0.05f;
uniform sampler2D waves_noise;

group_uniforms Bubbles;
uniform bool HasBubbles     = true;
uniform bool AlwaysBubbles  = false;
uniform float BubbleStrength: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform float BubbleMask    : hint_range(0.0, 1.0, 0.001) = 0.5;
uniform vec2 BubbleSpeed    = vec2(3.0, 3.0);
uniform sampler2D bubbles_tex;

varying lowp vec3 pos;
varying lowp float rot_scale;
varying lowp vec3 world_vec_up_to_model;
varying lowp vec3 weights;

void vertex() {
	VERTEX                -= glass_thickness * NORMAL;
	/* Position inside container rotated to world. */
	pos                   = mat3(MODEL_MATRIX)*VERTEX;
	/* Lerp between height and width depending on world orientation of z axis. */
	world_vec_up_to_model = vec3(0.0f, 1.0f, 0.0f)* mat3(MODEL_MATRIX);
	rot_scale             = mix(size.x, size.y, abs(dot(world_vec_up_to_model, vec3(0.0f, 1.0f, 0.0f))));
	weights               = mat3(MODEL_MATRIX)*NORMAL; weights*=weights;
}

void fragment() {
	/* Set liquid line to fill amount, add noise waves and incline. */
	lowp float wave_noise_1 = texture(waves_noise, (2.0 * pos.xz + 0.5 * TIME * vec2(1.0, 1.0)) * scale).r;
	lowp float wave_noise_2 = texture(waves_noise, (2.0 * pos.xz - 0.5 * TIME * vec2(1.0, 1.0)) * scale).g;
	lowp float wave = wave_intensity * length(coeff) * (wave_noise_1 - 0.5f + wave_noise_2 - 0.5f) + dot(pos.xz, coeff);
	wave *= smoothstep(0.05, 0.25, fill_amount);
	lowp float liquid_line = (fill_amount * 2.0 - 1.0 + wave) * rot_scale;
	if (pos.y > liquid_line) discard;// Discard all vertices above the liquid line. */

	if (HasBubbles){
		float bubble_weight = vel;
		if (AlwaysBubbles) {
			bubble_weight = BubbleStrength;
		}
		vec2 distortion  = vec2(wave_noise_1, wave_noise_2)*0.01;
		lowp vec2 bubbles;
		bubbles.x        = smoothstep(BubbleMask, 1.0, texture(bubbles_tex, scale * BubbleSpeed * pos.yx + distortion - TIME * vec2(2.0, 0.5)).r);
		bubbles.y        = smoothstep(BubbleMask, 1.0, texture(bubbles_tex, scale * BubbleSpeed * pos.yz + distortion - TIME * vec2(2.0, 0.0)).r);
		bubbles         *= weights.zx * 1.0 * bubble_weight;
		BACKLIGHT.z      = bubbles.x + bubbles.y;
	}

	if (FRONT_FACING)
	{
		float foam       = smoothstep(liquid_line - foam_line * scale * rot_scale, liquid_line,pos.y);
		vec3 normal_foam = mix (NORMAL, vec3(coeff.x, 1.0, coeff.y), foam);
		vec3 color_foam  = mix(liquid_color.xyz, foam_color.xyz, foam);
		ALBEDO           = mix(liquid_color.xyz, color_foam, vel);
		NORMAL           = mix(NORMAL, normal_foam, vel);
	}
	else
	{
		ALBEDO = mix(liquid_color.xyz, foam_color.xyz, vel);
		NORMAL = vec3(coeff.x, 1.0, coeff.y);
	}
}

void light() 
{
	// Liquid "glow" when held against light. 
	lowp float d  = dot(-VIEW, LIGHT);
	lowp float dd = smoothstep(0.0, 1.0, d);
	dd *= dd;
	DIFFUSE_LIGHT = (dd -BACKLIGHT.z * d) * liquid_color.rgb;
}