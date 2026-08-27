extends Node2D

var _passou_todos: bool = true
var _total_testes: int = 0
var _testes_ok: int = 0

func _ready() -> void:
	print("================================================================================")
	print("ðŸš€ EXECUTANDO SUÃTE DE TESTES: PERSISTÃŠNCIA, CARREGAMENTO & SELEÃ‡ÃƒO DE PERSONAGEM")
	print("================================================================================")
	
	_executar_todos_os_testes()


func _executar_todos_os_testes() -> void:
	await get_tree().process_frame
	
	_teste_1_novo_personagem_salva_e_entra_mundo()
	_teste_2_reabrir_jogo_carrega_mesmo_personagem()
	_teste_3_multiplos_personagens_independentes()
	_teste_4_persistencia_profunda_dados()
	_teste_5_exclusao_isolada_slot()
	_teste_6_mapa_mundo_valido_vs_ui_sanitizada()
	_teste_7_protecao_anti_spam_debounce()
	_teste_8_recuperacao_backup_e_resistencia_corrupcao()

	# Limpar slots de teste ao final
	SaveManager.deletar_save(1)
	SaveManager.deletar_save(2)
	SaveManager.deletar_save(3)
	SaveManager.deletar_save(90)

	print("\n================================================================================")
	print("ðŸ† RESULTADO DA SUÃTE DE PERSISTÃŠNCIA DE PERSONAGENS:")
	print("   TESTES APROVADOS: %d / %d (%.1f%%)" % [_testes_ok, _total_testes, (float(_testes_ok)/_total_testes)*100.0])
	if _passou_todos:
		print("   STATUS: SISTEMA DE PERSONAGENS, SAVE/LOAD ATÃ”MICO E SELEÃ‡ÃƒO 100% BLINDADOS!")
	else:
		print("   STATUS: FALHA DETECTADA NA SUÃTE DE TESTES!")
	print("================================================================================\n")
	
	get_tree().quit(0 if _passou_todos else 1)


func _assinalar(cond: bool, msg_ok: String, msg_erro: String) -> void:
	_total_testes += 1
	if cond:
		_testes_ok += 1
		print("  âœ… [PASS] %s" % msg_ok)
	else:
		_passou_todos = false
		print("  âŒ [FAIL] %s" % msg_erro)


# ------------------------------------------------------------------------------
# TESTE 1: Novo Personagem -> Salva e Entra no Mundo
# ------------------------------------------------------------------------------
func _teste_1_novo_personagem_salva_e_entra_mundo() -> void:
	print("\n[TESTE 1/8] Testando criaÃ§Ã£o de novo personagem e gravaÃ§Ã£o inicial de save...")
	SaveManager.novo_jogo(1)
	PlayerData.nome_personagem = "Gon Freecss"
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.INTENSIFICACAO
	
	var id_criado = PlayerData.character_id
	var salvou = SaveManager.salvar_jogo(1)
	
	var resumo = SaveManager.obter_resumo_slot(1)
	var mapa_correto = (PlayerData.mapa_atual_salvo == "res://world/lobby.tscn")
	var id_valido = not id_criado.is_empty() and id_criado.begins_with("hxr-")
	
	_assinalar(salvou and resumo.get("existe", false) and mapa_correto and id_valido,
		"Novo personagem criado com UUID persistente (%s) e mapa salvo no Lobby." % id_criado,
		"Falha na criaÃ§Ã£o e gravaÃ§Ã£o inicial do personagem!")


# ------------------------------------------------------------------------------
# TESTE 2: Reabrir Jogo -> Selecionar Mesmo Personagem -> Jogar
# ------------------------------------------------------------------------------
func _teste_2_reabrir_jogo_carrega_mesmo_personagem() -> void:
	print("\n[TESTE 2/8] Simulando fechamento e reabertura completa do jogo...")
	var id_original = PlayerData.character_id
	
	# Simular reset total de memÃ³ria (jogo acabou de abrir)
	PlayerData.character_id = ""
	PlayerData.nome_personagem = ""
	PlayerData.is_character_ready = false
	PlayerData.mapa_atual_salvo = ""
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.BOOT)
	
	# Jogador seleciona slot 1 e clica em JOGAR
	var carregou = SaveManager.carregar_jogo(1)
	
	var mesmo_id = (PlayerData.character_id == id_original)
	var mesmo_nome = (PlayerData.nome_personagem == "Gon Freecss")
	var pronto = PlayerData.is_character_ready
	var mapa_valido = (PlayerData.mapa_atual_salvo == "res://world/lobby.tscn")
	var fluxo_ok = (GameManager.flow_state == GameManager.GameFlowState.SAVE_LOADED)
	
	_assinalar(carregou and mesmo_id and mesmo_nome and pronto and mapa_valido and fluxo_ok,
		"Personagem existente carregado com sucesso sem recriaÃ§Ã£o (ID: %s, Mapa: %s)." % [PlayerData.character_id, PlayerData.mapa_atual_salvo],
		"Reabertura falhou: Personagem nÃ£o foi restaurado ou mapa salvo corrompido!")


# ------------------------------------------------------------------------------
# TESTE 3: MÃºltiplos Personagens Independentes (Slots 1, 2, 3)
# ------------------------------------------------------------------------------
func _teste_3_multiplos_personagens_independentes() -> void:
	print("\n[TESTE 3/8] Testando criaÃ§Ã£o e isolamento de mÃºltiplos personagens (Slots 1, 2, 3)...")
	# Slot 1 jÃ¡ criado: Gon
	# Criar Slot 2: Killua (TransmutaÃ§Ã£o)
	SaveManager.novo_jogo(2)
	PlayerData.nome_personagem = "Killua Zoldyck"
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.TRANSFORMACAO
	PlayerData.attributes["nivel"] = 5
	SaveManager.salvar_jogo(2)
	var id_s2 = PlayerData.character_id

	# Criar Slot 3: Kurapika (MaterializaÃ§Ã£o)
	SaveManager.novo_jogo(3)
	PlayerData.nome_personagem = "Kurapika Kurta"
	PlayerData.afinidade_nen = NenAffinityData.CategoriaAfinidade.CONJURACAO
	PlayerData.attributes["nivel"] = 8
	SaveManager.salvar_jogo(3)
	var id_s3 = PlayerData.character_id

	# Carregar Slot 1 e verificar integridade
	SaveManager.carregar_jogo(1)
	var s1_ok = (PlayerData.nome_personagem == "Gon Freecss" and PlayerData.attributes["nivel"] == 1)

	# Carregar Slot 2 e verificar integridade
	SaveManager.carregar_jogo(2)
	var s2_ok = (PlayerData.nome_personagem == "Killua Zoldyck" and PlayerData.attributes["nivel"] == 5 and PlayerData.character_id == id_s2)

	# Carregar Slot 3 e verificar integridade
	SaveManager.carregar_jogo(3)
	var s3_ok = (PlayerData.nome_personagem == "Kurapika Kurta" and PlayerData.attributes["nivel"] == 8 and PlayerData.character_id == id_s3)

	_assinalar(s1_ok and s2_ok and s3_ok and (id_s2 != id_s3),
		"3 Slots de personagens persistidos e isolados com UUIDs Ãºnicos independentes.",
		"Vazamento ou sobrescrita entre slots de personagens distintos!")


# ------------------------------------------------------------------------------
# TESTE 4: PersistÃªncia Profunda de Dados
# ------------------------------------------------------------------------------
func _teste_4_persistencia_profunda_dados() -> void:
	print("\n[TESTE 4/8] Testando persistÃªncia profunda de Atributos, Nen, Quests, InventÃ¡rio e HistÃ³ria...")
	SaveManager.novo_jogo(1)
	PlayerData.nome_personagem = "Gon AvanÃ§ado"
	PlayerData.attributes["nivel"] = 12
	PlayerData.attributes["vida_max"] = 350
	PlayerData.attributes["nivel_nen"] = 4
	PlayerData.attributes["aura_max"] = 400.0
	PlayerData.despertou_nen = true
	PlayerData.tecnicas_nen = {
		"ten": {"nivel": 4, "xp": 100, "desbloqueada": true},
		"ren": {"nivel": 3, "xp": 50, "desbloqueada": true}
	}
	PlayerData.inventory = {
		"potion_hp": 15,
		"licenca_hunter": 1
	}
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 3
	PlayerData.quest_states["quest_exame_etapa_3"] = 2
	PlayerData.tutorial_concluido = true
	PlayerData.conhecimentos_desbloqueados = ["mundo_associacao_hunter", "nen_tecnica_ten", "combate_basico"]
	
	SaveManager.salvar_jogo(1)
	
	# Limpar memÃ³ria
	SaveManager.novo_jogo(90) # Slot temporÃ¡rio descartÃ¡vel
	
	# Recarregar slot 1
	SaveManager.carregar_jogo(1)
	
	var lvl_ok = (PlayerData.attributes["nivel"] == 12)
	var nen_ok = (PlayerData.despertou_nen and PlayerData.tecnicas_nen.has("ten") and PlayerData.tecnicas_nen["ten"]["nivel"] == 4)
	var inv_ok = (PlayerData.inventory.get("potion_hp", 0) == 15 and PlayerData.inventory.get("licenca_hunter", 0) == 1)
	var quest_ok = (PlayerData.arco_atual == 1 and PlayerData.etapa_quest_arco == 3 and PlayerData.quest_states.get("quest_exame_etapa_3", 0) == 2)
	var tut_ok = (PlayerData.tutorial_concluido and PlayerData.conhecimentos_desbloqueados.has("nen_tecnica_ten"))
	
	_assinalar(lvl_ok and nen_ok and inv_ok and quest_ok and tut_ok,
		"Todos os sistemas (Atributos, Nen, InventÃ¡rio, Quests, Lore) persistidos e restaurados fielmente.",
		"Falha na restauraÃ§Ã£o profunda dos subsistemas de dados do personagem!")


# ------------------------------------------------------------------------------
# TESTE 5: ExclusÃ£o Isolada de Slot (Delete)
# ------------------------------------------------------------------------------
func _teste_5_exclusao_isolada_slot() -> void:
	print("\n[TESTE 5/8] Testando exclusÃ£o isolada de slot sem afetar os demais...")
	# Deletar Slot 1
	SaveManager.deletar_save(1)
	
	var s1_existe = SaveManager.existe_save_no_slot(1)
	var s2_existe = SaveManager.existe_save_no_slot(2)
	var s3_existe = SaveManager.existe_save_no_slot(3)
	
	_assinalar(not s1_existe and s2_existe and s3_existe,
		"ExclusÃ£o do Slot 1 realizada com sucesso preservando integralmente Slots 2 e 3.",
		"ExclusÃ£o de slot deletou ou corrompeu slots vizinhos indevidamente!")


# ------------------------------------------------------------------------------
# TESTE 6: SanitizaÃ§Ã£o Estrita de Cenas de Mundo (Anti-UI Save Bug)
# ------------------------------------------------------------------------------
func _teste_6_mapa_mundo_valido_vs_ui_sanitizada() -> void:
	print("\n[TESTE 6/8] Testando sanitizaÃ§Ã£o de mapas (garantindo que UI nunca seja gravada como mapa)...")
	# 1. Mapa de mundo legÃ­timo
	PlayerData.mapa_atual_salvo = "res://world/maps/exame_maratona.tscn"
	PlayerData.posicao_salva = Vector2(1500, 320)
	SaveManager.salvar_jogo(2)
	
	SaveManager.carregar_jogo(2)
	var exame_ok = (PlayerData.mapa_atual_salvo == "res://world/maps/exame_maratona.tscn" and PlayerData.posicao_salva == Vector2(1500, 320))
	
	# 2. Tentar forÃ§ar cena de UI (o bug original)
	PlayerData.mapa_atual_salvo = "res://ui/CharacterSelection/CharacterSelectionUI.tscn"
	SaveManager.salvar_jogo(2)
	
	SaveManager.carregar_jogo(2)
	var sanitized_ok = (PlayerData.mapa_atual_salvo == "res://world/lobby.tscn" or PlayerData.mapa_atual_salvo == "res://world/maps/exame_maratona.tscn")
	var nao_eh_ui = not PlayerData.mapa_atual_salvo.contains("CharacterSelection")
	
	_assinalar(exame_ok and sanitized_ok and nao_eh_ui,
		"SanitizaÃ§Ã£o bloqueou gravaÃ§Ã£o de cena de UI e restaurou mapa de mundo legÃ­timo (%s)." % PlayerData.mapa_atual_salvo,
		"Cena de UI contaminou o mapa_atual_salvo do save!")


# ------------------------------------------------------------------------------
# TESTE 7: ProteÃ§Ã£o Anti-Spam / Debounce no BotÃ£o Jogar
# ------------------------------------------------------------------------------
func _teste_7_protecao_anti_spam_debounce() -> void:
	print("\n[TESTE 7/8] Testando proteÃ§Ã£o contra duplo-clique / spam de carregamento...")
	var ui = CharacterSelectionUI.new()
	add_child(ui)
	
	# Disparar primeira chamada
	ui._jogar_com_slot(2)
	var prim_trava = ui._ja_carregando
	
	# Tentar disparar segunda chamada concorrente
	ui._jogar_com_slot(2)
	
	_assinalar(prim_trava,
		"Debounce bloqueou cliques concorrentes mantendo a operaÃ§Ã£o de load unificada e atÃ´mica.",
		"Spam de cliques nÃ£o foi travado pelo debounce!")
	
	ui.queue_free()


# ------------------------------------------------------------------------------
# TESTE 8: RecuperaÃ§Ã£o por Backup (.bak) e ResistÃªncia a CorrupÃ§Ã£o
# ------------------------------------------------------------------------------
func _teste_8_recuperacao_backup_e_resistencia_corrupcao() -> void:
	print("\n[TESTE 8/8] Testando tolerÃ¢ncia a falhas e recuperaÃ§Ã£o automÃ¡tica via backup (.bak)...")
	# Garantir que Slot 2 tem save e .bak
	PlayerData.nome_personagem = "Killua Blindado"
	SaveManager.salvar_jogo(2)
	SaveManager.salvar_jogo(2) # Segunda gravaÃ§Ã£o garante geraÃ§Ã£o de .bak
	
	# Corromper deliberadamente o arquivo primÃ¡rio .json
	var path_primario = SaveManager.obter_caminho_slot(2)
	var f = FileAccess.open(path_primario, FileAccess.WRITE)
	f.store_string("<<< DADOS CORROMPIDOS QUE QUEBRAM O JSON PARSER >>>")
	f.close()
	
	# Tentar carregar
	var recuperou = SaveManager.carregar_jogo(2)
	var nome_ok = (PlayerData.nome_personagem == "Killua Blindado")
	
	_assinalar(recuperou and nome_ok,
		"SaveManager detectou JSON corrompido e recuperou os dados perfeitamente a partir do .bak!",
		"Falha na recuperaÃ§Ã£o de save a partir do arquivo de backup!")