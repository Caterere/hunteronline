class_name VisualProfile
extends Resource

# ============================================================
# HUNTER ONLINE - VISUAL PROFILE (HATSU COSMETICS RESOURCE)
# ============================================================
#
# Estrutura de dados puramente cosmética para customização visual de Hatsu.
# NÃO altera dano, custo de aura, cooldown, alcance físico ou balanceamento.
#
# ============================================================

enum VisualShape {
	SPHERE,       # 0. Esfera clássica de Nen concentrado
	CIRCLE,       # 1. Círculo plano / anel de energia
	BEAM,         # 2. Feixe / Raio linear canalizado
	RAY,          # 3. Descarga de arco elétrico
	BLADE,        # 4. Lâmina / Meia-lua cortante
	DISC,         # 5. Disco rotativo de alta rotação
	CONE,         # 6. Cone / Dispersão angular
	RING,         # 7. Ondas de choque circulares concêntricas
	LINE,         # 8. Linha de traço tático
	AURA,         # 9. Chama / Miasma pulsante envolvente
	PARTICLES     # 10. Enxame de orbes cintilantes
}

# Paleta Canônica Pré-definida
const PALETTE: Dictionary = {
	"vermelho": Color(1.0, 0.16, 0.16, 1.0),
	"vermelho_escuro": Color(0.55, 0.0, 0.0, 1.0),
	"laranja": Color(1.0, 0.50, 0.0, 1.0),
	"amarelo": Color(1.0, 0.85, 0.0, 1.0),
	"verde": Color(0.0, 0.90, 0.25, 1.0),
	"verde_claro": Color(0.46, 1.0, 0.01, 1.0),
	"ciano": Color(0.0, 0.90, 1.0, 1.0),
	"azul": Color(0.12, 0.53, 0.90, 1.0),
	"azul_escuro": Color(0.05, 0.28, 0.63, 1.0),
	"roxo": Color(0.56, 0.14, 0.67, 1.0),
	"magenta": Color(0.83, 0.0, 0.98, 1.0),
	"rosa": Color(1.0, 0.25, 0.51, 1.0),
	"branco": Color(1.0, 1.0, 1.0, 1.0),
	"cinza": Color(0.46, 0.46, 0.46, 1.0),
	"preto": Color(0.10, 0.10, 0.10, 1.0)
}

# ------------------------------------------------------------
# CORES PRINCIPAIS
# ------------------------------------------------------------
@export_group("Colors")
@export var primary_color: Color = Color(0.12, 0.53, 0.90, 1.0) # Azul
@export var secondary_color: Color = Color(1.0, 1.0, 1.0, 0.9)   # Branco
@export var core_color: Color = Color(1.0, 1.0, 1.0, 1.0)        # Branco puro
@export var glow_color: Color = Color(0.0, 0.90, 1.0, 0.75)      # Ciano

# ------------------------------------------------------------
# FORMATO & ESCALA VISUAL
# ------------------------------------------------------------
@export_group("Shape & Scale")
@export var shape: VisualShape = VisualShape.SPHERE
@export var visual_scale: float = 1.0 # Cosmético (NÃO altera hitbox)

# ------------------------------------------------------------
# BRILHO & INTENSIDADE
# ------------------------------------------------------------
@export_group("Glow")
@export var glow_intensity: float = 0.8 # 0.0 a 1.5

# ------------------------------------------------------------
# RASTRO (TRAIL)
# ------------------------------------------------------------
@export_group("Trail")
@export var trail_enabled: bool = true
@export var trail_color: Color = Color(0.0, 0.90, 1.0, 0.60)
@export var trail_length: int = 12
@export var trail_width: float = 6.0

# ------------------------------------------------------------
# PARTÍCULAS LEVES (PERFORMANCE MMORPG)
# ------------------------------------------------------------
@export_group("Particles")
@export var particle_enabled: bool = false
@export var particle_amount: int = 8
@export var particle_size: float = 2.0
@export var particle_speed: float = 30.0
@export var particle_lifetime: float = 0.4

# ------------------------------------------------------------
# EFEITOS DE CAST E IMPACTO
# ------------------------------------------------------------
@export_group("Effects")
@export var cast_effect: String = "aura_flash" # "none", "aura_flash", "spark_burst", "smoke"
@export var impact_effect: String = "shockwave" # "none", "shockwave", "spark_burst", "smoke"

# ------------------------------------------------------------
# HERANÇA DA ASSINATURA DE AURA DO PERSONAGEM
# ------------------------------------------------------------
@export_group("Aura Inheritance")
@export var inherit_aura_visual: bool = false
@export var inheritance_strength: float = 0.7 # 0.0 a 1.0


# ============================================================
# MÉTODOS ESTÁTICOS DA PALETA
# ============================================================

static func get_palette_color(color_name: String) -> Color:
	var key: String = color_name.to_lower().strip_edges().replace(" ", "_")
	return PALETTE.get(key, PALETTE["azul"])


static func get_palette_names() -> Array[String]:
	var names: Array[String] = []
	for k in PALETTE.keys():
		names.append(str(k))
	return names


# ============================================================
# SERIALIZAÇÃO & CLONAGEM
# ============================================================

const SelfClass = preload("res://resource/hatsu/VisualProfile.gd")

func clone() -> Resource:
	var copy = SelfClass.new()
	copy.primary_color = primary_color
	copy.secondary_color = secondary_color
	copy.core_color = core_color
	copy.glow_color = glow_color
	copy.shape = shape
	copy.visual_scale = visual_scale
	copy.glow_intensity = glow_intensity
	copy.trail_enabled = trail_enabled
	copy.trail_color = trail_color
	copy.trail_length = trail_length
	copy.trail_width = trail_width
	copy.particle_enabled = particle_enabled
	copy.particle_amount = particle_amount
	copy.particle_size = particle_size
	copy.particle_speed = particle_speed
	copy.particle_lifetime = particle_lifetime
	copy.cast_effect = cast_effect
	copy.impact_effect = impact_effect
	copy.inherit_aura_visual = inherit_aura_visual
	copy.inheritance_strength = inheritance_strength
	return copy


func to_dict() -> Dictionary:
	return {
		"primary_color": primary_color.to_html(true),
		"secondary_color": secondary_color.to_html(true),
		"core_color": core_color.to_html(true),
		"glow_color": glow_color.to_html(true),
		"shape": int(shape),
		"visual_scale": visual_scale,
		"glow_intensity": glow_intensity,
		"trail_enabled": trail_enabled,
		"trail_color": trail_color.to_html(true),
		"trail_length": trail_length,
		"trail_width": trail_width,
		"particle_enabled": particle_enabled,
		"particle_amount": particle_amount,
		"particle_size": particle_size,
		"particle_speed": particle_speed,
		"particle_lifetime": particle_lifetime,
		"cast_effect": cast_effect,
		"impact_effect": impact_effect,
		"inherit_aura_visual": inherit_aura_visual,
		"inheritance_strength": inheritance_strength
	}


static func from_dict(data: Dictionary) -> Resource:
	var vp := VisualProfile.new()
	if data.has("primary_color"):
		vp.primary_color = Color.from_string(data["primary_color"], Color(0.12, 0.53, 0.90, 1.0))
	if data.has("secondary_color"):
		vp.secondary_color = Color.from_string(data["secondary_color"], Color(1.0, 1.0, 1.0, 0.9))
	if data.has("core_color"):
		vp.core_color = Color.from_string(data["core_color"], Color(1.0, 1.0, 1.0, 1.0))
	if data.has("glow_color"):
		vp.glow_color = Color.from_string(data["glow_color"], Color(0.0, 0.90, 1.0, 0.75))
	
	vp.shape = int(data.get("shape", VisualShape.SPHERE))
	vp.visual_scale = float(data.get("visual_scale", 1.0))
	vp.glow_intensity = float(data.get("glow_intensity", 0.8))
	vp.trail_enabled = bool(data.get("trail_enabled", true))
	if data.has("trail_color"):
		vp.trail_color = Color.from_string(data["trail_color"], Color(0.0, 0.90, 1.0, 0.60))
	vp.trail_length = int(data.get("trail_length", 12))
	vp.trail_width = float(data.get("trail_width", 6.0))
	vp.particle_enabled = bool(data.get("particle_enabled", false))
	vp.particle_amount = int(data.get("particle_amount", 8))
	vp.particle_size = float(data.get("particle_size", 2.0))
	vp.particle_speed = float(data.get("particle_speed", 30.0))
	vp.particle_lifetime = float(data.get("particle_lifetime", 0.4))
	vp.cast_effect = str(data.get("cast_effect", "aura_flash"))
	vp.impact_effect = str(data.get("impact_effect", "shockwave"))
	vp.inherit_aura_visual = bool(data.get("inherit_aura_visual", false))
	vp.inheritance_strength = float(data.get("inheritance_strength", 0.7))
	return vp