shader_type spatial;

render_mode blend_mix, cull_back;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform float alpha_scissor_threshold : hint_range(0, 1)  = 0.5;
uniform float dissolve : hint_range(0, 1)  = 0.0;
uniform sampler2D texture_dissolve : hint_default_white;

uniform float metal: hint_range(0, 1)  = 0.0;
uniform float rough: hint_range(0, 1)  = 1.0;


void vertex() {
//	UV=UV*uv1_scale.xy+uv1_offset.xy;
	vec2 looping_uv = UV + vec2(0.0, fract(TIME * 0.005));
	UV = looping_uv;
}

void fragment() {
	//vec2 looping_uv = UV + vec2(fract(TIME), 0.0);
    vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	
	
    ALBEDO = albedo.rgb * albedo_tex.rgb;
    //ALPHA = albedo.a * albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	METALLIC=metal;
	ROUGHNESS=rough;
    
    
    float limit = texture(texture_dissolve, UV).r;
	float fade = 1.0 - dissolve;
    if (fade < limit)
        discard;
		
	
}