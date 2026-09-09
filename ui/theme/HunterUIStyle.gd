class_name HunterUIStyle
extends RefCounted

# ============================================================
# HUNTER ONLINE — VISUAL DESIGN SYSTEM & THEME PALETTE
# ============================================================
#
# Identidade visual HxH: Licença Hunter + madeira/pergaminho antigo.
# Refs: Hunter License (creme/selo), tan #AD945D, dark green #006F44,
# madeira envelhecida e tinta sépia — sem navy moderno.
# Nen/combate mantém acentos (ciano/ouro/HP) para feedback legível.
# ============================================================

# 1. PALETA DE CORES GLOBAL — Licença Hunter / madeira & pergaminho
# Referência: Hunter License (creme, selo dourado, madeira envelhecida)
# + UI clássica de RPG pixel (wood / parchment kits).
const COLOR_HUNTER_GREEN        := Color(0.22, 0.55, 0.28, 1.0) # Verde musgo (selo Hunter)
const COLOR_HUNTER_GREEN_LIGHT  := Color(0.35, 0.70, 0.38, 1.0) # Verde destaque / Hover
const COLOR_HUNTER_GREEN_DARK   := Color(0.12, 0.22, 0.12, 0.98) # Verde madeira escura

const COLOR_GOLD                := Color(0.78, 0.58, 0.22, 1.0) # Bronze / ouro antigo
const COLOR_GOLD_LIGHT          := Color(0.92, 0.75, 0.35, 1.0) # Ouro de selo
const COLOR_GOLD_MUTED          := Color(0.62, 0.48, 0.22, 0.90) # Metal envelhecido

const COLOR_AURA_CYAN           := Color(0.25, 0.72, 0.85, 1.0) # Ciano Nen (mantido p/ feedback)
const COLOR_AURA_BLUE           := Color(0.20, 0.45, 0.75, 1.0)
const COLOR_AURA_PURPLE         := Color(0.55, 0.32, 0.70, 1.0)

# Fundos: pergaminho / madeira (NÃO navy moderno) — um pouco mais escuros p/ contraste
const COLOR_BG_NAVY             := Color(0.14, 0.09, 0.05, 0.95) # Madeira escura de fundo
const COLOR_PANEL_PETROL        := Color(0.74, 0.64, 0.44, 0.97) # Pergaminho principal (mais escuro)
const COLOR_PANEL_CARD          := Color(0.66, 0.55, 0.36, 0.96) # Pergaminho interno
const COLOR_PANEL_SLOT          := Color(0.28, 0.17, 0.08, 0.94) # Entalhe de madeira

const COLOR_BORDER_GOLD         := Color(0.48, 0.30, 0.12, 1.0) # Borda madeira escura
const COLOR_BORDER_GREEN        := Color(0.30, 0.48, 0.24, 0.95) # Borda musgo
const COLOR_BORDER_CYAN         := Color(0.30, 0.65, 0.75, 0.9) # Borda Nen (casos especiais)
const COLOR_BORDER_SUBTLE       := Color(0.40, 0.28, 0.15, 0.80) # Borda madeira suave

const COLOR_TEXT_PRIMARY        := Color(0.06, 0.04, 0.03, 1.0) # Tinta quase preta (legível no pergaminho)
const COLOR_TEXT_SECONDARY      := Color(0.22, 0.14, 0.08, 1.0) # Marrom escuro
const COLOR_TEXT_GOLD           := Color(0.32, 0.20, 0.08, 1.0) # Destaque bronze escuro (não amarelo)
const COLOR_TEXT_CYAN           := Color(0.10, 0.35, 0.48, 1.0) # Tint Nen escuro
const COLOR_TEXT_MUTED          := Color(0.38, 0.28, 0.18, 1.0) # Texto apagado

# 1.1 HIERARQUIA TIPOGRÁFICA (VIEWPORT 640x360)
const FONT_SIZE_TITLE           := 13 # Cabeçalhos principais e nomes de chefes (Teko)
const FONT_SIZE_SUBTITLE        := 10 # Subtítulos, abas e nomes de regiões (Rajdhani)
const FONT_SIZE_HEADING         := 10 # Cabeçalhos de seção e títulos de cards (Rajdhani)
const FONT_SIZE_BODY            := 8  # Diálogos, objetivos e descrições (Silkscreen/Pixel)
const FONT_SIZE_SMALL           := 7  # Números de HP/AP/XP e tooltips (Silkscreen)
const FONT_SIZE_MICRO           := 6  # Badges e hotkeys de atalho ([E], [1-4])
const FONT_SIZE_NUMERIC         := 11 # Números destacados de atributos e níveis (Rajdhani)
const FONT_SIZE_DAMAGE          := 10 # Números de dano flutuante em combate

const COLOR_HP_CRIMSON          := Color(0.92, 0.22, 0.25, 1.0) # Barra de HP
const COLOR_AURA_BAR            := Color(0.18, 0.75, 1.00, 1.0) # Barra de Aura
const COLOR_XP_BAR              := Color(0.15, 0.82, 0.42, 1.0) # Barra de XP Normal
const COLOR_NEN_XP_BAR          := Color(0.70, 0.40, 1.00, 1.0) # Barra de XP Nen

# 1.2 CORES CANÔNICAS DAS TÉCNICAS DE NEN
const COLOR_TEN                 := Color(0.20, 0.85, 0.45, 1.0) # Ten (Verde Proteção / Defesa)
const COLOR_REN                 := Color(0.95, 0.35, 0.20, 1.0) # Ren (Laranja/Vermelho Força Explosiva)
const COLOR_ZETSU               := Color(0.40, 0.80, 0.95, 1.0) # Zetsu (Ciano Suave / Furtividade)
const COLOR_GYO                 := Color(1.00, 0.85, 0.20, 1.0) # Gyo (Amarelo Foco Ocular)
const COLOR_KO                  := Color(1.00, 0.40, 0.10, 1.0) # Ko (Âmbar/Laranja Ataque Total)
const COLOR_EN                  := Color(0.30, 0.90, 1.00, 1.0) # En (Ciano Expansão de Esfera)
const COLOR_KEN                 := Color(0.80, 0.70, 0.25, 1.0) # Ken (Ouro Defesa Geral)
const COLOR_RYU                 := Color(0.90, 0.50, 0.80, 1.0) # Ryu (Magenta Distribuição)
const COLOR_SHU                 := Color(0.60, 0.40, 0.90, 1.0) # Shu (Violeta Revestimento)


# 1.1.1 FONTES OFICIAIS HUNTER X HUNTER & PIXEL RPG
static var _font_title: Font = null
static var _font_license: Font = null
static var _font_pixel: Font = null
static var _font_pixel_bold: Font = null

static func get_font_title() -> Font:
	if _font_title == null:
		if ResourceLoader.exists("res://assets/fonts/HunterTitle_Teko.ttf"):
			_font_title = load("res://assets/fonts/HunterTitle_Teko.ttf")
	return _font_title

static func get_font_license() -> Font:
	if _font_license == null:
		if ResourceLoader.exists("res://assets/fonts/HunterLicense_Rajdhani.ttf"):
			_font_license = load("res://assets/fonts/HunterLicense_Rajdhani.ttf")
	return _font_license

static func get_font_pixel() -> Font:
	if _font_pixel == null:
		if ResourceLoader.exists("res://assets/fonts/HunterPixel_Silkscreen.ttf"):
			_font_pixel = load("res://assets/fonts/HunterPixel_Silkscreen.ttf")
	return _font_pixel

static func get_font_pixel_bold() -> Font:
	if _font_pixel_bold == null:
		if ResourceLoader.exists("res://assets/fonts/HunterPixel_Silkscreen_Bold.ttf"):
			_font_pixel_bold = load("res://assets/fonts/HunterPixel_Silkscreen_Bold.ttf")
	return _font_pixel_bold

static func aplicar_fonte_titulo(node: Control, tamanho: int = FONT_SIZE_TITLE, cor: Color = COLOR_TEXT_PRIMARY) -> void:
	if node == null: return
	var f = get_font_title()
	if f != null:
		node.add_theme_font_override("font", f)
	node.add_theme_font_size_override("font_size", tamanho)
	node.add_theme_color_override("font_color", cor)

static func aplicar_fonte_licenca(node: Control, tamanho: int = FONT_SIZE_HEADING, cor: Color = COLOR_TEXT_PRIMARY) -> void:
	if node == null: return
	var f = get_font_license()
	if f != null:
		node.add_theme_font_override("font", f)
	node.add_theme_font_size_override("font_size", tamanho)
	node.add_theme_color_override("font_color", cor)

static func aplicar_fonte_pixel(node: Control, tamanho: int = FONT_SIZE_BODY, cor: Color = COLOR_TEXT_PRIMARY) -> void:
	if node == null: return
	var f = get_font_pixel()
	if f != null:
		node.add_theme_font_override("font", f)
	node.add_theme_font_size_override("font_size", tamanho)
	node.add_theme_color_override("font_color", cor)

static func aplicar_fonte_pixel_bold(node: Control, tamanho: int = FONT_SIZE_BODY, cor: Color = COLOR_TEXT_PRIMARY) -> void:
	if node == null: return
	var f = get_font_pixel_bold()
	if f != null:
		node.add_theme_font_override("font", f)
	node.add_theme_font_size_override("font_size", tamanho)
	node.add_theme_color_override("font_color", cor)

# 1.2 CORES DE COMBATE & FEEDBACK DINÂMICO
const COLOR_CRIT_GOLD           := Color(1.00, 0.88, 0.25, 1.0) # Acerto Crítico
const COLOR_DODGE_CYAN          := Color(0.30, 0.95, 1.00, 1.0) # Esquiva / Perfect Dodge
const COLOR_BLOCK_STEEL         := Color(0.65, 0.75, 0.90, 1.0) # Bloqueio / Ten
const COLOR_WEAK_ORANGE         := Color(1.00, 0.45, 0.15, 1.0) # Ponto Fraco / Weak Point
const COLOR_HEAL_GREEN          := Color(0.25, 1.00, 0.45, 1.0) # Regeneração de HP
const COLOR_DANGER_RED          := Color(0.95, 0.20, 0.20, 1.0) # Perigo / Alerta Máximo


# ============================================================
# FACTORY: PAINÉIS & JANELAS
# ============================================================

static func criar_style_painel_principal(cor_borda: Color = COLOR_BORDER_GOLD, raio: int = 4) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_PETROL
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = cor_borda
	style.corner_radius_top_left = raio
	style.corner_radius_top_right = raio
	style.corner_radius_bottom_right = raio
	style.corner_radius_bottom_left = raio
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 1)
	return style


static func criar_style_card_interno(cor_borda: Color = COLOR_BORDER_GREEN, raio: int = 3) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_CARD
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = cor_borda
	style.corner_radius_top_left = raio
	style.corner_radius_top_right = raio
	style.corner_radius_bottom_right = raio
	style.corner_radius_bottom_left = raio
	return style


static func criar_style_box(cor_bg: Color, cor_borda: Color = Color.TRANSPARENT, raio: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = cor_bg
	if cor_borda != Color.TRANSPARENT:
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = cor_borda
	style.corner_radius_top_left = raio
	style.corner_radius_top_right = raio
	style.corner_radius_bottom_right = raio
	style.corner_radius_bottom_left = raio
	return style


static func criar_style_card_nen(ativa: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.72, 0.58, 0.36, 0.98) if ativa else Color(0.80, 0.68, 0.48, 0.94)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_AURA_CYAN if ativa else COLOR_BORDER_SUBTLE
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	if ativa:
		style.shadow_color = Color(0.2, 0.8, 1.0, 0.3)
		style.shadow_size = 2
	return style


static func criar_style_unit_frame() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.72, 0.62, 0.42, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_BORDER_GOLD
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0.12, 0.06, 0.02, 0.55)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	return style


static func criar_style_action_slot(ativo: bool = false, cooldown: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if cooldown:
		style.bg_color = Color(0.28, 0.18, 0.10, 0.90)
		style.border_color = Color(0.45, 0.35, 0.22, 0.6)
	elif ativo:
		style.bg_color = Color(0.42, 0.28, 0.14, 0.98)
		style.border_color = COLOR_AURA_CYAN
		style.shadow_color = Color(0.2, 0.85, 1.0, 0.35)
		style.shadow_size = 3
	else:
		style.bg_color = COLOR_PANEL_SLOT
		style.border_color = COLOR_BORDER_SUBTLE

	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style


static func criar_style_quest_tracker() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.74, 0.64, 0.42, 0.94)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_BORDER_GOLD
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	style.shadow_color = Color(0.1, 0.05, 0.02, 0.4)
	style.shadow_size = 3
	return style


static func criar_style_overhead_badge(cor_borda: Color = COLOR_BORDER_SUBTLE) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.28, 0.18, 0.10, 0.90)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = cor_borda
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style


static func criar_style_card_personagem(cor_borda: Color = COLOR_BORDER_GOLD, raio: int = 4) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.84, 0.72, 0.52, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = cor_borda
	style.corner_radius_top_left = raio
	style.corner_radius_top_right = raio
	style.corner_radius_bottom_right = raio
	style.corner_radius_bottom_left = raio
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 3
	return style


static func criar_style_licenca_hunter() -> StyleBoxFlat:
	# Moldura madeira escura + pergaminho (refs Mini Medieval / Fantasy HUD)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.72, 0.60, 0.40, 0.97)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.28, 0.16, 0.08, 1.0)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	style.shadow_color = Color(0.05, 0.02, 0.01, 0.7)
	style.shadow_size = 3
	style.shadow_offset = Vector2(1, 2)
	return style


## Moldura individual de barra (HP/Aura/XP) — NÃO coladas
static func criar_style_barra_frame_madeira() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.22, 0.13, 0.07, 0.94)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.55, 0.38, 0.18, 1.0)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_right = 1
	style.corner_radius_bottom_left = 1
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	return style


## Frame madeira texturizado (PixelLab) — fallback para flat se asset ausente
static func criar_style_barra_frame_texturado() -> StyleBox:
	# Preferir recorte retangular 9-slice; kit completo só como fallback
	var path_frame := "res://assets/sprites/ui/hud_wood_panel_frame.png"
	var path_kit := "res://assets/sprites/ui/hud_wood_panel_kit.png"
	var path := path_frame if ResourceLoader.exists(path_frame) else path_kit
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path)
		var st := StyleBoxTexture.new()
		st.texture = tex
		# Margens menores no frame recortado (~163x72); kit 256 usa margem maior
		var is_frame := path == path_frame
		var m := 14 if is_frame else 24
		st.texture_margin_left = m
		st.texture_margin_top = m
		st.texture_margin_right = m
		st.texture_margin_bottom = m
		st.content_margin_left = 4
		st.content_margin_right = 4
		st.content_margin_top = 3
		st.content_margin_bottom = 3
		st.modulate_color = Color(0.92, 0.88, 0.78, 1.0)
		return st
	return criar_style_barra_frame_madeira()


static func criar_style_progress_bg_pixel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.07, 0.04, 0.98)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.08, 0.05, 0.02, 1.0)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_right = 0
	style.corner_radius_bottom_left = 0
	return style


static func criar_style_progress_fill_pixel(cor: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	# Tom base + “faixa” clara no topo via expand_margin simulado (cor um pouco mais clara)
	style.bg_color = cor
	style.border_width_top = 1
	style.border_color = Color(
		clampf(cor.r * 1.35 + 0.08, 0.0, 1.0),
		clampf(cor.g * 1.35 + 0.08, 0.0, 1.0),
		clampf(cor.b * 1.25 + 0.05, 0.0, 1.0),
		1.0
	)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_right = 0
	style.corner_radius_bottom_left = 0
	return style


static func criar_style_hunter_badge(cor_borda: Color = COLOR_GOLD_LIGHT, cor_fundo: Color = Color(0.34, 0.22, 0.12, 0.95)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = cor_fundo
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = cor_borda
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func criar_style_boss_banner() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.03, 0.05, 0.95)
	style.border_width_left = 2
	style.border_width_top = 1
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_HP_CRIMSON
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.shadow_color = Color(0.8, 0.1, 0.1, 0.35)
	style.shadow_size = 4
	return style


static func criar_style_condition_box(atendida: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.55, 0.70, 0.42, 0.88) if atendida else Color(0.78, 0.66, 0.48, 0.88)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_BORDER_GREEN if atendida else COLOR_BORDER_SUBTLE
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func criar_style_floating_text(cor_borda: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.03, 0.05, 0.75)
	if cor_borda != Color.TRANSPARENT:
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = cor_borda
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func criar_style_boss_phase_badge() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.04, 0.05, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_HP_CRIMSON
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


# ============================================================
# FACTORY: BOTÕES & INTERAÇÕES
# ============================================================

static func criar_style_botao_normal(cor_borda: Color = COLOR_BORDER_GREEN) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.42, 0.28, 0.14, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = cor_borda
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style


static func criar_style_botao_hover() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.52, 0.36, 0.18, 0.98)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_GOLD_LIGHT
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	style.shadow_color = Color(0.78, 0.58, 0.22, 0.35)
	style.shadow_size = 2
	return style


static func criar_style_botao_pressed() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.30, 0.20, 0.10, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_GOLD
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style


static func criar_style_botao_focus() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.46, 0.32, 0.16, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_GOLD_LIGHT
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style


static func aplicar_estilo_botao(btn: Button, cor_borda: Color = COLOR_BORDER_GREEN) -> void:
	if btn == null: return
	btn.add_theme_stylebox_override("normal", criar_style_botao_normal(cor_borda))
	btn.add_theme_stylebox_override("hover", criar_style_botao_hover())
	btn.add_theme_stylebox_override("pressed", criar_style_botao_pressed())
	btn.add_theme_stylebox_override("focus", criar_style_botao_focus())
	btn.add_theme_color_override("font_color", Color(0.95, 0.88, 0.72, 1.0))
	btn.add_theme_color_override("font_hover_color", COLOR_GOLD_LIGHT)
	btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.92, 0.70, 1.0))


static func aplicar_estilo_botao_estado(btn: Button, estado: String) -> void:
	if btn == null: return
	match estado.to_lower():
		"danger":
			btn.add_theme_stylebox_override("normal", criar_style_botao_normal(COLOR_DANGER_RED))
			btn.add_theme_color_override("font_color", COLOR_DANGER_RED)
		"selected", "special":
			btn.add_theme_stylebox_override("normal", criar_style_botao_normal(COLOR_BORDER_GOLD))
			btn.add_theme_color_override("font_color", COLOR_GOLD_LIGHT)
		"available":
			btn.add_theme_stylebox_override("normal", criar_style_botao_normal(COLOR_BORDER_CYAN))
			btn.add_theme_color_override("font_color", COLOR_AURA_CYAN)
		"disabled", "locked":
			btn.add_theme_stylebox_override("normal", criar_style_botao_normal(COLOR_BORDER_SUBTLE))
			btn.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
			btn.disabled = true
		_:
			aplicar_estilo_botao(btn, COLOR_BORDER_GREEN)


# ============================================================
# FACTORY: BARRAS DE PROGRESSO (HP, AURA, XP)
# ============================================================

static func criar_style_progress_bg() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.22, 0.14, 0.08, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.45, 0.32, 0.18, 0.85)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func criar_style_progress_fill(cor_preenchimento: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = cor_preenchimento
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	return style


static func aplicar_estilo_progress_bar(bar: ProgressBar, cor_fill: Color) -> void:
	if bar == null: return
	bar.add_theme_stylebox_override("background", criar_style_progress_bg())
	bar.add_theme_stylebox_override("fill", criar_style_progress_fill(cor_fill))


# ============================================================
# FACTORY: TAB CONTAINER (ABAS ESTILIZADAS)
# ============================================================

static func aplicar_estilo_tab_container(tab_c: TabContainer) -> void:
	if tab_c == null: return

	var style_tab_selected := StyleBoxFlat.new()
	style_tab_selected.bg_color = Color(0.48, 0.32, 0.16, 0.98)
	style_tab_selected.border_width_left = 1
	style_tab_selected.border_width_top = 2
	style_tab_selected.border_width_right = 1
	style_tab_selected.border_color = COLOR_GOLD
	style_tab_selected.corner_radius_top_left = 3
	style_tab_selected.corner_radius_top_right = 3
	style_tab_selected.content_margin_left = 5
	style_tab_selected.content_margin_right = 5
	style_tab_selected.content_margin_top = 2
	style_tab_selected.content_margin_bottom = 2

	var style_tab_unselected := StyleBoxFlat.new()
	style_tab_unselected.bg_color = Color(0.32, 0.20, 0.10, 0.90)
	style_tab_unselected.border_width_left = 1
	style_tab_unselected.border_width_top = 1
	style_tab_unselected.border_width_right = 1
	style_tab_unselected.border_color = COLOR_BORDER_SUBTLE
	style_tab_unselected.corner_radius_top_left = 3
	style_tab_unselected.corner_radius_top_right = 3
	style_tab_unselected.content_margin_left = 5
	style_tab_unselected.content_margin_right = 5
	style_tab_unselected.content_margin_top = 2
	style_tab_unselected.content_margin_bottom = 2

	var style_panel := StyleBoxFlat.new()
	style_panel.bg_color = COLOR_PANEL_PETROL
	style_panel.border_width_left = 1
	style_panel.border_width_top = 1
	style_panel.border_width_right = 1
	style_panel.border_width_bottom = 1
	style_panel.border_color = COLOR_BORDER_GOLD
	style_panel.corner_radius_bottom_left = 3
	style_panel.corner_radius_bottom_right = 3
	style_panel.content_margin_left = 4
	style_panel.content_margin_right = 4
	style_panel.content_margin_top = 4
	style_panel.content_margin_bottom = 4

	tab_c.add_theme_stylebox_override("tab_selected", style_tab_selected)
	tab_c.add_theme_stylebox_override("tab_unselected", style_tab_unselected)
	tab_c.add_theme_stylebox_override("tab_hovered", style_tab_selected)
	tab_c.add_theme_stylebox_override("panel", style_panel)
	tab_c.add_theme_color_override("font_selected_color", COLOR_GOLD_LIGHT)
	tab_c.add_theme_color_override("font_unselected_color", Color(0.78, 0.68, 0.50, 1.0))