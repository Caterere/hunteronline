extends Node2D

# ============================================================
# HUNTER ONLINE — P0 PLAY SMOKE SUITE
# Escolta noturna · Disputa da ponte (+rep) · Furto Gyo · UI pergaminho
# ============================================================

const PadokiaQuestCatalog = preload("res://resource/quest/PadokiaQuestCatalog.gd")

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 P0 PLAY SMOKE SUITE — escolta / ponte+rep / furto Gyo / pergaminho")
	print("================================================================================")

	await get_tree().process_frame
	await _run_all()

	print("\n================================================================================")
	print("🏆 P0 PLAY SMOKE: %d / %d (%.0f%%)" % [
		_passed, _total, 100.0 * float(_passed) / float(maxi(_total, 1))
	])
	if not _failures.is_empty():
		print("❌ FALHAS:")
		for f in _failures:
			print("   - ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _run_all() -> void:
	_test_01_estrada_loads()
	await _test_02_escolta_start_and_zone()
	await _test_03_escolta_fail_outside_zone()
	await _test_04_ponte_disputa_spawns()
	await _test_05_ponte_clear_grants_rep()
	_test_06_furto_quest_catalog()
	await _test_07_gyo_inspect_and_input()
	await _test_08_pergaminho_ui()
	await _test_09_padokia_gyo_gate_despertou_nen()
	_test_10_skill_tree_bloqueada_sem_nen()
	_test_11_soft_cap_xp_saga()
	_test_12_heavens_arena_challenge_wires_tower()


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ [PASS] ", label)
	else:
		_failures.append(label)
		print("  ❌ [FAIL] ", label)


func _test_01_estrada_loads() -> void:
	print("\n[TESTE 1] Cena Estrada Padokia carrega...")
	var scn := load("res://world/maps/estrada_padokia.tscn") as PackedScene
	_ok(scn != null, "estrada_padokia.tscn carrega")
	if scn == null:
		return
	var mapa := scn.instantiate()
	add_child(mapa)
	_ok(mapa.get_script() != null, "Script EstradaPadokiaMap anexado")
	mapa.queue_free()


func _test_02_escolta_start_and_zone() -> void:
	print("\n[TESTE 2] Escolta: start + ZonaProtecaoEscolta...")
	var scn := load("res://world/maps/estrada_padokia.tscn") as PackedScene
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	var q = PadokiaQuestCatalog.obter_quest_secundaria_estrada()
	if QuestSystem != null and PlayerData != null:
		if not PlayerData.is_quest_active(q) and not PlayerData.is_quest_completed(q):
			QuestSystem.start_quest(q)

	_ok(PlayerData != null and PlayerData.is_quest_active(q), "Quest escolta ativa")

	var zona = mapa.get_node_or_null("ZonaProtecaoEscolta")
	_ok(zona != null and zona is Area2D, "ZonaProtecaoEscolta existe")

	var carroca = mapa.get_node_or_null("CarrocaMercador")
	_ok(carroca != null, "CarrocaMercador presente")

	mapa.queue_free()
	await get_tree().process_frame


func _test_03_escolta_fail_outside_zone() -> void:
	print("\n[TESTE 3] Escolta falha após 8s fora da zona à noite...")
	var scn := load("res://world/maps/estrada_padokia.tscn") as PackedScene
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame

	var q = PadokiaQuestCatalog.obter_quest_secundaria_estrada()
	if QuestSystem != null and PlayerData != null and not PlayerData.is_quest_active(q):
		# Limpa estado residual de testes anteriores e reinicia
		if PlayerData.has_method("_get_quest_id"):
			PlayerData.quest_states.erase(PlayerData._get_quest_id(q))
		else:
			PlayerData.quest_states.erase(str(q.quest_name))
		QuestSystem.start_quest(q)

	if TimeManager != null and TimeManager.has_method("set_time"):
		TimeManager.set_time(22, 0)

	mapa.set("_emboscada_escolta_feita", true)
	mapa.set("_escolta_jogador_na_zona", false)
	mapa.set("_escolta_tempo_fora_zona", 0.0)
	mapa.set("_escolta_falhou", false)

	for _i in range(10):
		if mapa.has_method("_atualizar_vigilancia_escolta"):
			mapa.call("_atualizar_vigilancia_escolta", 1.0)
		await get_tree().process_frame

	_ok(bool(mapa.get("_escolta_falhou")), "Escolta falha após tempo fora da zona à noite")
	mapa.queue_free()
	await get_tree().process_frame


func _test_04_ponte_disputa_spawns() -> void:
	print("\n[TESTE 4] Disputa da ponte: spawn forçado + ID evento...")
	var scn := load("res://world/maps/estrada_padokia.tscn") as PackedScene
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame

	if mapa.has_method("_tentar_disputa_faccao_ponte"):
		mapa.call("_tentar_disputa_faccao_ponte", true)

	var root = mapa.get_node_or_null("DisputaFaccaoPonte")
	_ok(root != null, "Nó DisputaFaccaoPonte criado")
	var s0 = root.get_node_or_null("SalteadorPonte_0") if root else null
	var s1 = root.get_node_or_null("SalteadorPonte_1") if root else null
	_ok(s0 != null and s1 != null, "Dois SalteadorPonte_* spawnados")

	var src := FileAccess.get_file_as_string("res://world/maps/EstradaPadokiaMap.gd")
	_ok(
		src.contains("evento_disputa_ponte_estrada_padokia") \
		and not src.contains("\"evento_disputa_ponte_padokia\""),
		"ID evento ponte alinhado com WorldEventManager"
	)

	mapa.queue_free()
	await get_tree().process_frame


func _test_05_ponte_clear_grants_rep() -> void:
	print("\n[TESTE 5] Limpar salteadores da ponte concede +80 rep...")
	var scn := load("res://world/maps/estrada_padokia.tscn") as PackedScene
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame

	if mapa.has_method("_tentar_disputa_faccao_ponte"):
		mapa.call("_tentar_disputa_faccao_ponte", true)

	var rep_before := 0
	if ReputationSystem != null:
		rep_before = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER)

	var root = mapa.get_node_or_null("DisputaFaccaoPonte")
	if root != null:
		for c in root.get_children():
			if str(c.name).begins_with("SalteadorPonte"):
				var es = c.get_node_or_null("EnemySystem")
				if es != null:
					es.set("is_dead", true)
				c.free()
		if mapa.has_method("_on_salteador_morto"):
			mapa.call("_on_salteador_morto", &"ladrao_estrada")

	var rep_after := rep_before
	if ReputationSystem != null:
		rep_after = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER)

	_ok(rep_after >= rep_before + 80, "Reputação Associação +80 (%d → %d)" % [rep_before, rep_after])
	mapa.queue_free()
	await get_tree().process_frame


func _test_06_furto_quest_catalog() -> void:
	print("\n[TESTE 6] Quest furto Gyo + factory de pistas...")
	var q = PadokiaQuestCatalog.obter_quest_investigacao_furto()
	_ok(q != null and q.objectives.size() >= 4, "Quest furto tem ≥4 objetivos")

	var ids: PackedStringArray = []
	for obj in q.objectives:
		if obj.type == QuestObjective.Type.INVESTIGATE:
			ids.append(str(obj.target_clue_id))
	_ok(
		ids.has("pista_furto_janela") \
		and ids.has("pista_furto_pegada") \
		and ids.has("pista_furto_esconderijo"),
		"Clue IDs furto corretos"
	)

	var gyo = NenSensorFactory.criar_gyo(
		self,
		"PistaFurtoSmoke",
		Vector2(80, 80),
		&"pista_furto_janela",
		"Marca na Janela",
		"Resíduo de Nen na moldura.",
		"Intensificação",
		1
	)
	_ok(gyo != null and gyo is GyoInspectable, "NenSensorFactory.criar_gyo OK")
	if gyo:
		gyo.queue_free()


func _test_07_gyo_inspect_and_input() -> void:
	print("\n[TESTE 7] GyoInspectable inspeção + wiring [E]...")
	var gyo := GyoInspectable.new()
	gyo.name = "GyoSmokeClue"
	gyo.clue_id = &"pista_furto_pegada"
	gyo.titulo_pista = "Pegada Smoke"
	gyo.descricao_pista = "Rastro de teste"
	gyo.requer_gyo = true
	gyo.nivel_gyo_minimo = 1
	add_child(gyo)

	var player := CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	var NenScript = load("res://scripts/systems/NenSystem.gd")
	if NenScript != null:
		var nen = NenScript.new()
		nen.name = "NenSystem"
		player.add_child(nen)
	add_child(player)

	var fail_res: Dictionary = gyo.inspecionar(player)
	_ok(not bool(fail_res.get("sucesso", true)), "Inspeção sem Gyo falha")

	gyo.gyo_ativo_no_jogador = true
	gyo.jogador_proximo = player
	gyo.foi_inspecionado = false

	if QuestSystem != null and PlayerData != null:
		var q = PadokiaQuestCatalog.obter_quest_investigacao_furto()
		if not PlayerData.is_quest_active(q) and not PlayerData.is_quest_completed(q):
			QuestSystem.start_quest(q)
		if QuestSystem.has_method("register_npc_visit"):
			QuestSystem.register_npc_visit(&"vendedor")

	var ok_res: Dictionary = gyo.inspecionar(player)
	_ok(bool(ok_res.get("sucesso", false)), "Inspeção com Gyo sucede")
	_ok(gyo.has_method("_unhandled_input"), "GyoInspectable tem _unhandled_input")

	gyo.foi_inspecionado = false
	gyo.gyo_ativo_no_jogador = true
	gyo.jogador_proximo = player
	var ev := InputEventKey.new()
	ev.keycode = KEY_E
	ev.pressed = true
	ev.echo = false
	gyo._unhandled_input(ev)
	_ok(gyo.foi_inspecionado, "[E] via _unhandled_input inspeciona")

	player.queue_free()
	if is_instance_valid(gyo):
		gyo.queue_free()
	await get_tree().process_frame


func _test_08_pergaminho_ui() -> void:
	print("\n[TESTE 8] UI pergaminho (HunterUIStyle + HunterMissionContractUI)...")
	_ok(HunterUIStyle.COLOR_PANEL_PETROL.r > 0.5, "COLOR_PANEL_PETROL é tom pergaminho")
	var style := HunterUIStyle.criar_style_painel_principal()
	_ok(style is StyleBoxFlat and style.bg_color.r > 0.5, "StyleBox painel principal pergaminho")

	var contract := HunterMissionContractUI.new()
	add_child(contract)
	await get_tree().process_frame
	_ok(contract.get_child_count() > 0, "HunterMissionContractUI monta documento")
	contract.queue_free()


func _test_09_padokia_gyo_gate_despertou_nen() -> void:
	print("\n[TESTE 9] Padokia: Gyo/furto só após despertou_nen...")
	var scn := load("res://world/maps/regiao_vale_padokia.tscn") as PackedScene
	if scn == null:
		var MapScript = load("res://world/maps/RegiaoValePadokiaMap.gd")
		_ok(MapScript != null, "RegiaoValePadokiaMap.gd carrega")
		if MapScript == null:
			return
		PlayerData.despertou_nen = false
		var mapa_off = MapScript.new()
		mapa_off.name = "PadokiaGateOff"
		add_child(mapa_off)
		await get_tree().process_frame
		await get_tree().process_frame
		_ok(mapa_off.get_node_or_null("PistaFurtoJanela") == null, "Sem pistas Gyo pré-despertar (script)")
		mapa_off.queue_free()
		await get_tree().process_frame

		PlayerData.despertou_nen = true
		var mapa_on = MapScript.new()
		mapa_on.name = "PadokiaGateOn"
		add_child(mapa_on)
		await get_tree().process_frame
		await get_tree().process_frame
		if mapa_on.has_method("_popular_pistas_furto_gyo"):
			mapa_on._popular_pistas_furto_gyo()
		await get_tree().process_frame
		_ok(mapa_on.get_node_or_null("PistaFurtoJanela") != null, "Pistas Gyo após despertar (script)")
		mapa_on.queue_free()
		PlayerData.despertou_nen = false
		return

	PlayerData.despertou_nen = false
	var mapa_a := scn.instantiate()
	add_child(mapa_a)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa_a.get_node_or_null("PistaFurtoJanela") == null, "Sem PistaFurtoJanela pré-despertar")
	_ok(mapa_a.get_node_or_null("PistaFurtoPegada") == null, "Sem PistaFurtoPegada pré-despertar")
	mapa_a.queue_free()
	await get_tree().process_frame

	PlayerData.despertou_nen = true
	var mapa_b := scn.instantiate()
	add_child(mapa_b)
	await get_tree().process_frame
	await get_tree().process_frame
	_ok(mapa_b.get_node_or_null("PistaFurtoJanela") != null, "PistaFurtoJanela após despertar")
	_ok(mapa_b.get_node_or_null("PistaFurtoPegada") != null, "PistaFurtoPegada após despertar")
	mapa_b.queue_free()
	PlayerData.despertou_nen = false


func _test_10_skill_tree_bloqueada_sem_nen() -> void:
	print("\n[TESTE 10] Skill tree bloqueada sem despertou_nen...")
	PlayerData.despertou_nen = false
	PlayerData.nen_skill_points = 5
	var tree = PlayerData.obter_skill_tree() if PlayerData.has_method("obter_skill_tree") else null
	if tree == null:
		var NenSkillTreeScript = load("res://scripts/systems/NenSkillTree.gd")
		_ok(NenSkillTreeScript != null, "NenSkillTree.gd carrega")
		if NenSkillTreeScript == null:
			return
		tree = NenSkillTreeScript.new()
		add_child(tree)
	var sp_antes: int = PlayerData.nen_skill_points
	var ok_invest: bool = tree.investir_ponto("ren_1") if tree.has_method("investir_ponto") else true
	_ok(ok_invest == false, "investir_ponto retorna false sem despertar Nen")
	_ok(PlayerData.nen_skill_points == sp_antes, "SP não é consumido com árvore bloqueada (%d)" % PlayerData.nen_skill_points)
	PlayerData.despertou_nen = true
	PlayerData.nen_skill_points = 5
	var ok2: bool = tree.investir_ponto("ren_1") if tree.has_method("investir_ponto") else false
	_ok(ok2 == true or (tree.has_method("no_desbloqueado") and tree.no_desbloqueado("ren_1")), "investir_ponto funciona após despertar Nen")
	if tree.get_parent() == self:
		tree.queue_free()
	PlayerData.despertou_nen = false


func _test_11_soft_cap_xp_saga() -> void:
	print("\n[TESTE 11] Soft-cap XP por saga...")
	PlayerData.arco_atual = 1
	var m_ok: float = ProgressionConfig.obter_multiplicador_xp_soft_cap(20, 1)
	var m_cap: float = ProgressionConfig.obter_multiplicador_xp_soft_cap(25, 1)
	var m_over: float = ProgressionConfig.obter_multiplicador_xp_soft_cap(40, 1)
	_ok(is_equal_approx(m_ok, 1.0), "Abaixo do soft-max: multiplicador 1.0 (%.2f)" % m_ok)
	_ok(m_cap < 0.5, "No soft-max 25: XP amortecido (%.2f)" % m_cap)
	_ok(m_over <= 0.06, "Muito acima do soft-max: XP residual baixo (%.2f)" % m_over)
	_ok(ProgressionConfig.obter_faixa_saga(3).y == 60, "Arena Celestial soft-max = 60")
	_ok(ProgressionConfig.obter_faixa_saga(6).y == 230, "Formigas soft-max = 230")


func _test_12_heavens_arena_challenge_wires_tower() -> void:
	print("\n[TESTE 12] HeavensArenaTowerUI desafia ringue real...")
	var UIScript = load("res://ui/Arena/HeavensArenaTowerUI.gd")
	_ok(UIScript != null, "HeavensArenaTowerUI.gd carrega")
	if UIScript == null:
		return
	var src := FileAccess.get_file_as_string("res://ui/Arena/HeavensArenaTowerUI.gd")
	_ok("CelestialTowerArena.tscn" in src, "Desafiar aponta para CelestialTowerArena.tscn")
	_ok("andar_atual + 10" not in src, "Sem avanço automático +10 andares no botão Desafiar")
	_ok("torre_cena_retorno" in src, "Define cena de retorno da torre")
