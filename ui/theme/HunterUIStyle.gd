class_name HunterUIStyle
extends RefCounted

# ============================================================
# HUNTER ONLINE — VISUAL DESIGN SYSTEM & THEME PALETTE
# ============================================================
#
# Sistema Central de Identidade Visual inspirado na atmosfera
# de aventura shonen e RPG de Hunter x Hunter:
# - Paleta equilibrada: Verde Vibrante + Ouro/Âmbar + Ciano Nen + Midnight Navy.
# - Painéis com alto contraste, chanfros elegantes e bordas metálicas.
# - Botões com estados táteis visíveis (Normal, Hover, Pressed, Focus).
# - Barras de energia estilizadas (HP Vermelho, Aura Ciano, XP Verde/Ouro).
# - Estilo exclusivo para a interface e técnicas de Nen.
# ============================================================

# 1. PALETA DE CORES GLOBAL
const COLOR_HUNTER_GREEN        := Color(0.12, 0.76, 0.38, 1.0) # Verde Hunter Primário
const COLOR_HUNTER_GREEN_LIGHT  := Color(0.25, 0.92, 0.50, 1.0) # Verde Destaque / Hover
const COLOR_HUNTER_GREEN_DARK   := Color(0.05, 0.18, 0.11, 0.98) # Verde Fundo Escuro

const COLOR_GOLD                := Color(1.00, 0.82, 0.20, 1.0) # Ouro / Âmbar Hunter
const COLOR_GOLD_LIGHT          := Color(1.00, 0.92, 0.45, 1.0) # Ouro Brilhante / Destaque
const COLOR_GOLD_MUTED          := Color(0.85, 0.70, 0.25, 0.85) # Ouro Metálico Borda

const COLOR_AURA_CYAN           := Color(0.20, 0.88, 1.00, 1.0) # Ciano Nen / Aura
const COLOR_AURA_BLUE           := Color(0.12, 0.55, 0.95, 1.0) # Azul Profundo Nen
const COLOR_AURA_PURPLE         := Color(0.70, 0.35, 1.00, 1.0) # Roxo Especialista

const COLOR_BG_NAVY             := Color(0.04, 0.06, 0.10, 0.96) # Midnight Navy (Fundo Principal)
const COLOR_PANEL_PETROL        := Color(0.07, 0.10, 0.15, 0.98) # Painel Principal
const COLOR_PANEL_CARD          := Color(0.10, 0.14, 0.20, 0.95) # Sub-Card Interno
const COLOR_PANEL_SLOT          := Color(0.05, 0.08, 0.12, 0.90) # Slot Recuado

const COLOR_BORDER_GOLD         := Color(0.92, 0.75, 0.22, 1.0) # Borda Ouro
const COLOR_BORDER_GREEN        := Color(0.18, 0.75, 0.40, 0.9) # Borda Verde
const COLOR_BORDER_CYAN         := Color(0.25, 0.85, 1.00, 0.9) # Borda Ciano Nen
const COLOR_BORDER_SUBTLE       := Color(0.25, 0.32, 0.42, 0.7) # Borda Neutra

const COLOR_TEXT_PRIMARY        := Color(0.96, 0.95, 0.90, 1.0) # Creme / Branco Quente
const COLOR_TEXT_SECONDARY      := Color(0.70, 0.82, 0.78, 1.0) # Verde Menta Suave
const COLOR_TEXT_GOLD           := Color(1.00, 0.85, 0.25, 1.0) # Destaque Dourado
const COLOR_TEXT_CYAN           := Color(0.35, 0.90, 1.00, 1.0) # Destaque Aura
const COLOR_TEXT_MUTED          := Color(0.50, 0.58, 0.55, 1.0) # Texto Apagado

const COLOR_HP_CRIMSON          := Color(0.92, 0.22, 0.25, 1.0) # Barra de HP
const COLOR_AURA_BAR            := Color(0.18, 0.75, 1.00, 1.0) # Barra de Aura
const COLOR_XP_BAR              := Color(0.15, 0.82, 0.42, 1.0) # Barra de XP Normal
const COLOR_NEN_XP_BAR          := Color(0.70, 0.40, 1.00, 1.0) # Barra de XP Nen


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


static func criar_style_card_nen(ativa: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.10, 0.16, 0.96) if ativa else Color(0.06, 0.08, 0.12, 0.92)
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


# ============================================================
# FACTORY: BOTÕES & INTERAÇÕES
# ============================================================

static func criar_style_botao_normal(cor_borda: Color = COLOR_BORDER_GREEN) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.14, 0.18, 0.95)
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
	style.bg_color = Color(0.12, 0.28, 0.20, 0.98)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = COLOR_HUNTER_GREEN_LIGHT
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	style.shadow_color = Color(0.15, 0.8, 0.4, 0.35)
	style.shadow_size = 2
	return style


static func criar_style_botao_pressed() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.38, 0.24, 1.0)
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
	style.bg_color = Color(0.10, 0.18, 0.22, 0.95)
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
	btn.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	btn.add_theme_color_override("font_hover_color", COLOR_GOLD_LIGHT)
	btn.add_theme_color_override("font_pressed_color", COLOR_GOLD)


# ============================================================
# FACTORY: BARRAS DE PROGRESSO (HP, AURA, XP)
# ============================================================

static func criar_style_progress_bg() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.04, 0.06, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.25, 0.32, 0.8)
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
	style_tab_selected.bg_color = Color(0.08, 0.22, 0.14, 0.98)
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
	style_tab_unselected.bg_color = Color(0.05, 0.07, 0.10, 0.90)
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
	style_panel.bg_color = Color(0.06, 0.08, 0.12, 0.95)
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
	tab_c.add_theme_color_override("font_unselected_color", COLOR_TEXT_SECONDARY)