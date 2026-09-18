shader_type canvas_item;

// ============================================================
// HUNTER ONLINE - SMART PIXEL ART COLOR CUSTOMIZER SHADER
// ============================================================
//
// Identifica inteligente pele, cabelo e roupa pela luminescência
// e matiz dos pixels do sprite, aplicando a cor personalizada da roupa
// com sombras e brilhos preservados.
//
// ============================================================

uniform vec4 hair_custom_color : source_color = vec4(0.15, 0.15, 0.15, 1.0);
uniform vec4 clothes_custom_color : source_color = vec4(0.2, 0.6, 0.3, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Preservar pixels transparentes ou contornos pretos puros
	if (tex_color.a < 0.05) {
		COLOR = tex_color;
	} else {
		float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
		
		// 1. Detecção de Pele (Tons quentes de pele)
		bool is_skin = (tex_color.r > 0.55 && tex_color.g > 0.35 && tex_color.r > tex_color.b && (tex_color.r - tex_color.b) > 0.12);
		
		// 2. Detecção de Cabelo (Pixels escuros superiores / escuros puros)
		bool is_hair = (brightness < 0.28 && !is_skin);
		
		if (is_hair) {
			// Aplicar cor de cabelo mantendo a sombra original
			float factor = max(brightness * 2.5, 0.3);
			COLOR = vec4(hair_custom_color.rgb * factor, tex_color.a);
		} else if (!is_skin && brightness >= 0.28) {
			// 3. Roupa (Tudo que não for pele nem cabelo)
			// Aplicar a cor da roupa multiplicada pela intensidade de brilho do pixel original
			float intensity = brightness * 1.6;
			COLOR = vec4(clothes_custom_color.rgb * intensity, tex_color.a);
		} else {
			// Manter pele e detalhes intocados
			COLOR = tex_color;
		}
	}
}
