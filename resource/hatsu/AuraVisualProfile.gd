class_name AuraVisualProfile
extends Resource

const VisualProfile = preload("res://resource/hatsu/VisualProfile.gd")

# ============================================================
# HUNTER ONLINE - AURA VISUAL PROFILE (CHARACTER NEN SIGNATURE)
# ============================================================
#
# Representa a identidade e assinatura visual única da aura natural do personagem.
# Permite que habilidades Hatsu herdem e mesclem características visuais com a aura.
#
# ============================================================

@export_group("Character Aura Signature")
@export var aura_primary_color: Color = Color(0.12, 0.53, 0.90, 1.0) # Azul
@export var aura_secondary_color: Color = Color(1.0, 1.0, 1.0, 0.9)   # Branco
@export var aura_glow_color: Color = Color(0.0, 0.90, 1.0, 0.75)      # Ciano
@export var aura_intensity: float = 0.75                              # 0.0 a 1.0
@export var aura_style_name: String = "Sereno"                        # "Sereno", "Chamas", "Relâmpagos", "Sombrio"


# ============================================================
# MOTOR DE MESCLAGEM & HERANÇA VISUAL (BLENDING)
# ============================================================

const SelfClass = preload("res://resource/hatsu/AuraVisualProfile.gd")

func blend_with_hatsu(hatsu_profile: Resource) -> Resource:
	if hatsu_profile == null:
		var default_p = VisualProfile.new()
		default_p.primary_color = aura_primary_color
		default_p.secondary_color = aura_secondary_color
		default_p.glow_color = aura_glow_color
		default_p.glow_intensity = aura_intensity
		return default_p

	if not hatsu_profile.inherit_aura_visual:
		return hatsu_profile.clone()

	var weight: float = clamp(hatsu_profile.inheritance_strength, 0.0, 1.0)
	var resolved = hatsu_profile.clone()

	# Interpolação suave (lerp) das cores
	resolved.primary_color = hatsu_profile.primary_color.lerp(aura_primary_color, weight)
	resolved.secondary_color = hatsu_profile.secondary_color.lerp(aura_secondary_color, weight)
	resolved.glow_color = hatsu_profile.glow_color.lerp(aura_glow_color, weight)
	resolved.trail_color = hatsu_profile.trail_color.lerp(aura_glow_color, weight)
	resolved.glow_intensity = lerp(hatsu_profile.glow_intensity, aura_intensity, weight * 0.5)

	return resolved


# ============================================================
# SERIALIZAÇÃO
# ============================================================

func to_dict() -> Dictionary:
	return {
		"aura_primary_color": aura_primary_color.to_html(true),
		"aura_secondary_color": aura_secondary_color.to_html(true),
		"aura_glow_color": aura_glow_color.to_html(true),
		"aura_intensity": aura_intensity,
		"aura_style_name": aura_style_name
	}


static func from_dict(data: Dictionary) -> Resource:
	var ap = SelfClass.new()
	if data.has("aura_primary_color"):
		ap.aura_primary_color = Color.from_string(data["aura_primary_color"], Color(0.12, 0.53, 0.90, 1.0))
	if data.has("aura_secondary_color"):
		ap.aura_secondary_color = Color.from_string(data["aura_secondary_color"], Color(1.0, 1.0, 1.0, 0.9))
	if data.has("aura_glow_color"):
		ap.aura_glow_color = Color.from_string(data["aura_glow_color"], Color(0.0, 0.90, 1.0, 0.75))
	ap.aura_intensity = float(data.get("aura_intensity", 0.75))
	ap.aura_style_name = str(data.get("aura_style_name", "Sereno"))
	return ap