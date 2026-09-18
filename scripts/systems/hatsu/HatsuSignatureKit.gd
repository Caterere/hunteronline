class_name HatsuSignatureKit
extends RefCounted

const HatsuVisualScript = preload("res://scripts/visual/HatsuVisual.gd")

# ============================================================
# HUNTER ONLINE — HATSU SIGNATURE KIT (ULTIMATE FEEL)
# ============================================================
#
# Assinaturas legíveis estilo "ultimate" de MMO, adaptadas a Nen:
# cast telegraph → callout → impacto. Não cria combate paralelo.
#
# ============================================================

enum Kind {
	SKILL_HUNTER, ## Chrollo — livro / roubo
	DEVOUR, ## Meruem — absorção
	TERPSICHORA, ## Pitou — buff corporal
	DOCTOR_BLYTHE ## Pitou — cura médica massiva
}


static func telegraph_cast(caster: Node2D, hatsu: HatsuData, cast_time: float = 0.35) -> void:
	if caster == null or not is_instance_valid(caster):
		return
	var parent: Node = caster.get_parent() if caster.get_parent() != null else caster
	var cor: Color = Color(0.95, 0.85, 0.35)
	var raio: float = 46.0
	var pitch: float = 0.92
	var sfx := "hatsu_cast"
	if hatsu != null:
		if NenAffinityData != null:
			cor = NenAffinityData.obter_cor_afinidade(hatsu.categoria)
		raio = clampf(28.0 + float(hatsu.alcance) * 0.08, 36.0, 72.0)
		# Ordem de polish: Intensificação → Emissão → Transformação → Conjuração → Manipulação → Especialização
		match hatsu.categoria:
			HatsuData.Categoria.INTENSIFICACAO:
				raio *= 1.15
				pitch = 0.82
				sfx = "hatsu_cast"
			HatsuData.Categoria.EMISSAO:
				raio *= 1.25
				pitch = 1.05
			HatsuData.Categoria.TRANSFORMACAO:
				raio *= 1.05
				pitch = 1.15
			HatsuData.Categoria.CONJURACAO:
				raio *= 1.20
				pitch = 0.88
			HatsuData.Categoria.MANIPULACAO:
				raio *= 0.95
				pitch = 1.00
			HatsuData.Categoria.ESPECIALIZACAO:
				raio *= 1.30
				pitch = 0.78
			_:
				pass
	_spawn_cast_ring(parent, caster.global_position, raio, cor, maxf(0.12, cast_time))
	var bus = _event_bus()
	if bus != null and bus.has_method("emit_camera_shake"):
		bus.emit_camera_shake(0.18, 0.12)
	var audio = _audio_manager()
	if audio != null and audio.has_method("tocar_sfx_tipo"):
		audio.tocar_sfx_tipo(sfx, pitch)


static func play(kind: Kind, caster: Node2D, parent: Node = null, subtitle: String = "") -> void:
	if caster == null or not is_instance_valid(caster):
		return
	var map_parent: Node = parent
	if map_parent == null:
		map_parent = caster.get_parent() if caster.get_parent() != null else caster

	var meta: Dictionary = _meta(kind, subtitle)
	var cor: Color = meta.get("cor", Color(1, 1, 1))
	var titulo: String = str(meta.get("titulo", "Hatsu"))
	var sub: String = str(meta.get("sub", "Especialização"))
	var bus = _event_bus()

	# 1) Callout dramático (como ultimate banner)
	if bus != null:
		if bus.has_method("emit_hatsu_dramatic_callout"):
			bus.emit_hatsu_dramatic_callout(caster, titulo, sub, cor)
		if bus.has_method("emit_camera_shake"):
			bus.emit_camera_shake(float(meta.get("shake", 0.45)), float(meta.get("shake_dur", 0.22)))
		if bus.has_method("emit_toast"):
			bus.emit_toast(str(meta.get("toast", titulo)), cor)

	# 2) Telegraph no chão (cast circle)
	_spawn_cast_ring(map_parent, caster.global_position, float(meta.get("raio", 48.0)), cor, float(meta.get("cast_time", 0.35)))

	# 3) Burst de cast (assinatura visual distinta)
	var profile = _build_profile(kind, cor)
	if profile != null:
		HatsuVisualScript.spawn_cast_effect(caster.global_position, profile, map_parent)
		if bool(meta.get("impact", true)):
			HatsuVisualScript.spawn_impact_effect(caster.global_position, profile, map_parent)

	# 4) SFX tipado
	var audio = _audio_manager()
	if audio != null and audio.has_method("tocar_sfx_tipo"):
		audio.tocar_sfx_tipo(str(meta.get("sfx", "hatsu_cast")), float(meta.get("pitch", 1.0)))

	# 5) Balloon curto (legibilidade imediata)
	if caster.has_method("falar_balao"):
		caster.call("falar_balao", str(meta.get("balloon", titulo)), 2.0)
	elif bus != null and bus.has_method("emit_floating_text"):
		bus.emit_floating_text(caster.global_position + Vector2(0, -40), str(meta.get("balloon", titulo)), cor)


static func _event_bus() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null
	return tree.root.get_node_or_null("/root/EventBus")


static func _audio_manager() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null
	return tree.root.get_node_or_null("/root/AudioManager")


static func play_for_hatsu(hatsu: HatsuData, caster: Node2D, parent: Node = null) -> Kind:
	var kind := detect_kind(hatsu)
	var sub := ""
	if hatsu != null:
		sub = hatsu.nome
	play(kind, caster, parent, sub)
	return kind


static func detect_kind(hatsu: HatsuData) -> Kind:
	if hatsu == null:
		return Kind.SKILL_HUNTER
	var n := hatsu.nome.to_lower()
	var tags_txt := ""
	if "tags" in hatsu and hatsu.tags is Array:
		for t in hatsu.tags:
			tags_txt += " " + str(t).to_lower()
	if hatsu.arquetipo == HatsuData.Arquetipo.LIVRO_COLECAO \
		or hatsu.activation_type == HatsuData.ActivationType.OVERRIDE_LIBRARY \
		or "skill hunter" in n or "roubo" in n or "livro" in n or "hunter" in tags_txt:
		return Kind.SKILL_HUNTER
	if hatsu.core_component == HatsuComponentLibrary.CoreType.ABSORPTION \
		or "absorv" in n or "devour" in n or "predador" in n or "meruem" in n \
		or "absorb" in tags_txt or "devour" in tags_txt:
		return Kind.DEVOUR
	if "blythe" in n or "doctor" in n or "médic" in n or "medic" in n \
		or (hatsu.objetivo == HatsuData.ObjetivoPrincipal.CURA and hatsu.cura_base >= 80.0) \
		or "doctor" in tags_txt or "heal_mass" in tags_txt:
		return Kind.DOCTOR_BLYTHE
	if "terpsichora" in n or "marionete" in n or "corporal" in n \
		or "buff" in tags_txt or "terpsichora" in tags_txt:
		return Kind.TERPSICHORA
	if hatsu.objetivo == HatsuData.ObjetivoPrincipal.CURA:
		return Kind.DOCTOR_BLYTHE
	if hatsu.objetivo == HatsuData.ObjetivoPrincipal.SUPORTE:
		return Kind.TERPSICHORA
	return Kind.SKILL_HUNTER


static func _meta(kind: Kind, subtitle: String) -> Dictionary:
	match kind:
		Kind.SKILL_HUNTER:
			return {
				"titulo": "Skill Hunter",
				"sub": subtitle if not subtitle.is_empty() else "Especialização · Biblioteca de Nen",
				"toast": "📖 Skill Hunter — página aberta",
				"balloon": "📖 SKILL HUNTER!",
				"cor": Color(0.55, 0.25, 0.95),
				"raio": 52.0,
				"cast_time": 0.4,
				"shake": 0.4,
				"sfx": "hatsu_cast",
				"pitch": 0.85,
				"impact": true
			}
		Kind.DEVOUR:
			return {
				"titulo": "Síntese Predadora",
				"sub": subtitle if not subtitle.is_empty() else "Especialização · Absorção de Aura",
				"toast": "👑 Aura absorvida — poder permanente",
				"balloon": "👑 DEVOUR!",
				"cor": Color(1.0, 0.92, 0.35),
				"raio": 60.0,
				"cast_time": 0.45,
				"shake": 0.55,
				"sfx": "boss_phase",
				"pitch": 1.1,
				"impact": true
			}
		Kind.TERPSICHORA:
			return {
				"titulo": "Terpsichora",
				"sub": subtitle if not subtitle.is_empty() else "Manipulação · Marionete Corporal",
				"toast": "🐱 Terpsichora — corpo reforçado",
				"balloon": "🐱 TERPSICHORA!",
				"cor": Color(1.0, 0.2, 0.35),
				"raio": 44.0,
				"cast_time": 0.3,
				"shake": 0.35,
				"sfx": "hatsu_cast",
				"pitch": 1.15,
				"impact": true
			}
		Kind.DOCTOR_BLYTHE:
			return {
				"titulo": "Doctor Blythe",
				"sub": subtitle if not subtitle.is_empty() else "Conjuração · Cirurgia de Nen",
				"toast": "💉 Doctor Blythe — regeneração massiva",
				"balloon": "💉 DOCTOR BLYTHE!",
				"cor": Color(0.35, 1.0, 0.65),
				"raio": 56.0,
				"cast_time": 0.55,
				"shake": 0.25,
				"sfx": "item_pickup",
				"pitch": 0.9,
				"impact": true
			}
	return {"titulo": "Hatsu", "cor": Color.WHITE}


static func _build_profile(kind: Kind, cor: Color):
	var VisualProfileScript = load("res://resource/hatsu/VisualProfile.gd")
	var p = VisualProfileScript.new() if VisualProfileScript != null else null
	if p == null:
		return null
	p.primary_color = cor
	p.core_color = cor.lightened(0.25)
	p.glow_color = Color(cor.r, cor.g, cor.b, 0.85)
	p.visual_scale = 1.15
	match kind:
		Kind.SKILL_HUNTER:
			p.cast_effect = "spark_burst"
			p.impact_effect = "shockwave"
		Kind.DEVOUR:
			p.cast_effect = "smoke"
			p.impact_effect = "shockwave"
		Kind.TERPSICHORA:
			p.cast_effect = "blade"
			p.impact_effect = "slash"
		Kind.DOCTOR_BLYTHE:
			p.cast_effect = "flash"
			p.impact_effect = "wave"
		_:
			p.cast_effect = "flash"
			p.impact_effect = "burst"
	return p


static func _spawn_cast_ring(parent: Node, pos: Vector2, raio: float, cor: Color, dur: float) -> void:
	if parent == null:
		return
	var ring := Node2D.new()
	ring.name = "HatsuCastRing"
	ring.z_index = 6
	ring.global_position = pos
	var r := raio
	var c := cor
	ring.draw.connect(func():
		ring.draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, Color(c.r, c.g, c.b, 0.85), 2.0)
		ring.draw_arc(Vector2.ZERO, r * 0.72, 0.0, TAU, 28, Color(c.r, c.g, c.b, 0.35), 1.0)
	)
	parent.add_child(ring)
	ring.queue_redraw()
	var tw := ring.create_tween()
	tw.tween_property(ring, "scale", Vector2(1.25, 1.25), dur)
	tw.parallel().tween_property(ring, "modulate:a", 0.0, dur)
	tw.tween_callback(ring.queue_free)
