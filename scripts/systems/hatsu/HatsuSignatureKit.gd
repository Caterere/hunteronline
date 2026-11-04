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


## Pipeline cast → impacto → residual (Steam polish §6.3). Mastery ≥10 densifica residual.
static func play_intensity_pipeline(caster: Node2D, hatsu: HatsuData, hit_pos: Vector2 = Vector2.ZERO, dir: Vector2 = Vector2.RIGHT) -> void:
	if caster == null or not is_instance_valid(caster) or hatsu == null:
		return
	var parent: Node = caster.get_parent() if caster.get_parent() != null else caster
	var cor: Color = NenAffinityData.obter_cor_afinidade(hatsu.categoria) if NenAffinityData != null else hatsu.cor_aura
	var mastery: float = float(hatsu.mastery) if "mastery" in hatsu else 0.0
	var scale_m: float = 1.0 + clampf(mastery, 0.0, 100.0) / 200.0 # até +50% @100
	var residual_boost: bool = mastery >= 10.0
	var impact_at: Vector2 = hit_pos if hit_pos != Vector2.ZERO else caster.global_position
	var d: Vector2 = dir if dir != Vector2.ZERO else Vector2.RIGHT
	var n := hatsu.nome.to_lower()

	# --- IMPACTO por identidade ---
	if ("jajanken" in n and "pedra" in n) or (hatsu.categoria == HatsuData.Categoria.INTENSIFICACAO and "pedra" in n):
		HatsuProceduralFxKit.cast_flash(parent, impact_at, Color(1.0, 0.75, 0.2), 1.25 * scale_m)
		HatsuProceduralFxKit.impact_ring(parent, impact_at, Color(1.0, 0.7, 0.25), 48.0 * scale_m)
		CombatImpactEffect.spawn_dust_kickup(parent, impact_at, d * 120.0)
		if residual_boost:
			HatsuProceduralFxKit.ember_sparks(parent, impact_at, Color(1.0, 0.85, 0.35), 16)
			_spawn_residual_crater(parent, impact_at, Color(1.0, 0.7, 0.2), 0.55 + mastery * 0.004)
	elif ("jajanken" in n and "papel" in n) or "papel" in n and "jajanken" in n:
		HatsuProceduralFxKit.emission_bolts(parent, impact_at, d, Color(0.45, 0.9, 1.0), 4, scale_m)
		HatsuProceduralFxKit.impact_ring(parent, impact_at, Color(0.4, 0.85, 1.0), 34.0 * scale_m)
		if residual_boost:
			_spawn_residual_trail(parent, impact_at - d * 40.0, impact_at, Color(0.45, 0.9, 1.0), 0.4 + mastery * 0.003)
	elif ("jajanken" in n and "tesoura" in n) or "tesoura" in n:
		HatsuProceduralFxKit.slash_arc(parent, impact_at, d, Color(0.95, 0.98, 1.0), 40.0 * scale_m, true)
		CombatImpactEffect.spawn_slash(parent, impact_at, d, Color(0.9, 0.95, 1.0))
		if residual_boost:
			_spawn_residual_slash(parent, impact_at, d, Color(0.85, 0.92, 1.0), 0.35 + mastery * 0.002)
	elif "godspeed" in n or "kanmuru" in n:
		HatsuProceduralFxKit.lightning_arcs(parent, caster.global_position, d, Color(0.65, 0.9, 1.0), scale_m)
		HatsuProceduralFxKit.cast_flash(parent, caster.global_position, Color(0.55, 0.85, 1.0), 1.1 * scale_m)
		if residual_boost:
			_spawn_residual_aura(parent, caster, Color(0.55, 0.9, 1.0), 0.8 + mastery * 0.005)
	elif "chain jail" in n or "aprisionamento" in n:
		_spawn_chain_visual(parent, caster.global_position, impact_at, Color(0.75, 0.35, 1.0))
		HatsuProceduralFxKit.impact_ring(parent, impact_at, Color(0.7, 0.3, 0.95), 36.0 * scale_m)
		if residual_boost:
			_spawn_residual_aura(parent, null, Color(0.7, 0.3, 0.95), 0.6, impact_at)
	elif "judgement" in n or "julgamento" in n:
		_spawn_chain_visual(parent, caster.global_position, impact_at, Color(0.95, 0.2, 0.3))
		HatsuProceduralFxKit.cast_flash(parent, impact_at, Color(1.0, 0.2, 0.25), 1.3 * scale_m)
		HatsuProceduralFxKit.impact_ring(parent, impact_at, Color(0.95, 0.15, 0.25), 50.0 * scale_m)
	elif "bungee" in n:
		HatsuProceduralFxKit.serpent_wave(parent, caster.global_position, d, Color(1.0, 0.4, 0.75), scale_m)
		if residual_boost:
			HatsuProceduralFxKit.mist_cloud(parent, impact_at, Color(1.0, 0.35, 0.7), 0.7)
	elif "crazy slots" in n:
		HatsuProceduralFxKit.cast_flash(parent, caster.global_position, Color(0.95, 0.35, 0.55), 1.2 * scale_m)
		HatsuProceduralFxKit.spin_star(parent, caster.global_position, Color(1.0, 0.4, 0.55), scale_m)
	else:
		HatsuProceduralFxKit.play_for_hatsu(parent, impact_at, d, hatsu, scale_m)
		if residual_boost:
			HatsuProceduralFxKit.impact_ring(parent, impact_at, cor, 28.0 * scale_m)

	var bus = _event_bus()
	if bus != null and bus.has_method("emit_hitstop"):
		var hs: float = 0.15 if hatsu.categoria == HatsuData.Categoria.INTENSIFICACAO else 0.12
		if residual_boost:
			hs += 0.02
		bus.emit_hitstop(hs)


static func _spawn_residual_crater(parent: Node, pos: Vector2, cor: Color, dur: float) -> void:
	if parent == null:
		return
	var n := Node2D.new()
	n.name = "HatsuResidualCrater"
	n.z_index = -1
	n.global_position = pos
	var c := cor
	n.draw.connect(func():
		n.draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 28, Color(c.r, c.g, c.b, 0.55), 2.5)
		n.draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 20, Color(c.r, c.g, c.b, 0.35), 1.5)
	)
	parent.add_child(n)
	n.queue_redraw()
	var tw := n.create_tween()
	tw.tween_property(n, "modulate:a", 0.0, maxf(0.25, dur))
	tw.tween_callback(n.queue_free)


static func _spawn_residual_trail(parent: Node, from: Vector2, to: Vector2, cor: Color, dur: float) -> void:
	if parent == null:
		return
	var line := Line2D.new()
	line.name = "HatsuResidualTrail"
	line.width = 3.5
	line.default_color = Color(cor.r, cor.g, cor.b, 0.75)
	line.z_index = 7
	line.points = PackedVector2Array([from, to])
	parent.add_child(line)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, maxf(0.2, dur))
	tw.tween_callback(line.queue_free)


static func _spawn_residual_slash(parent: Node, pos: Vector2, dir: Vector2, cor: Color, dur: float) -> void:
	if parent == null:
		return
	var line := Line2D.new()
	line.name = "HatsuResidualSlash"
	line.width = 2.5
	line.default_color = Color(cor.r, cor.g, cor.b, 0.7)
	line.z_index = 8
	var a := pos - dir.normalized() * 18.0
	var b := pos + dir.normalized() * 28.0
	line.points = PackedVector2Array([a, b])
	parent.add_child(line)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, maxf(0.18, dur))
	tw.tween_callback(line.queue_free)


static func _spawn_residual_aura(parent: Node, follow: Node2D, cor: Color, dur: float, fixed_pos: Vector2 = Vector2.ZERO) -> void:
	if parent == null and follow == null:
		return
	var root: Node = parent if parent != null else (follow.get_parent() if follow != null else null)
	if root == null:
		return
	var n := Node2D.new()
	n.name = "HatsuResidualAura"
	n.z_index = 5
	if fixed_pos != Vector2.ZERO:
		n.global_position = fixed_pos
	elif follow != null:
		n.global_position = follow.global_position
	var c := cor
	n.draw.connect(func():
		n.draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 24, Color(c.r, c.g, c.b, 0.55), 1.8)
	)
	root.add_child(n)
	n.queue_redraw()
	var elapsed := {"t": 0.0}
	var tw := n.create_tween()
	tw.set_loops(maxi(1, int(dur / 0.08)))
	tw.tween_callback(func():
		elapsed["t"] = float(elapsed["t"]) + 0.08
		if follow != null and is_instance_valid(follow) and fixed_pos == Vector2.ZERO:
			n.global_position = follow.global_position
		n.queue_redraw()
		if float(elapsed["t"]) >= dur and is_instance_valid(n):
			n.queue_free()
	)
	tw.tween_interval(0.08)


static func _spawn_chain_visual(parent: Node, from: Vector2, to: Vector2, cor: Color) -> void:
	if parent == null:
		return
	var line := Line2D.new()
	line.name = "ChainJailVisual"
	line.width = 2.8
	line.default_color = Color(cor.r, cor.g, cor.b, 0.9)
	line.z_index = 9
	# Elos segmentados
	var pts := PackedVector2Array()
	var steps := 6
	for i in range(steps + 1):
		var t: float = float(i) / float(steps)
		var p: Vector2 = from.lerp(to, t)
		p += Vector2(0, sin(t * PI) * 6.0)
		pts.append(p)
	line.points = pts
	parent.add_child(line)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.85)
	tw.tween_callback(line.queue_free)


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
