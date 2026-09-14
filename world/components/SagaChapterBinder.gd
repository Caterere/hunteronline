class_name SagaChapterBinder
extends RefCounted

# ============================================================
# HUNTER ONLINE — SAGA CHAPTER BINDER
# Garante quest ativa do arco + placa/NPC de objetivo do capítulo
# alinhados ao distrito (CanonQuestCatalog — 254 etapas).
# ============================================================


static func bind_hub(mapa: Node2D, arco: int) -> void:
	if mapa == null:
		return
	_garantir_quest(arco)
	_spawn_chapter_objective_placard(mapa, arco)
	_spawn_chapter_guide_npc(mapa, arco)
	if QuestSystem != null and QuestSystem.has_method("sincronizar_inimigos_do_mapa"):
		QuestSystem.sincronizar_inimigos_do_mapa(mapa)


static func _garantir_quest(arco: int) -> void:
	if QuestSystem == null:
		return
	if QuestSystem.active_quests.is_empty() and QuestSystem.has_method("garantir_quest_do_arco"):
		QuestSystem.garantir_quest_do_arco(arco)


static func _etapa_atual() -> int:
	if PlayerData != null:
		return max(1, int(PlayerData.etapa_quest_arco))
	if StoryManager != null:
		return max(1, int(StoryManager.current_chapter))
	return 1


static func _quest_info(arco: int, etapa: int) -> Dictionary:
	var q = CanonQuestCatalog.obter_quest_da_etapa(arco, etapa)
	if q == null:
		return {}
	return {
		"name": str(q.quest_name) if "quest_name" in q else "Capítulo %d" % etapa,
		"desc": str(q.description) if "description" in q else "",
	}


static func _district_anchor_for_etapa(arco: int, etapa: int) -> Vector2:
	match arco:
		1:
			if etapa <= 5:
				return Vector2(400, -130)
			if etapa <= 11:
				return Vector2(2200, -130)
			if etapa <= 16:
				return Vector2(4400, -130)
			return Vector2(5600, -130)
		2:
			if etapa <= 5:
				return Vector2(300, -130)
			if etapa <= 12:
				return Vector2(1400, -130)
			return Vector2(2800, -130)
		3:
			if etapa <= 8:
				return Vector2(300, -130)
			if etapa <= 16:
				return Vector2(1400, -130)
			return Vector2(3000, -130)
		4:
			if etapa <= 10:
				return Vector2(400, -130)
			if etapa <= 22:
				return Vector2(1800, -130)
			return Vector2(3200, -130)
		5:
			if etapa <= 10:
				return Vector2(300, -130)
			if etapa <= 22:
				return Vector2(1600, -130)
			if etapa <= 30:
				return Vector2(2700, -130)
			return Vector2(3600, -130)
		6:
			if etapa <= 12:
				return Vector2(300, -130)
			if etapa <= 28:
				return Vector2(1600, -130)
			if etapa <= 40:
				return Vector2(2700, -130)
			return Vector2(3600, -130)
		7:
			if etapa <= 6:
				return Vector2(300, -130)
			if etapa <= 12:
				return Vector2(1600, -130)
			if etapa <= 16:
				return Vector2(2700, -130)
			return Vector2(3600, -130)
		8:
			if etapa <= 6:
				return Vector2(300, -130)
			if etapa <= 12:
				return Vector2(1600, -130)
			if etapa <= 18:
				return Vector2(2700, -130)
			return Vector2(3600, -130)
		9:
			if etapa <= 8:
				return Vector2(300, -130)
			if etapa <= 14:
				return Vector2(1600, -130)
			if etapa <= 20:
				return Vector2(2700, -130)
			return Vector2(3600, -130)
		_:
			return Vector2(200, -130)


static func _spawn_chapter_objective_placard(mapa: Node2D, arco: int) -> void:
	var etapa := _etapa_atual()
	var info := _quest_info(arco, etapa)
	if info.is_empty():
		return
	var node_name := "PlacaObjetivoCapitulo"
	var existing = mapa.get_node_or_null(node_name)
	if existing != null:
		existing.queue_free()
	var marker := Node2D.new()
	marker.name = node_name
	marker.position = _district_anchor_for_etapa(arco, etapa)
	var lbl := Label.new()
	var titulo := str(info.get("name", "Capítulo %d" % etapa))
	var desc := str(info.get("desc", ""))
	if desc.length() > 70:
		desc = desc.substr(0, 67) + "..."
	lbl.text = "🎯 %s\n%s" % [titulo, desc]
	lbl.position = Vector2(-120, -18)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45, 0.98))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	marker.add_child(lbl)
	mapa.add_child(marker)


static func _spawn_chapter_guide_npc(mapa: Node2D, arco: int) -> void:
	var etapa := _etapa_atual()
	var info := _quest_info(arco, etapa)
	if info.is_empty():
		return
	var n := "GuiaCapituloSaga"
	if mapa.get_node_or_null(n) != null:
		return
	var scn = load("res://entities/npc/NPC.tscn")
	if scn == null:
		return
	var total := CanonQuestCatalog.obter_total_quests_do_arco(arco)
	var npc = scn.instantiate()
	npc.name = n
	npc.position = _district_anchor_for_etapa(arco, etapa) + Vector2(80, 80)
	npc.npc_name = "Guia do Capítulo"
	npc.fala_padrao = "Capítulo %d/%d — %s. %s" % [
		etapa, total, str(info.get("name", "")), str(info.get("desc", ""))
	]
	NpcSpriteBinder.aplicar(npc, ["npc_viajante_scout"])
	var living := LivingNPCBehavior.new()
	living.name = "LivingNPCBehavior"
	living.npc_nome = "Guia do Capítulo"
	living.tipo_marcador = "guide"
	living.hierarchy = LivingNPCBehavior.NPCHierarchy.COMMON
	living.raio_patrulha = 24.0
	npc.add_child(living)
	mapa.add_child(npc)
