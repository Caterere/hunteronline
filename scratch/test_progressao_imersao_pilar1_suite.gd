extends Node

# ============================================================
# Suite: Progressão & Imersão — Pilar 1 (treino + equipamento)
# ============================================================

const EquipmentCatalogScript = preload("res://resource/item/EquipmentCatalog.gd")
const TrainingSystemScript = preload("res://scripts/systems/TrainingSystem.gd")
const StoryPacingManagerScript = preload("res://scripts/systems/StoryPacingManager.gd")
const CutsceneSequenceRunnerScript = preload("res://scripts/cutscenes/CutsceneSequenceRunner.gd")

var _passed: int = 0
var _failed: int = 0


func _ready() -> void:
	print("\n========== TEST PROGRESSAO IMERSAO PILAR1 ==========")
	await get_tree().process_frame
	_reset_player()
	_teste_catalogo_equipamento()
	_teste_equipar_desequipar()
	_teste_treino_wing_permanente()
	_teste_treino_nao_repete()
	_teste_reaplicar_apos_load_simulado()
	_teste_travel_catalog()
	await _teste_cutscene_steps_maratona()
	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	if _failed > 0:
		OS.set_environment("HO_TEST_FAILED", "1")
		get_tree().quit(1)
	else:
		get_tree().quit(0)


func _reset_player() -> void:
	PlayerData.reset()
	PlayerData.inventory.clear()
	PlayerData.equipped = {
		"cabeca": "",
		"corpo": "",
		"mao_princ": "",
		"mao_sec": "",
		"acessorio": "",
		"licenca": "",
	}
	PlayerData.active_modifiers.clear()
	PlayerData.despertou_nen = true
	PlayerData.aplicar_nivel_nen(1)
	PlayerData.attributes["nivel"] = 20
	PlayerData.recalcular_todos_atributos()
	if StoryManager != null:
		for tid in ["ten_resistencia", "fortalecimento_fisico", "ren_intensificacao", "fluxo_ko"]:
			StoryManager.set_story_flag("treino_" + tid, false)
		for eid in ["estrada_comerciante", "patrulha_associacao", "emboscada_leve"]:
			StoryManager.set_story_flag("travel_event_" + eid, false)
		StoryManager.set_story_flag("test_cutscene_pilar1", false)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", msg)
	else:
		_failed += 1
		print("  FAIL: ", msg)


func _teste_catalogo_equipamento() -> void:
	print("\n[1] Catalogo de equipamento")
	_assert(EquipmentCatalogScript.ids().size() >= 10, "Pelo menos 10 itens no catalogo")
	_assert(EquipmentCatalogScript.eh_equipamento("adaga_zaban"), "adaga_zaban e equipamento")
	_assert(EquipmentCatalogScript.obter_slot("adaga_zaban") == &"mao_princ", "slot mao_princ")
	_assert(EquipmentCatalogScript.listar_crafts().size() >= 2, "crafts espada/armadura")


func _teste_equipar_desequipar() -> void:
	print("\n[2] Equipar / desequipar com StatModifier")
	PlayerData.adicionar_item(&"adaga_zaban", 1)
	PlayerData.adicionar_item(&"colete_cacador", 1)
	var forca_base: int = int(PlayerData.attributes.get("forca", 0))
	var def_base: int = int(PlayerData.attributes.get("defesa", 0))

	var r1: Dictionary = PlayerData.equipar_item("adaga_zaban")
	_assert(r1.get("sucesso", false), "equipar adaga")
	_assert(PlayerData.obter_equipado("mao_princ") == "adaga_zaban", "slot mao_princ preenchido")
	_assert(int(PlayerData.attributes.get("forca", 0)) > forca_base, "forca aumentou com adaga")

	var r2: Dictionary = PlayerData.equipar_item("colete_cacador")
	_assert(r2.get("sucesso", false), "equipar colete")
	_assert(int(PlayerData.attributes.get("defesa", 0)) > def_base, "defesa aumentou com colete")

	# Shu bonus
	var shu: float = PlayerData.obter_modificador_total("dano_arma")
	_assert(shu > 0.0, "bonus Shu (dano_arma) ativo")

	var r3: Dictionary = PlayerData.desequipar_slot("mao_princ")
	_assert(r3.get("sucesso", false), "desequipar adaga")
	_assert(PlayerData.obter_equipado("mao_princ") == "", "slot vazio apos desequipar")


func _teste_treino_wing_permanente() -> void:
	print("\n[3] Treino Wing com StatModifier permanente")
	var ts = TrainingSystemScript.obter_ou_criar(get_tree())
	_assert(ts != null, "TrainingSystem obtido")
	var aura_antes: int = int(PlayerData.attributes.get("aura_max", 0))
	var sp_antes: int = PlayerData.nen_skill_points
	var res: Dictionary = ts.executar_sessao_treino("ten_resistencia", get_tree())
	_assert(res.get("sucesso", false), "treino ten_resistencia concluiu")
	_assert(int(PlayerData.attributes.get("aura_max", 0)) >= aura_antes + 25, "aura_max +25")
	_assert(PlayerData.nen_skill_points >= sp_antes + 1, "nen SP +1")
	_assert(ts.ja_concluiu_treino("ten_resistencia"), "marcado como concluido")

	# Recalc nao apaga
	PlayerData.recalcular_todos_atributos()
	_assert(int(PlayerData.attributes.get("aura_max", 0)) >= aura_antes + 25, "aura persiste apos recalc")


func _teste_treino_nao_repete() -> void:
	print("\n[4] Treino nao repete")
	var ts = TrainingSystemScript.obter_ou_criar(get_tree())
	var res: Dictionary = ts.executar_sessao_treino("ten_resistencia", get_tree())
	_assert(not res.get("sucesso", true), "segunda tentativa bloqueada")


func _teste_reaplicar_apos_load_simulado() -> void:
	print("\n[5] Reaplicar mods apos limpar modifiers (simula load)")
	# Mantem equipped + flags, limpa modifiers e reaplica
	PlayerData.equipar_item("colete_cacador")
	var def_com_gear: int = int(PlayerData.attributes.get("defesa", 0))
	PlayerData.active_modifiers.clear()
	PlayerData.recalcular_todos_atributos()
	var def_sem: int = int(PlayerData.attributes.get("defesa", 0))
	_assert(def_sem < def_com_gear, "sem mods defesa cai")
	PlayerData.reaplicar_mods_progressao()
	var def_re: int = int(PlayerData.attributes.get("defesa", 0))
	_assert(def_re >= def_com_gear, "reaplicar restaura defesa do colete + treinos")


func _teste_travel_catalog() -> void:
	print("\n[6] Catalogo de eventos de viagem")
	_assert(StoryPacingManagerScript.EVENTOS_VIAGEM.has("estrada_comerciante"), "evento comerciante")
	_assert(StoryPacingManagerScript.EVENTOS_VIAGEM.has("emboscada_leve"), "evento emboscada")
	_assert(StoryPacingManagerScript.EVENTOS_VIAGEM.has("patrulha_associacao"), "evento patrulha")


func _teste_cutscene_steps_maratona() -> void:
	print("\n[7] Semi-cutscene runner smoke")
	_assert(not CutsceneSequenceRunnerScript.em_execucao, "runner livre no inicio")
	var passos: Array[Dictionary] = [
		{"type": CutsceneSequenceRunnerScript.StepType.LOCK_INPUT, "lock": true},
		{"type": CutsceneSequenceRunnerScript.StepType.WAIT, "seconds": 0.05},
		{"type": CutsceneSequenceRunnerScript.StepType.SET_FLAG, "flag": "test_cutscene_pilar1", "value": true},
		{"type": CutsceneSequenceRunnerScript.StepType.LOCK_INPUT, "lock": false},
	]
	var done := {"ok": false}
	CutsceneSequenceRunnerScript.executar(get_tree(), passos, "Test_Pilar1", func():
		done["ok"] = true
	)
	var timeout := 2.0
	while timeout > 0.0 and not done["ok"]:
		await get_tree().process_frame
		timeout -= get_process_delta_time()
	_assert(done["ok"], "cutscene runner concluiu")
	_assert(StoryManager.get_story_flag("test_cutscene_pilar1", false), "flag de cutscene setada")
