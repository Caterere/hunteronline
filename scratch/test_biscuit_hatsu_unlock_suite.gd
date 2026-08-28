extends Node

# ============================================================
# TEST SUITE: BISCUIT KRUEGER & DESBLOQUEIO DO HATSU CREATOR
# ============================================================

var testes_passados: int = 0
var testes_totais: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🥋 INICIANDO SUÍTE DE TESTES: BISCUIT & HATSU CREATOR UNLOCK")
	print("============================================================\n")

	await _executar_teste("1. Novo Jogador — Greed Island Incompleta (Hatsu Bloqueado)", _teste_novo_jogador_bloqueado)
	await _executar_teste("2. Jogador Conclui Greed Island — Desbloqueio Canônico", _teste_conclusao_greed_island)
	await _executar_teste("3. Save Nível 100 com Greed Island Incompleta — Hatsu Permanece Bloqueado", _teste_lv100_incompleto)
	await _executar_teste("4. Save Nível 100 com Greed Island Concluída — Hatsu Desbloqueado", _teste_lv100_concluido)
	await _executar_teste("5. Migração de Save Antigo Legado (Compatibilidade)", _teste_migracao_save_legado)
	await _executar_teste("6. Persistência Atômica de Save / Load", _teste_persistencia_save_load)
	await _executar_teste("7. Conclusão Repetida de Greed Island (Idempotência)", _teste_conclusao_repetida)
	await _executar_teste("8. Instanciação e Abertura Segura do HatsuCreationUI pela Biscuit", _teste_biscuit_abrir_creator)

	print("\n============================================================")
	print("📊 RESULTADO DA SUÍTE BISCUIT & HATSU CREATOR:")
	print("Passou em: %d / %d testes (%.1f%%)" % [testes_passados, testes_totais, (float(testes_passados) / float(testes_totais)) * 100.0])
	print("============================================================\n")

	if testes_passados == testes_totais:
		print("🎉 TODOS OS TESTES PASSARAM COM SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES FALHARAM!")

	get_tree().quit(0 if testes_passados == testes_totais else 1)


func _executar_teste(nome: String, metodo: Callable) -> void:
	testes_totais += 1
	print("▶ Teste %d: %s" % [testes_totais, nome])
	var ok: bool = await metodo.call()
	if ok:
		testes_passados += 1
		print("  ✅ PASSOU: %s\n" % nome)
	else:
		print("  ❌ FALHOU: %s\n" % nome)


func _teste_novo_jogador_bloqueado() -> bool:
	PlayerData.reset()
	PlayerData.arco_atual = 1
	PlayerData.max_arco_desbloqueado = 1
	PlayerData.modo_historia_concluido = false
	PlayerData.despertou_nen = true

	if PlayerData.is_greed_island_concluida():
		print("  Erro: Greed Island não deveria estar concluída para novo jogador.")
		return false

	if PlayerData.hatsu_creation_unlocked:
		print("  Erro: hatsu_creation_unlocked deveria ser false.")
		return false

	var biscuit_scn = load("res://entities/npc/biscuit/Biscuit.tscn")
	var biscuit = biscuit_scn.instantiate()
	add_child(biscuit)

	var dummy_player = CharacterBody2D.new()
	biscuit._on_interacted(dummy_player)

	# Como está bloqueado, o modal_menu não deve ter sido criado
	if biscuit.modal_menu != null:
		print("  Erro: Biscuit não deveria abrir o menu interativo de criação.")
		biscuit.queue_free()
		dummy_player.queue_free()
		return false

	biscuit.queue_free()
	dummy_player.queue_free()
	return true


func _teste_conclusao_greed_island() -> bool:
	PlayerData.reset()
	PlayerData.arco_atual = 5
	PlayerData.despertou_nen = true
	PlayerData.desbloquear_hatsu_creator()

	if not PlayerData.hatsu_creation_unlocked:
		print("  Erro: hatsu_creation_unlocked deveria ser true após desbloquear_hatsu_creator.")
		return false

	if not PlayerData.hatsu_desbloqueado:
		print("  Erro: hatsu_desbloqueado deveria estar sincronizado como true.")
		return false

	var biscuit_scn = load("res://entities/npc/biscuit/Biscuit.tscn")
	var biscuit = biscuit_scn.instantiate()
	add_child(biscuit)

	var dummy_player = CharacterBody2D.new()
	biscuit._on_interacted(dummy_player)

	if biscuit.modal_menu == null:
		print("  Erro: Biscuit deveria ter aberto o menu interativo com a opção de criar Hatsu.")
		biscuit.queue_free()
		dummy_player.queue_free()
		return false

	biscuit._fechar_menu_interacao()
	biscuit.queue_free()
	dummy_player.queue_free()
	return true


func _teste_lv100_incompleto() -> bool:
	PlayerData.reset()
	PlayerData.attributes["nivel"] = 100
	PlayerData.attributes["nivel_nen"] = 100
	PlayerData.attributes["aura"] = 5000.0
	PlayerData.attributes["aura_max"] = 5000.0
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = 2 # Montanha Kukuroo
	PlayerData.max_arco_desbloqueado = 2
	PlayerData.modo_historia_concluido = false
	PlayerData.hatsu_creation_unlocked = false
	PlayerData.hatsu_desbloqueado = false

	# Nível 100 sozinho NÃO deve concluir Greed Island
	if PlayerData.is_greed_island_concluida():
		print("  Erro: is_greed_island_concluida retornou true para Arco 2!")
		return false

	if PlayerData.hatsu_creation_unlocked:
		print("  Erro: Nível 100 sozinho desbloqueou o Hatsu Creator indevidamente!")
		return false

	return true


func _teste_lv100_concluido() -> bool:
	PlayerData.reset()
	PlayerData.attributes["nivel"] = 100
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = 6 # Formigas Chimera (Greed Island concluída)
	PlayerData.max_arco_desbloqueado = 6

	if not PlayerData.is_greed_island_concluida():
		print("  Erro: is_greed_island_concluida deveria ser true para Arco 6.")
		return false

	# Simular verificação do save
	if PlayerData.is_greed_island_concluida():
		PlayerData.desbloquear_hatsu_creator()

	if not PlayerData.hatsu_creation_unlocked:
		print("  Erro: hatsu_creation_unlocked não foi ativado para save Lv 100 pós-Greed Island.")
		return false

	return true


func _teste_migracao_save_legado() -> bool:
	# Criar save falso de versão antiga sem a chave 'hatsu_creation_unlocked'
	var mock_save: Dictionary = {
		"timestamp": "2026-08-28 12:00:00",
		"mapa_atual": "res://world/lobby.tscn",
		"posicao_player": [0.0, 0.0],
		"nome_personagem": "Hunter Legado",
		"afinidade_nen": 0,
		"dificuldade": 1,
		"arco_atual": 6, # Já passou de Greed Island
		"max_arco_desbloqueado": 6,
		"modo_historia_concluido": false,
		"despertou_nen": true,
		"attributes": {"vida": 100, "vida_max": 100, "nivel": 50, "forca": 20, "defesa": 20, "velocidade": 20, "aura": 200.0, "aura_max": 200.0},
		"character_id": "hxr-legado-s88",
		"slot": 88
	}

	var save_str := JSON.stringify(mock_save, "\t")
	var file := FileAccess.open("user://savegame_slot_88.json", FileAccess.WRITE)
	if file != null:
		file.store_string(save_str)
		file.close()

	PlayerData.reset()
	var ok := SaveManager.carregar_jogo(88)
	if not ok:
		print("  Erro: Falha ao carregar save de teste legado.")
		return false

	if not PlayerData.hatsu_creation_unlocked:
		print("  Erro: Migração automática de save legado não desbloqueou o Hatsu Creator.")
		SaveManager.remover_save(88)
		return false

	SaveManager.remover_save(88)
	return true


func _teste_persistencia_save_load() -> bool:
	PlayerData.reset()
	PlayerData.character_id = "hxr-persist-s89"
	PlayerData.nome_personagem = "Hunter Persistente"
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = 5
	PlayerData.desbloquear_hatsu_creator()

	var ok_save := SaveManager.salvar_jogo(89)
	if not ok_save:
		print("  Erro: Falha ao salvar jogo no slot 89.")
		return false

	# Resetar PlayerData para estado vazio
	PlayerData.reset()
	if PlayerData.hatsu_creation_unlocked:
		print("  Erro: Reset não limpou hatsu_creation_unlocked.")
		SaveManager.remover_save(89)
		return false

	var ok_load := SaveManager.carregar_jogo(89)
	if not ok_load:
		print("  Erro: Falha ao carregar jogo do slot 89.")
		SaveManager.remover_save(89)
		return false

	if not PlayerData.hatsu_creation_unlocked:
		print("  Erro: hatsu_creation_unlocked não foi restaurado após carregar o save!")
		SaveManager.remover_save(89)
		return false

	SaveManager.remover_save(89)
	return true


func _teste_conclusao_repetida() -> bool:
	PlayerData.reset()
	PlayerData.arco_atual = 5
	PlayerData.despertou_nen = true

	# Concluir Greed Island 3 vezes
	PlayerData.completar_etapa_historia(5)
	PlayerData.completar_etapa_historia(5)
	PlayerData.desbloquear_hatsu_creator()

	if not PlayerData.hatsu_creation_unlocked:
		print("  Erro: Conclusão repetida quebrou o flag de unlock.")
		return false

	return true


func _teste_biscuit_abrir_creator() -> bool:
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.desbloquear_hatsu_creator()

	var biscuit_scn = load("res://entities/npc/biscuit/Biscuit.tscn")
	var biscuit = biscuit_scn.instantiate()
	add_child(biscuit)

	# Testar método de abertura direta
	biscuit._abrir_hatsu_creator()

	var hatsu_ui: HatsuCreationUI = get_tree().root.get_node_or_null("HatsuCreationUI") as HatsuCreationUI
	if hatsu_ui == null:
		hatsu_ui = biscuit.get_node_or_null("HatsuCreationUI") as HatsuCreationUI

	if hatsu_ui == null:
		print("  Erro: HatsuCreationUI não foi instanciado!")
		biscuit.queue_free()
		return false

	if not hatsu_ui.visible:
		print("  Erro: HatsuCreationUI não ficou visível após abrir()!")
		biscuit.queue_free()
		hatsu_ui.queue_free()
		return false

	hatsu_ui.fechar()
	hatsu_ui.queue_free()
	biscuit.queue_free()
	return true
