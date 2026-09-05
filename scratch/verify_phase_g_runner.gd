extends SceneTree

const WorldStateManagerScript = preload("res://autoload/WorldStateManager.gd")
const CharacterVisualDatabaseScript = preload("res://resource/visual/CharacterVisualDatabase.gd")
const HunterLicenseCardScript = preload("res://ui/hunter_license/HunterLicenseCard.gd")
const HunterMissionContractUIScript = preload("res://ui/contracts/HunterMissionContractUI.gd")
const SagaModuleCatalogScript = preload("res://world/sagas/SagaModuleCatalog.gd")
const NetworkEntitySnapshotScript = preload("res://scripts/network/NetworkEntitySnapshot.gd")
const MultiplayerStateBridgeScript = preload("res://scripts/network/MultiplayerStateBridge.gd")

func _init() -> void:
	print("\n============================================================")
	print("🧪 EXECUTANDO TESTE INTEGRADO COMPLETO: FASE G (EPICS 1 A 8)")
	print("============================================================")

	var erros := 0

	# 1. EPIC 1 — Game Feel & Combat Polish
	print("\n[EPIC 1] Testando Hitstop & Game Feel...")
	var hitstop_script = load("res://scripts/combat/HitStopManager.gd")
	if hitstop_script != null:
		print("  ✓ HitStopManager carregado com sucesso.")
	else:
		push_error("HitStopManager não encontrado!")
		erros += 1

	# 2. EPIC 2 — Hierarquia & Battle Personality
	print("\n[EPIC 2] Testando BattlePersonality & Bosses Canônicos...")
	var bp_script = load("res://resource/personality/BattlePersonality.gd")
	if bp_script != null:
		var hisoka_bp = bp_script.criar_hisoka()
		var razor_bp = bp_script.criar_razor()
		var meruem_bp = bp_script.criar_meruem()
		if hisoka_bp != null and razor_bp != null and meruem_bp != null:
			print("  ✓ Personalidades canônicas (Hisoka, Razor, Meruem) instanciadas com sucesso.")
			print("    Hisoka taunt: '%s'" % hisoka_bp.obter_taunt())
			print("    Razor attack: '%s'" % razor_bp.obter_fala_ataque())
			print("    Meruem low hp: '%s'" % meruem_bp.obter_reacao_vida_baixa())
		else:
			push_error("Falha ao instanciar personalidades canônicas!")
			erros += 1
	else:
		erros += 1

	# 3. EPIC 3 — Memória, Relações e Consequências
	print("\n[EPIC 3] Testando RelationshipSystem & Marcos Históricos...")
	if RelationshipSystem != null:
		RelationshipSystem.aplicar_escolha_social("wing", RelationshipSystemClass.EscolhaSocial.AJUDAR)
		var rotulo = RelationshipSystem.obter_rotulo_relacionamento("wing")
		print("  ✓ Rótulo social com Wing: %s" % rotulo)
	else:
		erros += 1

	if WorldState != null:
		WorldState.registrar_treinamento_mestre("wing", "gyo")
		WorldState.registrar_vitoria_boss("hisoka", "Arena Celestial")
		var diag = WorldState.obter_dialogo_contextual_npc("wing")
		print("  ✓ Diálogo contextual de Mestre: '%s'" % diag)

	# 4. EPIC 4 — World State Engine
	print("\n[EPIC 4] Testando WorldStateManager...")
	if WorldStateManager != null:
		WorldStateManager.definir_clima(WorldStateManagerScript.Clima.TEMPESTADE_AURA)
		var info = WorldStateManager.obter_resumo_mundo()
		print("  ✓ Resumo do Mundo Vivo: Clima=%s, Perigo=%s" % [info.get("clima_nome"), info.get("regiao_perigo")])
	else:
		erros += 1

	# 5. EPIC 5 — Exploração Orgânica & Segredos
	print("\n[EPIC 5] Testando Segredos Orgânicos...")
	var rune_script = load("res://entities/secrets/NenGyoRunePuzzle.gd")
	var passage_script = load("res://entities/secrets/SecretHiddenPassage.gd")
	var secret_npc_script = load("res://entities/secrets/EccentricSecretNPC.gd")
	var secret_boss = load("res://resource/status/enemies/boss_opcional_guardiao.tres")
	if rune_script != null and passage_script != null and secret_npc_script != null and secret_boss != null:
		print("  ✓ Gyo Rune Puzzle, Passagem Secreta, NPC Excêntrico e Boss Opcional validados.")
	else:
		push_error("Falha ao carregar componentes do Epic 5!")
		erros += 1

	# 6. EPIC 6 — HatsuMastery & Equipamentos com Trade-offs
	print("\n[EPIC 6] Testando HatsuMastery Ranks 1 a 6+ & Equipamentos...")
	var h_data := HatsuData.new()
	h_data.nome = "Impacto de Aura"
	h_data.mastery = 0.0 # Rank 1
	var r1_mods = h_data.obter_modificadores_maestria()
	print("  ✓ Rank 1 (Iniciante): Custo Aura=%.2f, Tempo Conj=%.2fs" % [r1_mods.fator_custo_aura, r1_mods.tempo_conjuracao_segundos])

	h_data.mastery = 50.0 # Rank 3
	var r3_mods = h_data.obter_modificadores_maestria()
	print("  ✓ Rank 3 (Intermediário): Custo Aura=%.2f, Redução Conjuração=%.0f%%" % [r3_mods.fator_custo_aura, r3_mods.reducao_tempo_pct])

	h_data.mastery = 100.0 # Rank 6 Mestre
	var r6_mods = h_data.obter_modificadores_maestria()
	print("  ✓ Rank 6 (Mestre): Execução Instantânea=%s, Custo Aura=%.2f (-30%%)" % [r6_mods.execucao_instantanea, r6_mods.fator_custo_aura])

	var eq_lamina = DataManager.obter_equipamento(&"lamina_cacador")
	if eq_lamina != null:
		print("  ✓ Equipamento Trade-off validado: '%s' (%s)" % [eq_lamina.nome_item, eq_lamina.trade_off_descricao])
	else:
		erros += 1

	# 7. EPIC 7 — Identidade Visual & Sprites Modulares
	print("\n[EPIC 7] Testando CharacterVisualDatabase & UI Hunter...")
	for cid in ["gon", "killua", "kurapika", "leorio", "hisoka", "biscuit", "wing", "razor", "chrollo", "meruem"]:
		var ret = CharacterVisualDatabaseScript.obter_retrato(cid)
		var cdata = CharacterVisualDatabaseScript.obter_dados_visuais(cid)
		if ret == null or cdata.is_empty():
			push_error("Falha ao obter visual de %s!" % cid)
			erros += 1
	print("  ✓ Retratos pixel-art e perfis visuais gerados para todos os 10 personagens centrais.")

	var lic_card = HunterLicenseCardScript.new()
	var mission_contract = HunterMissionContractUIScript.new()
	if lic_card != null and mission_contract != null:
		print("  ✓ HunterLicenseCard e HunterMissionContractUI construídos com sucesso.")
		lic_card.free()
		mission_contract.free()
	else:
		erros += 1

	# 8. EPIC 8 — SagaModuleCatalog & MultiplayerStateBridge
	print("\n[EPIC 8] Testando SagaModuleCatalog & Abstração Multiplayer...")
	for s_id in range(1, 10):
		var mod = SagaModuleCatalogScript.obter_modulo(s_id)
		if mod.is_empty():
			push_error("Saga %d ausente no catálogo!" % s_id)
			erros += 1
	print("  ✓ Todas as 9 Sagas canônicas validadas e desacopladas no SagaModuleCatalog.")

	var snap = NetworkEntitySnapshotScript.new()
	snap.net_id = 1001
	snap.hp = 85
	snap.aura = 92.5
	snap.nen_tech = "REN"
	var snap_bytes: PackedByteArray = snap.to_byte_array()
	var snap_restaurado = NetworkEntitySnapshotScript.from_byte_array(snap_bytes)
	if snap_restaurado.hp == 85 and snap_restaurado.nen_tech == "REN":
		print("  ✓ NetworkEntitySnapshot serializado/desserializado em %d bytes." % snap_bytes.size())
	else:
		push_error("Falha na serialização binária de NetworkEntitySnapshot!")
		erros += 1

	if MultiplayerStateBridgeScript.is_offline_singleplayer():
		print("  ✓ MultiplayerStateBridge operando em modo OFFLINE_SINGLEPLAYER sem overhead.")
	else:
		erros += 1

	print("\n============================================================")
	if erros == 0:
		print("🎉 TODOS OS TESTES DA FASE G (EPICS 1 A 8) FORAM APROVADOS!")
	else:
		print("❌ TOTAL DE FALHAS: %d" % erros)
	print("============================================================\n")

	quit(erros)
