class_name CanonHatsuVisualCatalog
extends RefCounted

# ============================================================
# Visuais canônicos de Hatsu inspirados no anime (somente cosmético).
# IDs alinhados a CanonHatsuCatalog.
# ============================================================

const VisualProfileScript = preload("res://resource/hatsu/VisualProfile.gd")


static func obter_perfil(id_hatsu: String) -> Resource:
	var vp = VisualProfileScript.new()
	match id_hatsu:
		# --- GON: Jajanken ---
		"gon_jajanken_pedra":
			_paint(vp, Color(0.35, 0.95, 0.45), Color(0.9, 1.0, 0.55), Color(1.0, 1.0, 0.85), Color(0.25, 1.0, 0.4, 0.85))
			vp.shape = VisualProfileScript.VisualShape.FIST
			vp.visual_scale = 1.35
			vp.glow_intensity = 1.2
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.particle_amount = 10
			vp.cast_effect = "spark_burst"
			vp.impact_effect = "shockwave"
		"gon_jajanken_tesoura":
			_paint(vp, Color(0.45, 1.0, 0.7), Color(0.85, 1.0, 0.95), Color(1, 1, 1), Color(0.3, 0.95, 0.65, 0.8))
			vp.shape = VisualProfileScript.VisualShape.BLADE
			vp.visual_scale = 1.2
			vp.glow_intensity = 1.1
			vp.trail_enabled = true
			vp.trail_color = Color(0.4, 1.0, 0.7, 0.55)
			vp.trail_length = 10
			vp.trail_width = 4.0
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "spark_burst"
		"gon_jajanken_papel":
			_paint(vp, Color(0.55, 1.0, 0.55), Color(0.85, 1.0, 0.75), Color(1.0, 1.0, 0.9), Color(0.45, 1.0, 0.5, 0.75))
			vp.shape = VisualProfileScript.VisualShape.SPHERE
			vp.visual_scale = 1.15
			vp.glow_intensity = 1.0
			vp.trail_enabled = true
			vp.trail_color = Color(0.5, 1.0, 0.55, 0.5)
			vp.trail_length = 14
			vp.trail_width = 7.0
			vp.particle_enabled = true
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"

		# --- KILLUA ---
		"killua_kanmuru":
			_paint(vp, Color(0.55, 0.85, 1.0), Color(0.9, 0.98, 1.0), Color(1, 1, 1), Color(0.4, 0.8, 1.0, 0.85))
			vp.shape = VisualProfileScript.VisualShape.AURA
			vp.visual_scale = 1.4
			vp.glow_intensity = 1.35
			vp.trail_enabled = true
			vp.trail_color = Color(0.6, 0.9, 1.0, 0.55)
			vp.trail_length = 16
			vp.trail_width = 5.0
			vp.particle_enabled = true
			vp.particle_amount = 14
			vp.particle_speed = 55.0
			vp.cast_effect = "spark_burst"
			vp.impact_effect = "spark_burst"
		"killua_narukami":
			_paint(vp, Color(0.45, 0.8, 1.0), Color(0.95, 1.0, 1.0), Color(1, 1, 1), Color(0.35, 0.75, 1.0, 0.9))
			vp.shape = VisualProfileScript.VisualShape.RAY
			vp.visual_scale = 1.45
			vp.glow_intensity = 1.4
			vp.trail_enabled = true
			vp.trail_color = Color(0.5, 0.85, 1.0, 0.65)
			vp.trail_length = 18
			vp.trail_width = 3.5
			vp.particle_enabled = true
			vp.cast_effect = "spark_burst"
			vp.impact_effect = "spark_burst"

		# --- KITE ---
		"kite_crazy_slots":
			_paint(vp, Color(0.95, 0.25, 0.35), Color(1.0, 0.85, 0.2), Color(1, 1, 1), Color(1.0, 0.4, 0.3, 0.75))
			vp.shape = VisualProfileScript.VisualShape.DISC
			vp.visual_scale = 1.3
			vp.glow_intensity = 1.1
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"

		# --- NETERO ---
		"netero_guanyin":
			_paint(vp, Color(1.0, 0.92, 0.55), Color(1.0, 0.75, 0.25), Color(1.0, 1.0, 0.9), Color(1.0, 0.85, 0.35, 0.8))
			vp.shape = VisualProfileScript.VisualShape.AURA
			vp.visual_scale = 1.6
			vp.glow_intensity = 1.25
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.particle_amount = 12
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"

		# --- KURAPIKA ---
		"kurapika_emperor_time":
			_paint(vp, Color(0.85, 0.08, 0.12), Color(1.0, 0.35, 0.25), Color(1.0, 0.85, 0.85), Color(0.9, 0.1, 0.15, 0.85))
			vp.shape = VisualProfileScript.VisualShape.RING
			vp.visual_scale = 1.35
			vp.glow_intensity = 1.3
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"
		"kurapika_holy_chain":
			_paint(vp, Color(0.95, 0.9, 0.55), Color(1.0, 1.0, 0.85), Color(1.0, 1.0, 0.95), Color(0.9, 0.85, 0.4, 0.7))
			vp.shape = VisualProfileScript.VisualShape.CHAIN
			vp.visual_scale = 1.15
			vp.glow_intensity = 0.95
			vp.trail_enabled = true
			vp.trail_color = Color(0.95, 0.9, 0.5, 0.45)
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "none"
		"kurapika_chain_jail":
			_paint(vp, Color(0.75, 0.78, 0.85), Color(0.45, 0.5, 0.6), Color(0.95, 0.95, 1.0), Color(0.6, 0.65, 0.8, 0.7))
			vp.shape = VisualProfileScript.VisualShape.CHAIN
			vp.visual_scale = 1.35
			vp.glow_intensity = 1.05
			vp.trail_enabled = true
			vp.trail_color = Color(0.7, 0.75, 0.9, 0.55)
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"
		"kurapika_judgement_chain":
			_paint(vp, Color(0.9, 0.15, 0.2), Color(0.7, 0.7, 0.75), Color(1.0, 0.9, 0.9), Color(0.85, 0.2, 0.25, 0.8))
			vp.shape = VisualProfileScript.VisualShape.CHAIN
			vp.visual_scale = 1.25
			vp.glow_intensity = 1.15
			vp.trail_enabled = true
			vp.trail_color = Color(0.9, 0.25, 0.3, 0.5)
			vp.cast_effect = "spark_burst"
			vp.impact_effect = "shockwave"
		"kurapika_dowsing_chain":
			_paint(vp, Color(0.85, 0.85, 0.9), Color(0.55, 0.75, 1.0), Color(1, 1, 1), Color(0.6, 0.8, 1.0, 0.65))
			vp.shape = VisualProfileScript.VisualShape.CHAIN
			vp.visual_scale = 1.0
			vp.glow_intensity = 0.9
			vp.trail_enabled = true
			vp.trail_color = Color(0.7, 0.85, 1.0, 0.45)
			vp.trail_length = 16
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "spark_burst"

		# --- HISOKA ---
		"hisoka_bungee_gum":
			_paint(vp, Color(0.95, 0.25, 0.65), Color(1.0, 0.55, 0.8), Color(1.0, 0.85, 0.95), Color(0.9, 0.2, 0.55, 0.75))
			vp.shape = VisualProfileScript.VisualShape.GUM
			vp.visual_scale = 1.2
			vp.glow_intensity = 1.05
			vp.trail_enabled = true
			vp.trail_color = Color(0.95, 0.3, 0.7, 0.55)
			vp.trail_length = 20
			vp.trail_width = 5.5
			vp.particle_enabled = true
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"

		# --- FEITAN ---
		"feitan_pain_packer":
			_paint(vp, Color(1.0, 0.45, 0.1), Color(1.0, 0.85, 0.2), Color(1.0, 1.0, 0.7), Color(1.0, 0.35, 0.05, 0.85))
			vp.shape = VisualProfileScript.VisualShape.SUN
			vp.visual_scale = 1.7
			vp.glow_intensity = 1.45
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.particle_amount = 16
			vp.cast_effect = "spark_burst"
			vp.impact_effect = "shockwave"

		# --- LEORIO ---
		"leorio_remote_punch":
			_paint(vp, Color(0.35, 0.55, 0.95), Color(0.7, 0.85, 1.0), Color(1, 1, 1), Color(0.4, 0.6, 1.0, 0.75))
			vp.shape = VisualProfileScript.VisualShape.FIST
			vp.visual_scale = 1.5
			vp.glow_intensity = 1.1
			vp.trail_enabled = true
			vp.trail_color = Color(0.45, 0.65, 1.0, 0.45)
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"

		# --- CHROLLO ---
		"chrollo_skill_hunter":
			_paint(vp, Color(0.55, 0.15, 0.65), Color(0.85, 0.45, 0.95), Color(1.0, 0.9, 1.0), Color(0.5, 0.2, 0.7, 0.8))
			vp.shape = VisualProfileScript.VisualShape.BOOK
			vp.visual_scale = 1.3
			vp.glow_intensity = 1.15
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "none"
		"chrollo_indoor_fish":
			_paint(vp, Color(0.35, 0.75, 0.95), Color(0.7, 0.95, 1.0), Color(0.95, 1.0, 1.0), Color(0.3, 0.7, 0.95, 0.7))
			vp.shape = VisualProfileScript.VisualShape.PARTICLES
			vp.visual_scale = 1.25
			vp.glow_intensity = 1.0
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.particle_amount = 16
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"

		# --- ZENO ---
		"zeno_dragon_head":
			_paint(vp, Color(0.55, 0.9, 0.75), Color(0.85, 1.0, 0.9), Color(1, 1, 1), Color(0.4, 0.95, 0.7, 0.8))
			vp.shape = VisualProfileScript.VisualShape.DRAGON
			vp.visual_scale = 1.4
			vp.glow_intensity = 1.2
			vp.trail_enabled = true
			vp.trail_color = Color(0.5, 0.95, 0.75, 0.55)
			vp.trail_length = 18
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"
		"zeno_dragon_dive":
			_paint(vp, Color(0.45, 0.95, 0.7), Color(0.8, 1.0, 0.9), Color(1, 1, 1), Color(0.35, 0.9, 0.65, 0.75))
			vp.shape = VisualProfileScript.VisualShape.DRAGON
			vp.visual_scale = 1.55
			vp.glow_intensity = 1.25
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.particle_amount = 14
			vp.cast_effect = "spark_burst"
			vp.impact_effect = "shockwave"

		# --- SILVA ---
		"silva_explosive_orbs":
			_paint(vp, Color(0.75, 0.55, 1.0), Color(0.95, 0.85, 1.0), Color(1, 1, 1), Color(0.65, 0.4, 1.0, 0.85))
			vp.shape = VisualProfileScript.VisualShape.SPHERE
			vp.visual_scale = 1.45
			vp.glow_intensity = 1.3
			vp.trail_enabled = true
			vp.trail_color = Color(0.7, 0.5, 1.0, 0.5)
			vp.particle_enabled = true
			vp.cast_effect = "aura_flash"
			vp.impact_effect = "shockwave"

		# --- MOREL ---
		"morel_deep_purple":
			_paint(vp, Color(0.45, 0.2, 0.65), Color(0.7, 0.45, 0.9), Color(0.9, 0.8, 1.0), Color(0.4, 0.15, 0.55, 0.7))
			vp.shape = VisualProfileScript.VisualShape.SMOKE
			vp.visual_scale = 1.4
			vp.glow_intensity = 0.95
			vp.trail_enabled = false
			vp.particle_enabled = true
			vp.particle_amount = 16
			vp.particle_speed = 25.0
			vp.cast_effect = "smoke"
			vp.impact_effect = "smoke"

		# --- ILLUMI ---
		"illumi_needle_people":
			_paint(vp, Color(0.35, 0.85, 0.45), Color(0.85, 1.0, 0.9), Color(1, 1, 1), Color(0.3, 0.8, 0.4, 0.7))
			vp.shape = VisualProfileScript.VisualShape.NEEDLE
			vp.visual_scale = 1.15
			vp.glow_intensity = 1.0
			vp.trail_enabled = true
			vp.trail_color = Color(0.4, 0.9, 0.5, 0.45)
			vp.trail_length = 12
			vp.trail_width = 2.5
			vp.cast_effect = "spark_burst"
			vp.impact_effect = "spark_burst"

		_:
			return null

	return vp


static func _paint(vp: Resource, primary: Color, secondary: Color, core: Color, glow: Color) -> void:
	vp.primary_color = primary
	vp.secondary_color = secondary
	vp.core_color = core
	vp.glow_color = glow
