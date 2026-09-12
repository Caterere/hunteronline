shader_type canvas_item;

// ============================================================
// HUNTER ONLINE - SMART PIXEL ART COLOR CUSTOMIZER SHADER
// ============================================================
// Identifica pele, cabelo (claro/escuro), olhos e roupa pela
// luminescência/matiz. Sem 'return' no fragment (compat Godot 4).
// ============================================================

uniform vec4 hair_custom_color : source_color = vec4(0.15, 0.15, 0.15, 1.0);
uniform vec4 clothes_custom_color : source_color = vec4(0.2, 0.6, 0.3, 1.0);
uniform vec4 eyes_custom_color : source_color = vec4(0.15, 0.45, 0.85, 1.0);
uniform float enable_eye_tint : hint_range(0.0, 1.0) = 1.0;
uniform float light_hair_mode : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 out_color = tex_color;

	if (tex_color.a >= 0.05) {
		float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
		float maxc = max(tex_color.r, max(tex_color.g, tex_color.b));
		float minc = min(tex_color.r, min(tex_color.g, tex_color.b));
		float sat = maxc - minc;

		bool is_outline = brightness < 0.06 && sat < 0.05;
		bool is_skin = (tex_color.r > 0.55 && tex_color.g > 0.35 && tex_color.r > tex_color.b && (tex_color.r - tex_color.b) > 0.12);
		bool is_eye = enable_eye_tint > 0.5
			&& !is_skin
			&& sat > 0.18
			&& brightness > 0.12 && brightness < 0.72
			&& tex_color.b > tex_color.r * 0.55;
		bool is_dark_hair = (brightness < 0.28 && !is_skin && !is_eye);
		bool is_light_hair = light_hair_mode > 0.5
			&& !is_skin && !is_eye
			&& brightness >= 0.45 && brightness < 0.92
			&& sat < 0.22
			&& abs(tex_color.r - tex_color.g) < 0.12
			&& abs(tex_color.g - tex_color.b) < 0.12;
		bool is_hair = is_dark_hair || is_light_hair;

		if (!is_outline) {
			if (is_eye) {
				float factor = mix(0.55, 1.35, brightness);
				out_color = vec4(eyes_custom_color.rgb * factor, tex_color.a);
			} else if (is_hair) {
				float factor = max(brightness * 2.2, 0.25);
				if (is_light_hair) {
					factor = mix(0.55, 1.25, brightness);
				}
				out_color = vec4(hair_custom_color.rgb * factor, tex_color.a);
			} else if (!is_skin && brightness >= 0.28) {
				float intensity = brightness * 1.6;
				out_color = vec4(clothes_custom_color.rgb * intensity, tex_color.a);
			}
		}
	}

	COLOR = out_color;
}
