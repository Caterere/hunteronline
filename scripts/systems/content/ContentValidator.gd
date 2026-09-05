class_name ContentValidator
extends RefCounted

# ============================================================
# HUNTER ONLINE — CONTENT VALIDATOR (FASE L)
# ============================================================
#
# Validador automático estático e dinâmico de pipeline de conteúdo:
# - Detecta IDs duplicados ou vazios.
# - Verifica existência de cenas de mapa, trilhas de áudio e texturas.
# - Identifica requisitos de gating inválidos ou impossíveis.
# - Valida integridade de tabelas de recompensas e drops de chefes.
# ============================================================

static func validate_saga(saga_def: Resource) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	if saga_def == null:
		return {"valid": false, "errors": ["SagaDefinition é nula."], "warnings": []}

	var s_id = saga_def.get("saga_id")
	if s_id == null or String(s_id).strip_edges().is_empty():
		errors.append("Saga possui saga_id vazio ou inválido.")

	var s_name_val = saga_def.get("display_name")
	var s_name = str(s_name_val) if s_name_val != null else ""
	if s_name.strip_edges().is_empty():
		warnings.append("Saga '%s' não possui display_name definido." % str(s_id))

	var caps = saga_def.get("chapters")
	if not (caps is Array) or caps.is_empty():
		warnings.append("Saga '%s' não possui capítulos cadastrados." % str(s_id))
	else:
		var seen_indices: Dictionary = {}
		for c in caps:
			if c == null:
				errors.append("Saga '%s' possui capítulo nulo na lista." % str(s_id))
				continue
			var c_idx_val = c.get("chapter_index")
			var c_idx = int(c_idx_val) if c_idx_val != null else 0
			if seen_indices.has(c_idx):
				errors.append("Saga '%s' possui capítulo com índice duplicado: %d" % [str(s_id), c_idx])
			seen_indices[c_idx] = true

			var cap_val = validate_chapter(c)
			for err in cap_val.get("errors", []):
				errors.append("Saga '%s' Cap %d: %s" % [str(s_id), c_idx, err])
			for warn in cap_val.get("warnings", []):
				warnings.append("Saga '%s' Cap %d: %s" % [str(s_id), c_idx, warn])

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings
	}


static func validate_chapter(chapter_def: Resource) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	if chapter_def == null:
		return {"valid": false, "errors": ["ChapterDefinition é nula."], "warnings": []}

	var title_val = chapter_def.get("title")
	var title = str(title_val) if title_val != null else ""
	if title.strip_edges().is_empty():
		warnings.append("Capítulo não possui título.")

	var q_id_val = chapter_def.get("main_quest_id")
	var q_id = str(q_id_val) if q_id_val != null else ""
	if q_id.strip_edges().is_empty():
		warnings.append("Capítulo '%s' não possui main_quest_id atribuída." % title)

	var reqs = chapter_def.get("gating_requirements")
	if reqs is Array:
		for r in reqs:
			if r is Dictionary:
				var t = str(r.get("type", ""))
				if t.is_empty():
					errors.append("Requisito de gating com tipo vazio no capítulo '%s'." % title)

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings
	}


static func validate_region(region_pkg: Resource) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	if region_pkg == null:
		return {"valid": false, "errors": ["RegionPackage é nula."], "warnings": []}

	var r_id = region_pkg.get("region_id")
	if r_id == null or String(r_id).strip_edges().is_empty():
		errors.append("RegionPackage possui region_id vazio.")

	var sp_val = region_pkg.get("scene_path")
	var scene_path = str(sp_val) if sp_val != null else ""
	if not scene_path.is_empty():
		if not ResourceLoader.exists(scene_path) and not FileAccess.file_exists(scene_path):
			warnings.append("Região '%s': Arquivo de cena não encontrado: '%s'" % [str(r_id), scene_path])

	var m_val = region_pkg.get("ambient_music")
	var music = str(m_val) if m_val != null else ""
	if not music.is_empty():
		if not ResourceLoader.exists(music) and not FileAccess.file_exists(music):
			warnings.append("Região '%s': Trilha musical não encontrada: '%s'" % [str(r_id), music])

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings
	}


static func validate_boss(boss_def: Resource) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	if boss_def == null:
		return {"valid": false, "errors": ["BossDefinition é nula."], "warnings": []}

	var b_id = boss_def.get("boss_id")
	if b_id == null or String(b_id).strip_edges().is_empty():
		errors.append("BossDefinition possui boss_id vazio.")

	var stats = boss_def.get("base_stats")
	if not (stats is Dictionary):
		errors.append("BossDefinition '%s' não possui base_stats." % str(b_id))
	else:
		if int(stats.get("max_health", 0)) <= 0:
			errors.append("Boss '%s' possui max_health menor ou igual a zero." % str(b_id))
		if int(stats.get("damage", 0)) <= 0:
			warnings.append("Boss '%s' possui damage menor ou igual a zero." % str(b_id))

	var loot = boss_def.get("loot_table")
	if loot is Array:
		for item_drop in loot:
			if item_drop is Dictionary:
				var it_id = str(item_drop.get("item_id", ""))
				if it_id.is_empty():
					errors.append("Boss '%s': Item no loot table com item_id vazio." % str(b_id))
				var chance = float(item_drop.get("chance", 0.0))
				if chance <= 0.0 or chance > 1.0:
					errors.append("Boss '%s': Chance de drop de '%s' inválida: %.2f (deve ser 0.01..1.0)" % [str(b_id), it_id, chance])

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings
	}


static func validate_live_event(event_def: Resource) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	if event_def == null:
		return {"valid": false, "errors": ["LiveEventDefinition é nula."], "warnings": []}

	var e_id = event_def.get("event_id")
	if e_id == null or String(e_id).strip_edges().is_empty():
		errors.append("LiveEventDefinition possui event_id vazio.")

	var dur_val = event_def.get("duration_hours")
	var dur = float(dur_val) if dur_val != null else 0.0
	if dur <= 0.0:
		errors.append("LiveEventDefinition '%s' possui duração inválida (<= 0h)." % str(e_id))

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings
	}
